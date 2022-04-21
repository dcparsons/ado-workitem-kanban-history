# Azure DevOps (ADO) Kanban Work Item History Tracker 

A solution to see how long a Work Item has been in a given column of a Kanban board in Azure DevOps. 

## Summary
As of this writing (2022) Azure DevOps does not provide users with a way to see how long a Work Item has been in a given column on the Kanban Board.  Users are able to manually read through a Work Item's history to see when the Work Item moved from one column to another, however this is cumbersome and time consuming.  

This daemon solves that problem by populating a set of tables in SQL Server that can be used to generate a report that shows a Work Item's movement across the board and how long a Work Item spent in each column. 


## Gotchas 
This section contains all of the "gotchas" with this solution.

 - This code does not give you the ability to "look into the past" in terms of Work Item history.  This code builds a set of history tables, based on data in ADO, that can be used to run reports off of.  Said another way: this code can provide data to build accurate reports going forward but it can't tell you about how long Work Items spent in columns previously. 
 - This is solution ***does not*** provide code to generate an actual 'Days In Column' report.  The reason a report is not included is because it is impossible to know what columns an organization is using for their board or the keys associated to those columns.  A sample SQL Query is provided in this readme to show how a report could be generated though.  
 - This code is designed to be run once a day as a cron job or scheduled task. Failing to run the code every day can lead to bad counts in your data. 
 - This code can only query from one ADO Project at a time.

## Technical Requirements 

 - A way to compile and run a .NET 6.0 C# solution such as [Visual Studio Community Edition](https://visualstudio.microsoft.com/free-developer-offers/)
 - SQL Server 2019. SQL Server 2016 likely could also be used (that is an untested statement) but any version prior to that won't work because of the use of JSON in Stored Procedures.
 - Optionally, a Google Cloud Provider account.  This is only necessary if you want to push data into Google Sheets instead of / in addition to SQL Server. 
 - Ability to create a cron job or Scheduled Task

## C# Solution & Settings
Before getting started it is worth pointing out that this solution does not use any of the client libraries that Microsoft has published for ADO/VSTS.  This was nothing more than a design decision.

The solution itself is fairly straightforward (make an API call, get the data, save it to the persistence layer, end) so this section does not go through it file by file.  Instead this section focuses mostly on what settings data you need to provide in order to get the solution to work. 

### appsettings.json

 - **DEVOPS_URL** - base URL for Azure DevOps.  Change this if you are using an OnPrem version of ADO. 
 - **WIQL_API_PATH** - the Work Item Query Language API path. 
 - **WIT_API_PATH** - the Work Item API path to get data for a single work item.
 - **WIT_API_PATH_BULK** - the Work Item API path to get data for many work items.
 - **ADOAnalysis** (Connection String) - once you have created the database you will need to configure a password for the SQL User *wit-daemon* and provide it here.  
 - **DEVOPS_ORG_NAME** - your ADO organization name
 - **DEVOPS_PROJECT_NAME** - the ADO project that you want to query work items from
 - **DEVOPS_TEAM_NAME** - a team name within the ADO Project specified above.  *(This is important for constructing the URL for the API call but it does not limit queries to just work items assigned to that team)*
 - **MAX_BULK_ADO_COUNT** - the maximum number or Work Item IDs to be sent to the Bulk Work Item API Path when requesting data.  The upper bound is set by Microsoft and the current maximum is 200 so this value should not exceed 200.
 - **PAT** - an ADO Personal Access Token that has the scope to Read Work Items.
 -   **GETALLWORKITEMS** - a WIQL query to Get All Work Items from the specified ADO Project.  Used for the initial run of the code. *The WHERE clause can be modified to suit your needs.* 
 - **GETWORKITEMSSINCELASTRUN** - a WIQL query to Get All Work Items that have been created or modified since the last run of the code. *The WHERE clause can be modified to suit your needs.* 
 - **SHEET_ID** - the ID of the Google Sheet to write to. *See Connectors section below.*
 - **GCP_PROJECT_NAME** - the name of your GCP Project. *See Connectors section below.*

**Note** - if you are unsure of what values you need to provide for the DEVOPS settings above, the ADO url has this format: https://dev.azure.com/{organization}/{project}

### Connectors
What is called a connector in this solution is just a means to pass data into the persistence layer.  The solution contains 2 connectors: a `SqlConnector` and a `SheetConnector`. 

Out-of-the-box the solution is configured to ONLY use the `SqlConnector` which will pass data to SQL based on the configured Connection String.  

If you would like to pass data to a Google Sheet instead of or in addition to SQL Server, you can modify the code to make calls to the `SheetConnector` as well.   The `SheetConector`is a legacy implementation which is why it isn't hooked up anywhere in the code, however it might still be useful.  If you are interested in also using the `SheetConnector` you will need to read through the [C# Quickstart for Google Sheets](https://developers.google.com/sheets/api/quickstart/dotnet)

### SQL Server Solution

#### Setup
In the root of the repo you will find a file named **database.sql** which will create the entire database schema required by the C# Solution.  Run this script file in SQL Server Management Studio as a SQL Administrator to create a database named ADOAnalysis.  Once the database is created you will need to do the following items listed below.

 - Create a SQL Server Login with a username and password and map this login to the ADO Analysis user wit-daemon.  The username and password that you specify here are what you should put in the connection string mentioned previously. 
 - Grant EXECUTE permissions to the database user wit-daemon: `GRANT EXECUTE TO [wit-daemon]`
 - Grant UPDATE permissions on the Sequence object to the database user wit-daemon: `GRANT UPDATE ON [WitWorkflowSequence] TO [wit-daemon]`

