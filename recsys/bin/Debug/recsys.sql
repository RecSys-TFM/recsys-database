﻿/*
Deployment script for recsys

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "recsys"
:setvar DefaultFilePrefix "recsys"
:setvar DefaultDataPath "C:\Users\smmanrrique\AppData\Local\Microsoft\VisualStudio\SSDT\recsys"
:setvar DefaultLogPath "C:\Users\smmanrrique\AppData\Local\Microsoft\VisualStudio\SSDT\recsys"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE,
                DISABLE_BROKER 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'Creating Table [dbo].[Client]...';


GO
CREATE TABLE [dbo].[Client] (
    [ClientId]         INT           IDENTITY (1, 1) NOT NULL,
    [Company]          VARCHAR (40)  NOT NULL,
    [Email]            VARCHAR (320) NOT NULL,
    [Phone]            VARCHAR (50)  NULL,
    [RegistrationDate] DATETIME2 (7) NULL,
    [Status]           BIT           NULL,
    CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED ([ClientId] ASC)
);


GO
PRINT N'Creating Table [dbo].[Service]...';


GO
CREATE TABLE [dbo].[Service] (
    [ServiceId] INT             NOT NULL,
    [Name]      VARCHAR (40)    NULL,
    [Detail]    VARCHAR (1000)  NULL,
    [Pricing]   DECIMAL (10, 2) NULL,
    CONSTRAINT [PK_Service] PRIMARY KEY CLUSTERED ([ServiceId] ASC)
);


GO
PRINT N'Creating Table [dbo].[ServiceOrder]...';


GO
CREATE TABLE [dbo].[ServiceOrder] (
    [ServiceOrderId] INT             NOT NULL,
    [ClientId]       INT             NULL,
    [ServiceId]      INT             NULL,
    [PurchaseDate]   DATETIME2 (7)   NULL,
    [AmountPaid]     DECIMAL (10, 2) NULL,
    [Validity]       DATETIME2 (7)   NULL,
    CONSTRAINT [PK_ServiceOrder] PRIMARY KEY CLUSTERED ([ServiceOrderId] ASC)
);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ServiceOrder_Client]...';


GO
ALTER TABLE [dbo].[ServiceOrder] WITH NOCHECK
    ADD CONSTRAINT [FK_ServiceOrder_Client] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ServiceOrder_ToTable]...';


GO
ALTER TABLE [dbo].[ServiceOrder] WITH NOCHECK
    ADD CONSTRAINT [FK_ServiceOrder_ToTable] FOREIGN KEY ([ServiceId]) REFERENCES [dbo].[Service] ([ServiceId]);


GO
PRINT N'Creating Procedure [dbo].[AddClient]...';


GO
CREATE PROCEDURE [dbo].[AddClient] 
   @Company VARCHAR(40) , 
   @Email VARCHAR(320) , 
   @Phone VARCHAR(50) , 
   @RegistrationDate DATETIME2, 
   @Status bit -- 1 active, 0 closed 
AS 
SET NOCOUNT ON 
INSERT INTO dbo.Client 
(Company,Email,Phone,RegistrationDate,Status) 
VALUES 
(@Company,@Email,@Phone,@RegistrationDate,@Status) 
RETURN 0;
GO
PRINT N'Creating Procedure [dbo].[AddService]...';


GO
CREATE PROCEDURE [dbo].[AddService] 
   @Name VARCHAR(40), 
   @Detail VARCHAR(1000), 
   @Pricing DECIMAL(10,2) 
AS 
INSERT INTO Service 
(Name,Detail,Pricing) 
VALUES 
(@Name,@Detail,@Pricing) 
RETURN 0;
GO
PRINT N'Creating Procedure [dbo].[PurchaseService]...';


GO
CREATE PROCEDURE [dbo].[PurchaseService] 
   @ClientId INT, 
   @ServiceId INT, 
   @PurchaseDate DATETIME2, 
   @AmountPaid DECIMAL (10,2), 
   @Validity DATETIME2 
AS 
INSERT INTO ServiceOrder 
(ClientId,ServiceId,PurchaseDate,AmountPaid,Validity) 
VALUES 
(@ClientId,@ServiceId,@PurchaseDate,@AmountPaid,@Validity) 
RETURN 0;
GO
PRINT N'Creating Procedure [dbo].[RemoveClient]...';


GO
CREATE PROCEDURE [dbo].[RemoveClient] 
    @ClientId INT 
AS 
DELETE FROM dbo.Client WHERE ClientId=@ClientId 
RETURN 0;
GO
PRINT N'Creating Procedure [dbo].[RemoveService]...';


GO
CREATE PROCEDURE [dbo].[RemoveService] 
@ServiceId INT 
AS 
DELETE FROM Service WHERE 
ServiceId=@ServiceId 
RETURN 0;
GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[ServiceOrder] WITH CHECK CHECK CONSTRAINT [FK_ServiceOrder_Client];

ALTER TABLE [dbo].[ServiceOrder] WITH CHECK CHECK CONSTRAINT [FK_ServiceOrder_ToTable];


GO
PRINT N'Update complete.';


GO
