USE [master]
GO
/****** Object:  Database [ADOAnalysis]    Script Date: 4/20/2022 10:46:01 ******/
CREATE DATABASE [ADOAnalysis]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ADOAnalysis', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ADOAnalysis.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ADOAnalysis_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ADOAnalysis_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [ADOAnalysis] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ADOAnalysis].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ADOAnalysis] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ADOAnalysis] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ADOAnalysis] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ADOAnalysis] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ADOAnalysis] SET ARITHABORT OFF 
GO
ALTER DATABASE [ADOAnalysis] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ADOAnalysis] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ADOAnalysis] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ADOAnalysis] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ADOAnalysis] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ADOAnalysis] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ADOAnalysis] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ADOAnalysis] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ADOAnalysis] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ADOAnalysis] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ADOAnalysis] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ADOAnalysis] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ADOAnalysis] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ADOAnalysis] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ADOAnalysis] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ADOAnalysis] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ADOAnalysis] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ADOAnalysis] SET RECOVERY FULL 
GO
ALTER DATABASE [ADOAnalysis] SET  MULTI_USER 
GO
ALTER DATABASE [ADOAnalysis] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ADOAnalysis] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ADOAnalysis] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ADOAnalysis] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ADOAnalysis] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ADOAnalysis] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ADOAnalysis', N'ON'
GO
ALTER DATABASE [ADOAnalysis] SET QUERY_STORE = OFF
GO
USE [ADOAnalysis]
GO
/****** Object:  User [wit-daemon]    Script Date: 4/20/2022 10:46:01 ******/
CREATE USER [wit-daemon] FOR LOGIN [wit-daemon] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [wit-daemon]
GO
USE [ADOAnalysis]
GO
/****** Object:  Sequence [dbo].[WitWorkflowSequence]    Script Date: 4/20/2022 10:46:01 ******/
CREATE SEQUENCE [dbo].[WitWorkflowSequence] 
 AS [bigint]
 START WITH 10000
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 CACHE 
GO
/****** Object:  Table [dbo].[SystemRuns]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemRuns](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RunDate] [datetime] NOT NULL,
	[IsLastRun] [bit] NOT NULL,
 CONSTRAINT [PK_SystemRuns] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WEFLookup]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WEFLookup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TeamName] [nvarchar](50) NOT NULL,
	[BoardWEFID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_WEFLookup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkItem_ColumnHistory]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkItem_ColumnHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WitID] [int] NOT NULL,
	[WefColumnID] [nvarchar](250) NULL,
	[CurrentColumn] [nvarchar](50) NULL,
	[IsDone] [bit] NULL,
	[WorkflowSequence] [int] NOT NULL,
	[AuditCreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WorkItem_ColumnHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkItems]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WitID] [int] NOT NULL,
	[AreaPath] [nvarchar](50) NOT NULL,
	[TeamProject] [nvarchar](50) NOT NULL,
	[IterationPath] [nvarchar](100) NULL,
	[ItemType] [nvarchar](50) NOT NULL,
	[State] [nvarchar](50) NOT NULL,
	[Reason] [nvarchar](50) NOT NULL,
	[AssignedTo] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[ChangedDate] [datetime] NULL,
	[ChangedBy] [nvarchar](50) NULL,
	[CommentCount] [int] NULL,
	[Title] [nvarchar](255) NOT NULL,
	[BoardColumn] [nvarchar](50) NULL,
	[BoardColumnDone] [bit] NULL,
	[StateChangeDate] [datetime] NULL,
	[ActivatedDate] [datetime] NULL,
	[ActivatedBy] [nvarchar](50) NULL,
	[ResolvedDate] [datetime] NULL,
	[ResolvedBy] [nvarchar](50) NULL,
	[ClosedDate] [datetime] NULL,
	[ClosedBy] [nvarchar](50) NULL,
	[Priority] [nvarchar](50) NULL,
	[StackRank] [nvarchar](50) NULL,
	[ValueArea] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[History] [nvarchar](max) NULL,
	[Tags] [nvarchar](max) NULL,
	[WorkflowSequence] [int] NOT NULL,
	[AuditCreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WorkItems] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[WitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkItem_ColumnHistory] ADD  CONSTRAINT [DF_WorkItem_ColumnHistory_AuditCreatedDate]  DEFAULT (getdate()) FOR [AuditCreatedDate]
GO
ALTER TABLE [dbo].[WorkItems] ADD  CONSTRAINT [DF_WorkItems_AuditCreatedDate]  DEFAULT (getdate()) FOR [AuditCreatedDate]
GO
ALTER TABLE [dbo].[WorkItem_ColumnHistory]  WITH CHECK ADD  CONSTRAINT [FK_WorkItem_ColumnHistory_WorkItem_ColumnHistory] FOREIGN KEY([ID])
REFERENCES [dbo].[WorkItem_ColumnHistory] ([ID])
GO
ALTER TABLE [dbo].[WorkItem_ColumnHistory] CHECK CONSTRAINT [FK_WorkItem_ColumnHistory_WorkItem_ColumnHistory]
GO
/****** Object:  StoredProcedure [dbo].[usp_AddWorkItem]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AddWorkItem]
	@witJson as nvarchar(max),
	@seqval as bigint
AS
BEGIN
	SET NOCOUNT ON;


	SELECT 
		*
	INTO #WITWorkTable
	FROM OPENJSON(@witJson, '$')
	WITH
	(
		id					int					'$.id',
		AreaPath			nvarchar(50)		'$.fields."System.AreaPath"',
		TeamProject			nvarchar(50)		'$.fields."System.TeamProject"',
		IterationPath		nvarchar(100)		'$.fields."System.IterationPath"',
		ItemType			nvarchar(50)		'$.fields."System.WorkItemType"',
		[State]				nvarchar(50)		'$.fields."System.State"',
		Reason				nvarchar(50)		'$.fields."System.Reason"',
		AssignedTo			nvarchar(50)		'$.fields."System.AssignedTo".displayName',
		CreatedDate			datetime			'$.fields."System.CreatedDate"',
		CreatedBy			nvarchar(50)		'$.fields."System.CreatedBy".displayName',
		ChangedDate			datetime			'$.fields."System.ChangedDate"',
		ChangedBy			nvarchar(50)		'$.fields."System.ChangedBy".displayName',
		CommentCount		int					'$.fields."System.CommentCount"',
		Title				nvarchar(255)		'$.fields."System.Title"',
		BoardColumn			nvarchar(50)		'$.fields."System.BoardColumn"',
		BoardColumnDone		bit					'$.fields."System.BoardColumnDone"',
		StateChangeDate		datetime			'$.fields."Microsoft.VSTS.Common.StateChangeDate"',
		ActivatedDate		datetime			'$.fields."Microsoft.VSTS.Common.ActivatedDate"',
		ActivatedBy			nvarchar(50)		'$.fields."Microsoft.VSTS.Common.ActivatedBy".displayName',
		ResolvedDate		datetime			'$.fields."Microsoft.VSTS.Common.ResolvedDate"',
		ResolvedBy			nvarchar(50)		'$.fields."Microsoft.VSTS.Common.ResolvedBy".displayName',
		ClosedDate  		datetime			'$.fields."Microsoft.VSTS.Common.ClosedDate"',
		ClosedBy			nvarchar(50)		'$.fields."Microsoft.VSTS.Common.ClosedBy".displayName',
		[Priority]			nvarchar(50)		'$.fields."Microsoft.VSTS.Common.Priority"',
		StackRank			nvarchar(50)		'$.fields."Microsoft.VSTS.Common.StackRank"',
		ValueArea			nvarchar(50)		'$.fields."Microsoft.VSTS.Common.ValueArea"',
		[Description]		nvarchar(max)		'$.fields."System.Description"',
		History				nvarchar(max)		'$.fields."System.History"',
		Tags				nvarchar(max)		'$.fields."System.Tags"'
	) as jData

	
	--INSERT only records that either don't exsit or have changed their Board Column values.
	--The intent of this table is to track changes to the board column values and not to restate the history of a WIT
	MERGE WorkItems AS trgt
	USING #WITWorkTable as src
	ON trgt.WitID = src.id AND trgt.BoardColumn = src.BoardColumn AND trgt.BoardColumnDone = src.BoardColumnDone
	WHEN NOT MATCHED THEN
		INSERT (WitID, AreaPath, TeamProject, IterationPath, ItemType, [State], Reason, AssignedTo, CreatedDate, CreatedBy, ChangedDate, ChangedBy, CommentCount, Title, BoardColumn, BoardColumnDone,
		StateChangeDate, ActivatedDate, ActivatedBy, ResolvedDate, ResolvedBy, ClosedDate, ClosedBy, [Priority], StackRank, ValueArea, [Description], History, Tags, WorkflowSequence)
		VALUES(src.id, src.AreaPath, src.TeamProject, src.IterationPath, src.ItemType, src.[State], src.Reason, src.AssignedTo, src.CreatedDate, src.CreatedBy, src.ChangedDate, src.ChangedBy, 
		src.CommentCount, src.Title, src.BoardColumn, src.BoardColumnDone, src.StateChangeDate, src.ActivatedDate, src.ActivatedBy, src.ResolvedDate, src.ResolvedBy, src.ClosedDate, src.ClosedBy, 
		src.[Priority], src.StackRank, src.ValueArea, src.[Description], src.History, src.Tags, @seqval);


	
	DROP TABLE #WITWorkTable
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AddWorkItemColumnHistory]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AddWorkItemColumnHistory]
	@witJson nvarchar(max),
	@seqval as bigint
AS
BEGIN
	SET NOCOUNT ON;

	--The WHERE Clauses are the current format that is defined by Azure DevOps.  There will generally only be 2 results per WIT, however changes to the board columns (i.e. Deleting a column) 
	--can cause more than 2 values to appear.  The Boards API can be used to determine which WEF value is the correct one.
	SELECT 	a.id, b.[key], b.[value] INTO #Columns FROM OPENJSON(@witJson) WITH(
								id int,
								fields nvarchar(max) as JSON
							 ) a
					OUTER APPLY OPENJSON(a.fields) b
					WHERE B.[Key] like 'WEF_%_Kanban.Column'

   	SELECT 	a.id, b.[key], b.[value] INTO #ColumnDone FROM OPENJSON(@witJson) WITH(
								id int,
								fields nvarchar(max) as JSON
							 ) a
					OUTER APPLY OPENJSON(a.fields) b
					WHERE B.[Key] like 'WEF_%_Kanban.Column.Done'

	
	SELECT DISTINCT
		a.id as WitID,
		a.[key] as WefColumnID,
		a.[value] as CurrentColumn,
		ISNULL(b.[value], 0) as IsDone,
		@seqval as WorkflowSequence,
		GETDATE() as AuditCreateDate
	INTO #WITWorkTable
	FROM #Columns a
	LEFT JOIN #ColumnDone b on (a.id = b.id AND b.[key] = (a.[key] + '.Done'))

	DROP TABLE #Columns
	DROP TABLE #ColumnDone

	--INSERT only records that either don't exsit or have changed their Board Column values.
	--The intent of this table is to track changes to the board column values and not to restate the history of a WIT
	MERGE WorkItem_ColumnHistory AS trgt
	USING #WITWorkTable as src
	ON trgt.WitID = src.WitID AND trgt.CurrentColumn = src.CurrentColumn AND trgt.IsDone = src.IsDone
	WHEN NOT MATCHED THEN
		INSERT (WitID, WefColumnID, CurrentColumn, IsDone, WorkflowSequence, AuditCreatedDate)
		VALUES(src.WitID, src.WefColumnID, src.CurrentColumn, src.IsDone, src.WorkflowSequence, src.AuditCreateDate);


	DROP TABLE #WITWorkTable
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetLastRunTime]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetLastRunTime]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1 
		RunDate
	FROM SystemRuns
	WHERE IsLastRun = 1
	ORDER BY RunDate DESC

END
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateLastRunTime]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_UpdateLastRunTime]
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE SystemRuns SET IsLastRun = 0
	INSERT INTO SystemRuns (RunDate, IsLastRun) VALUES (GETDATE(), 1)
END
GO
/****** Object:  StoredProcedure [dbo].[wkflw_LoadWitData]    Script Date: 4/20/2022 10:46:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[wkflw_LoadWitData]
		@witJson as nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @seqval as bigint 
	
	SELECT NEXT VALUE FOR WitWorkflowSequence

	SELECT @seqval = CONVERT(bigint, current_value) FROM sys.sequences WHERE name = 'WitWorkflowSequence'

	EXEC usp_AddWorkItem @witJson, @seqval

	EXEC usp_AddWorkItemColumnHistory @witJson, @seqval

	EXEC usp_UpdateLastRunTime

END
GO
USE [master]
GO
ALTER DATABASE [ADOAnalysis] SET  READ_WRITE 
GO
