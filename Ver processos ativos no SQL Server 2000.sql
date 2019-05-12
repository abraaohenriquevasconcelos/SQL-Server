/* 
Ver informações sobre os processos ativos no servidor no SQL Server 2000
*/

select
    P.spid
,   right(convert(varchar, 
            dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'), 
            121), 12) as 'batch_duration'
,   P.cmd            
,   P.program_name
,   P.hostname
,   P.loginame
,	P.blocked
,   P.waittype
,   P.*
from master.dbo.sysprocesses P
where P.spid > 50
and      P.status not in ('background'/*, 'sleeping'*/)
and      P.cmd not in ('AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER')
order by batch_duration desc




USE MASTER

Declare @handle as binary(20)

select @handle = sql_handle from sysprocesses where spid = '100'

select @handle

select * from ::fn_get_sql(@handle)