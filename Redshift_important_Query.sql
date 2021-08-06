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