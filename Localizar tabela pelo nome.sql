

/* Procura em todos os objetos*/
select SCHEMA_NAME(schema_id) + '.' + name as table_view,
type, type_desc, create_date,  modify_date 
from sys.objects 
where type = 'U' and name like '%PersonPhone%'


select * from sys.tables where name like '%PersonPhone%' --Do próprio banco


/* Procura em todos os bancos */
EXEC sys.sp_msforeachdb  'SELECT ''?'' DatabaseName, Name FROM [?].sys.tables WHERE Name LIKE ''%PersonPhone%'''



--Procura tabela pelo nome da coluna dentro do banco de dados
SELECT
sys.tables.name AS 'Table Name', 
--OBJECT_NAME(sys.tables.object_id) AS 'Object ID', --TableName
sys.columns.name AS 'Column Name'
FROM sys.tables INNER JOIN sys.columns 
ON sys.tables.object_id = sys.columns.object_id
WHERE sys.columns.name LIKE '%PhoneNumber%'
ORDER BY 1;

