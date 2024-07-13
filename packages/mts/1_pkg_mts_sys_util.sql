create or replace package pkg_mts_sys_util
as
    procedure deploy_mts_sys_trigger;
    procedure drop_mts_sys_trigger;

end ;
/

create or replace package body pkg_mts_sys_util
as
    procedure deploy_mts_sys_trigger
    is
        pl_query        varchar2(30000);
        pl_new_line     char(1)     := chr(10);
        pl_quote        char(1)     := chr(39);
        pl_tab          char(1)     := chr(9);
        cursor c1 is
            select  distinct lower(t.table_name) table_name
            from    user_tables t 
            join    user_tab_columns c on c.table_name = t.table_name 
            where   t.table_name like '%MTS%'
            and     c.column_name like '%UPDATE_DATE%' ;
    begin

        pl_query := '';
        for c1rec in c1 LOOP
            pl_query := '';
            pl_query := pl_query || 'create or replace editionable trigger trg_sys_' || c1rec.table_name || pl_new_line;
            pl_query := pl_query || 'before update on ' || c1rec.table_name ||  pl_new_line;
            pl_query := pl_query || 'for each row' ||  pl_new_line;
            pl_query := pl_query || 'begin' ||  pl_new_line;
            pl_query := pl_query || pl_tab || 'if inserting then' ||  pl_new_line;
            pl_query := pl_query || pl_tab || pl_tab || ':new.create_date := current_timestamp;' ||  pl_new_line;
            pl_query := pl_query || pl_tab || pl_tab || ':new.created_by := coalesce(sys_context(' || pl_quote || 'apex$session' || pl_quote || ',' || pl_quote || 'g_login_id' || pl_quote || '),user);'|| pl_new_line;
            pl_query := pl_query || pl_tab || 'elsif updating then' ||  pl_new_line;
            pl_query := pl_query || pl_tab || pl_tab || ':new.update_date := current_timestamp;' ||  pl_new_line;
            pl_query := pl_query || pl_tab || pl_tab || ':new.updated_by := coalesce(sys_context(' || pl_quote || 'apex$session' || pl_quote || ',' || pl_quote || 'g_login_id' || pl_quote || '),user);'|| pl_new_line;
            pl_query := pl_query || pl_tab || 'end if;' ||  pl_new_line;

            pl_query := pl_query || 'end trg_sys_' || c1rec.table_name || ';' ||  pl_new_line;
            --pl_query := pl_query || '/' || pl_new_line;

            execute immediate pl_query;

            --pl_query := 'ALTER TRIGGER ' || 'trg_sys_' || c1rec.table_name || 'COMPILE ; ';
            --execute immediate pl_query;

        end loop;
    end deploy_mts_sys_trigger;

    procedure drop_mts_sys_trigger
    is
        pl_query        varchar2(30000);
        pl_new_line     char(1)     := chr(10);
        pl_quote        char(1)     := chr(39);
        pl_tab          char(1)     := chr(9);
        cursor c1 is
            select  distinct lower(t.table_name) table_name
            from    user_tables t 
            join    user_tab_columns c on c.table_name = t.table_name 
            where   t.table_name like '%MTS%'
            and     c.column_name like '%UPDATE_DATE%' ;
    begin

        pl_query := '';
        for c1rec in c1 LOOP
            pl_query := '';
            pl_query := pl_query || 'drop trigger trg_sys_' || c1rec.table_name  || ' ' || pl_new_line;
            --pl_query := pl_query || '/' || pl_new_line;
            dbms_output.put_line (pl_query);
            execute immediate pl_query;

        end loop;
    end drop_mts_sys_trigger;

end;
/