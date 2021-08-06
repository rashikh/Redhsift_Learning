---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Redshift Important Queries
------------------------------------------------------------------------------------------------------------------------------------------------------------

Query to determine what queries are currently running against the database:

select user_name, db_name, pid, query
from stv_recents
where status = 'Running';
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Query to joins STL_LOAD_ERRORS to STL_LOADERROR_DETAIL to view the details errors that occurred during the most recent load.

select d.query, substring(d.filename,14,20), 
d.line_number as line, 
substring(d.value,1,16) as value,
substring(le.err_reason,1,48) as err_reason
from stl_loaderror_detail d, stl_load_errors le
where d.query = le.query
and d.query = pg_last_copy_id(); 
--------------------------------------------------------------------------------------------------------------------------------------------
 Statement to terminates the session holding the locks:

select pg_terminate_backend(8585); 
---------------------------------------------------------------------------------------------------------------------------------
To find session ID (process)
First we will identify the session we want to end. We do it by listing all sessions on the server with this query:

select * from stv_sessions;
------------------------------------------------------------------------------------------------------
In Order to Kill the session we will use process ID (process) to kill the session (323 in our example):

select pg_terminate_backend(323);
--------------------------------------------------------
How to concatenate two different column of the two different tables in Redshift

(Tab1.column_tab1 + '(' + tab2.column_tab2 + ')') as combine_column_name
----------------------------------------------------------------------------------------
Finding and Killing Sessions in Amazon Redshift
The first step in killing a session in an Amazon Redshift database is to find the session to kill. Please be sure to connect to Redshift as a user that has the privileges necessary to run queries to find sessions and execute commands to kill sessions. To find the currently active sessions in Redshift, execute the following query:


SELECT
	procpid,
	datname,
	usename,
	current_query,
	query_start
FROM
	pg_catalog.pg_stat_activity;
				
The above query will return the running sessions. After determining which session to kill, get the pid from the above query results and execute the following command to kill the session. The below example assumes the id is 9556:


SELECT pg_terminate_backend(9556);

---------------------------------------------------------------------------------------------------------------------
/* show running queries */
select pid, user_name, starttime, query
from stv_recents
where lower(status) = 'running';

/* show recent completed queries */
select pid, user_name, starttime, query
from stv_recents
where lower(status) = 'done'
order by starttime desc;

/* table rows by schema */
select
    trim(pgdb.datname) as Database,
    trim(pgn.nspname) as Schema,
    trim(a.name) as Table,
    b.mbytes,
    a.rows
from (
    select db_id, id, name, sum(rows) as rows
    from stv_tbl_perm a
    group by db_id, id, name
) as a
join pg_class as pgc on pgc.oid = a.id
join pg_namespace as pgn on pgn.oid = pgc.relnamespace
join pg_database as pgdb on pgdb.oid = a.db_id
join (
    select tbl, count(*) as mbytes
    from stv_blocklist
    group by tbl
) b on a.id = b.tbl
where trim(pgn.nspname) = 'sat'
order by  mbytes desc, a.db_id, a.name; 

/* view dependencies for a table and/or schema */
SELECT *
FROM vault_xero.dvs.vwdependencies 
where schemaname = 'tempstage'

/* view table columns and datatypes */
select distinct attrelid, rtrim(name), attname, typname
from pg_attribute a, pg_type t, stv_tbl_perm p
where t.oid=a.atttypid and a.attrelid=p.id
and a.attrelid between 100100 and 110000
and typname not in('oid','xid','tid','cid')
order by a.attrelid asc, typname, attname;

/* view vacuum progress/summary */
select * from svv_vacuum_progress;
select * from svv_vacuum_summary;

/* view sort key(s) for table */
select * from svv_table_info;

/* Use the SET command to set the value of wlm_query_slot_count for the duration of the current session. */
set wlm_query_slot_count to 3; 
-------------------------------------------------------------------------------------------------------------------------
Query below returns a list of all columns in a specific table in Amazon Redshift database.
select ordinal_position as position,
       column_name,
       data_type,
       case when character_maximum_length is not null
            then character_maximum_length
            else numeric_precision end as max_length,
       is_nullable,
       column_default as default_value
from information_schema.columns
where table_name = '' -- enter table name here
      -- and table_schema = 'Schema name'
order by ordinal_position;
---------------------------------------------------------------------------------------------------
Find tables with specific column name in Redshift
select t.table_schema,
       t.table_name
from information_schema.tables t
inner join information_schema.columns c 
           on c.table_name = t.table_name 
           and c.table_schema = t.table_schema
where c.column_name = 'region'
      and t.table_schema not in ('information_schema', 'pg_catalog')
      and t.table_type = 'BASE TABLE'
order by t.table_schema;
--------------------------------------------------------------------------------------------------------------
select * from information_schema.view_table_usage where table_schema='' and table_name='';
---------------------------------------------------------------------------------------------------------
