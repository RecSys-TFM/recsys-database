CREATE TABLE [dbo].[Service] 
( 
   [ServiceId] INT NOT NULL, 
   [Name] VARCHAR(40), 
   [Detail] VARCHAR(1000), 
   [Pricing] DECIMAL(10,2), 
   CONSTRAINT [PK_Service] PRIMARY KEY ([ServiceId]) 
);