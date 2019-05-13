/* 
List all table constraints (PK, UK, FK, Check & Default) in SQL Server database
*/


--sus.objects.object_id                  -> nesse contexto � o ID de uma tabela	
--sys.indexes.object_id                  -> ID do objeto ao qual este �ndice pertence (Tabela)
--sys.key_constraints.parent_object_id   -> ID do objeto ao qual este objeto pertence. (0 = N�o � um objeto filho.)
--sys.key_constraints.unique_index_id    -> ID do �ndice exclusivo correspondente no objeto pai que foi criado para impor esta restri��o.


/***Vers�o resumida****/
select schema_name(a.schema_id) + '.' + a.name as table_view,
case 
	when a.type = 'U' then 'Table'
	when a.type = 'V' then 'View'
end as object_type,
case
	when c.type  = 'PK' then 'Primary key'
	when c.type = 'UQ'  then 'Unique constraint'
	when b.type = 1     then 'Unique clustered index'
	when b.type = 2     then 'Unique index'
end as constraint_type,
isnull(c.name, b.name) as constraint_name
from sys.objects a left join sys.indexes b
on a.object_id = b.object_id
left outer join sys.key_constraints c 
on b.object_id = c.parent_object_id and b.index_id = c.unique_index_id
where is_unique = 1 --1 = O �ndice � exclusivo / 0 = O �ndice n�o � exclusivo.
and a.is_ms_shipped <> 1




/***Vers�o estendida****/
select table_view,
    object_type, 
    constraint_type,
    constraint_name,
    details
from (
    select schema_name(t.schema_id) + '.' + t.[name] as table_view, 
        case when t.[type] = 'U' then 'Table'
            when t.[type] = 'V' then 'View'
            end as [object_type],
        case when c.[type] = 'PK' then 'Primary key'
            when c.[type] = 'UQ' then 'Unique constraint'
            when i.[type] = 1 then 'Unique clustered index'
            when i.type = 2 then 'Unique index'
            end as constraint_type, 
        isnull(c.[name], i.[name]) as constraint_name,
        substring(column_names, 1, len(column_names)-1) as [details]
    from sys.objects t
        left outer join sys.indexes i
            on t.object_id = i.object_id
        left outer join sys.key_constraints c
            on i.object_id = c.parent_object_id 
            and i.index_id = c.unique_index_id
       cross apply (select col.[name] + ', '
                        from sys.index_columns ic
                            inner join sys.columns col
                                on ic.object_id = col.object_id
                                and ic.column_id = col.column_id
                        where ic.object_id = t.object_id
                            and ic.index_id = i.index_id
                                order by col.column_id
                                for xml path ('') ) D (column_names)
    where is_unique = 1
    and t.is_ms_shipped <> 1
    union all 
    select schema_name(fk_tab.schema_id) + '.' + fk_tab.name as foreign_table,
        'Table',
        'Foreign key',
        fk.name as fk_constraint_name,
        schema_name(pk_tab.schema_id) + '.' + pk_tab.name
    from sys.foreign_keys fk
        inner join sys.tables fk_tab
            on fk_tab.object_id = fk.parent_object_id
        inner join sys.tables pk_tab
            on pk_tab.object_id = fk.referenced_object_id
        inner join sys.foreign_key_columns fk_cols
            on fk_cols.constraint_object_id = fk.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Check constraint',
        con.[name] as constraint_name,
        con.[definition]
    from sys.check_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id
    union all
    select schema_name(t.schema_id) + '.' + t.[name],
        'Table',
        'Default constraint',
        con.[name],
        col.[name] + ' = ' + con.[definition]
    from sys.default_constraints con
        left outer join sys.objects t
            on con.parent_object_id = t.object_id
        left outer join sys.all_columns col
            on con.parent_column_id = col.column_id
            and con.parent_object_id = col.object_id) a
order by table_view, constraint_type, constraint_name