#### Schema
There are 4 tables in the ADOAnalysis database listed below.
- **dbo.SystemRuns** - contains a list of dates that correspond to the C# solution being run.  The most recent run, if present, is used in the GETWORKITEMSSINCELASTRUN query above. 
- **dbo.WEFLookup** - this table is optional and the C# solution doesn't care about. If you want to use it the data needs to be manually entered.  Read more about the use of this table in the *WEF Keys and Boards* section below.
- **dbo.WorkItems** - this table contains all of the data related to the Work Items that were returned as a result of our queries above.  
- **dbo.WorkItems_ColumnHistory** - this table will only be populated if you are using a board that you have customized.  If you are using the system default Kanban board there won't be any data in this table.  In the event that you have a customized board, this table contains the data needed to determin 'Days in Column' for custom boards. See the *WEF Keys and Boards* section below for more information. 

#### Data
This section is going to talk broadly about how data is saved in the database instead of walking through the stored procedures that are responsible for saving the data.  The system only contains 5 stored procedures, all of which are fairly straightforward, so please have a look for yourself. 

The C# solution passes data about all Work Items that have had any modification since the last system run to the database. However, because the system is only interested in tracking when a Work Item has moved into a different board column, the database will discard any Work Items that have not had changes made to their board columns.  Said another way: the database does not track every time a change is made to a work item, only when a change is made to the columns related to the board columns. 

**WEF Keys and Boards**
In the WorkItems table there are two columns: BoardColumn and BoardColumnDone; the BoardColumn denotes which column of the associated Kanban Board a WorkItem is in while the BoardColumnDone column indicates whether or not the Work Item has been moved into the Done section of a column that has been split into Doing and Done.  

For reasons unknown to me the data in BoardColumn does not always visually correlate to Columns that currently exist on the actual board.  For example: during testing I had a Work Item that was in a column named 'Development' however the data I was getting from the ADO APIs said that the Work Item was in a column named 'In Progress' which no longer existed on my board. 

What I noticed in my analysis of the Work Item data was that there were a set JSON fields that followed the format shown below.

 - WEF_{ID}_Kanban.Column - work items had 1 or more of these fields that displayed the name(s) of Columns on a Kanban board.  When there was more than one of these per Work Item, only one of the columns actually existed on the board.  
 - WEF_{ID}_Kanban.Column.Done - directly linked to the Kanban column that shared its ID.  Indicated whether or not an item was in the 'Done' section of a column that had been split into 'Doing' and 'Done'.

Using the [Boards API](https://docs.microsoft.com/en-us/rest/api/azure/devops/work/boards/list?view=azure-devops-rest-6.0) I noticed a correlation between the ID that was used in the above fields and what was being returned in the Boards API payload.  My guess is that this is a way of tracking the history of Board Column names internally in ADO.  In any event, using the ID returned by the Boards API against the data returned by the Work Item API I was always able to get the correct column name for a given Work Item. The only problem here is that if my assumption is correct then as the ID changes in ADO it will need to change in the report query to stay accurate.  Not a deal breaker, but annoying. 

**TL;DR:** if you are fine with some discrepancy in the name of the Board Column a Work Item is in you can use just the data in dbo.WorkItems to build your report.  If you want something more accurate you will also need to use the data in dbo.WorkItem_ColumnHistory.


### Example Report Query

    SELECT DISTINCT
    	wi.WitID,
    	DATEDIFF(day, wic_new.AuditCreatedDate, Coalesce(wic_prog.AuditCreatedDate, wic_released.AuditCreatedDate, GETDATE())) as DaysInNew,
    	DATEDIFF(day, wic_prog.AuditCreatedDate, Coalesce(wic_released.AuditCreatedDate, GETDATE())) as DaysInProgess,
    	DATEDIFF(day, wic_released.AuditCreatedDate, GETDATE()) as DaysInReleased
    FROM WorkItems wi
    LEFT JOIN WorkItem_ColumnHistory wic_new on (wic_new.WitID = wi.WitID AND wic_new.CurrentColumn = 'New' AND wic_new.WefColumnID LIKE '%[YOUR TEAMS WEF ID]%')
    LEFT JOIN WorkItem_ColumnHistory wic_prog on (wic_prog.WitID = wi.WitID AND wic_prog.CurrentColumn = 'In Progress' AND wic_prog.WefColumnID LIKE '%[YOUR TEAMS WEF ID]%')
    LEFT JOIN WorkItem_ColumnHistory wic_released on (wic_released.WitID = wi.WitID AND wic_released.CurrentColumn = 'Released' AND wic_released.WefColumnID LIKE '%[YOUR TEAMS WEF ID]%')
    WHERE
    wi.[State] NOT IN('Closed', 'Removed')
    ORDER BY WitID ASC
The most important part of this query is the Coalesce statement.  The date columns in the Coalesce need to be the associated to the columns that fall to the right of a given column on the physical board.  Because a card could move from New to Released in a day, the date column for In Progress would be NULL, therefore the span between the Work item being in new would be the difference between that date and the Released date.  In this example a card would go from New to In Progress to Released. 
