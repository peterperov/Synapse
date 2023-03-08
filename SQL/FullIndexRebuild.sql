
use WideWorldImporters
go


SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON

DECLARE @TableName varchar(255);
DECLARE @IndexName varchar(255);
DECLARE @Fragmentation FLOAT;
DECLARE @IndexScript varchar(255);
DECLARE @StatScript varchar(255);


DECLARE TableCursor CURSOR FOR  
    SELECT 
        dbschemas.[name] + '.' + dbtables.[name], 
        dbindexes.[name],
        indexstats.avg_fragmentation_in_percent 
    FROM 
        sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
        INNER JOIN sys.tables dbtables 
            on dbtables.[object_id] = indexstats.[object_id]
        INNER JOIN sys.schemas dbschemas 
            on dbtables.[schema_id] = dbschemas.[schema_id]
        INNER JOIN sys.indexes AS dbindexes 
            ON dbindexes.[object_id] = indexstats.[object_id]
            AND indexstats.index_id = dbindexes.index_id
    WHERE 
        indexstats.database_id = DB_ID()
        AND indexstats.avg_fragmentation_in_percent >= 5.0
        AND indexstats.page_count > 10
    ORDER BY 
        indexstats.page_count ASC,
        indexstats.avg_fragmentation_in_percent ASC;

OPEN TableCursor

FETCH NEXT FROM TableCursor INTO
    @TableName,
    @IndexName,
    @Fragmentation
 
WHILE @@FETCH_STATUS = 0 
 
BEGIN 
    IF (@Fragmentation >= 30.0)
        SET @IndexScript = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' REBUILD';
    ELSE IF (@Fragmentation >= 5.0)
        SET @IndexScript = 'ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' REORGANIZE';
    ELSE
        SET @IndexScript = NULL;

    IF (@IndexScript IS NOT NULL)
    BEGIN
        RAISERROR (@IndexScript, 10, 0) WITH NOWAIT

        WAITFOR DELAY '00:00:01';

        EXEC(@IndexScript); 

        -- update statistics tblHourlyData with fullscan; 

        SET @StatScript = 'UPDATE STATISTICS ' + @TableName + ' WITH FULLSCAN';
        RAISERROR (@StatScript, 10, 0) WITH NOWAIT

        EXEC(@StatScript); 

    END

    FETCH NEXT FROM TableCursor INTO
        @TableName,
        @IndexName,
        @Fragmentation;
 
END 
 
CLOSE TableCursor;
 
DEALLOCATE TableCursor;