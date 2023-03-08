
# WWI Install 

# Install SQL Server 

[download](https://learn.microsoft.com/en-us/sql/samples/wide-world-importers-oltp-install-configure?view=sql-server-ver16)


## creation / restore 

Note: scripts do not work as there are multiple databases, use Database -> Restore in SSMS. 

Scripts are here just for reference. 

```
CREATE DATABASE WideWorldImporters
ON ( NAME = WideWorldImporters, FILENAME = 'W:\SQLDATA\WideWorldImporters.MDF' )
LOG ON ( NAME = WideWorldImporters_Log, FILENAME = 'W:\SQLDATA\WideWorldImporters_log.LDF' ) ;

```

restore 

```

USE [master]

RESTORE DATABASE [WideWorldImporters] 
FROM  DISK = N'W:\pub\SampleDBs\WideWorldImporters-Full.bak' WITH  FILE = 1,  
    MOVE N'WWI_Primary' TO N'W:\SQLDATA\WideWorldImporters.mdf',  
    MOVE N'WWI_UserData' TO N'W:\SQLDATA\WideWorldImporters_UserData.ndf',  
    MOVE N'WWI_Log' TO N'W:\SQLDATA\WideWorldImporters.ldf',  
    MOVE N'WWI_InMemory_Data_1' TO N'W:\SQLDATA\WideWorldImporters_InMemory_Data_1',  
NOUNLOAD,  STATS = 5

GO

```

## Generate new data 

To improve the data generation script 

```
ALTER DATABASE WideWorldImporters SET DELAYED_DURABILITY =  FORCED 
```

[Documentation link](https://learn.microsoft.com/en-us/sql/samples/wide-world-importers-generate-data?view=sql-server-ver16)

Restored data is up to 2016. We need to generate data till current date

```
use WideWorldImporters
go

select Max(invoiceDate) from Sales.Invoices 
```

2016-05-31

To generate new data use 

```
use WideWorldImporters
go

EXECUTE DataLoadSimulation.PopulateDataToCurrentDate
    @AverageNumberOfCustomerOrdersPerDay = 60,
    @SaturdayPercentageOfNormalWorkDay = 50,
    @SundayPercentageOfNormalWorkDay = 0,
    @IsSilentMode = 0,
    @AreDatesPrinted = 1;
GO 
```

This might take a while... Really long white. Nearly 4 mins per day. For mode detailed analysis see [Performance Improvments](PerformanceImprovement.md). 


View the number of invoice lines per day generated: 

```
select I.InvoiceDate
	, Count(IL.InvoiceID) as LinesPerDay 
FROM Sales.Invoices I 
inner join Sales.InvoiceLines IL on I.InvoiceID = IL.InvoiceID
group by I.InvoiceDate
order by 1 desc 
```

## Bring data to DW database

[link](https://learn.microsoft.com/en-us/sql/samples/wide-world-importers-generate-data?view=sql-server-ver16#import-generated-data-in-wideworldimportersdw)

to bring new data to DWH use

### Reseed DWH 

```
use WideWorldImportersDW
go 

EXECUTE [Application].Configuration_ReseedETL

```

### ETL data 

Download SSIS scripts from [here](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0)



# Install Synapse 

Will need to bring data from SQL DWH to Synapse via Polybase

[Tutorial: Load data to Azure Synapse Analytics SQL pool](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/load-data-wideworldimportersdw)


# 