/***********************************************************/
dbcc checkdb(minervaGeo) with all_errormsgs, no_infomsgs
/***********************************************************/



/***********************************************************/
--Table error: Object ID 13959126, index ID 2, partition ID 563864778702848
select  * from sys.objects where object_id = 13959126
/***********************************************************/

/***********************************************************/
--Mostra todos os índices de uma tabela
SELECT 
		DB_NAME(DB_ID()),
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 AND
     t.name = 'vendas'
ORDER BY 
     t.name, ind.name, ind.index_id, ic.index_column_id
	 /***********************************************************/


/***********************************************************/
ALTER INDEX IX_vendedor ON vendas REBUILD
/***********************************************************/