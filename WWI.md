
# WWI Install 

# Install SQL Server 

[download](https://learn.microsoft.com/en-us/sql/samples/wide-world-importers-oltp-install-configure?view=sql-server-ver16)


## creation / restore 

create

```
CREATE DATABASE WideWorldImporters
ON ( NAME = WideWorldImporters, FILENAME = 'W:\SQLDATA\WideWorldImporters.MDF' )
LOG ON ( NAME = WideWorldImporters_Log, FILENAME = 'W:\SQLDATA\WideWorldImporters_log.LDF' ) ;

```

restore 

```

```