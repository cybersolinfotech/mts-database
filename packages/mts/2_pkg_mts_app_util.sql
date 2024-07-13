/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_app_util as

        MESSAGE         CONSTANT NUMBER := 10;
        INFO            CONSTANT NUMBER := 20;
        WARNING         CONSTANT NUMBER := 30;
        ERROR           CONSTANT NUMBER := 9999;

        --------------------------------------------------------------------------------------
        --    APP_CNTRL
        --------------------------------------------------------------------------------------
        procedure set_app_cntrl(
                p_app_cntrl_id          in out mts_app_cntrl.id%type,
                p_name                  mts_app_cntrl.name%type         default null,
                p_description           mts_app_cntrl.description%type  default null,
                p_active                mts_app_cntrl.active%type       default 1 );

        procedure delete_app_cntrl(  p_app_cntrl_id   mts_app_cntrl.id%type  );

        function get_app_cntrl_id( p_name  mts_app_cntrl.name%type) return mts_app_cntrl.id%type;

        --------------------------------------------------------------------------------------
        --    APP_CNTRL_VALUE
        --------------------------------------------------------------------------------------
        procedure set_app_cntrl_value(
                p_app_cntrl_value_id    in out mts_app_cntrl_value.id%type ,
                p_app_cntrl_id          mts_app_cntrl_value.app_cntrl_id%type,
                p_key                   mts_app_cntrl_value.key%type,
                p_str_value             mts_app_cntrl_value.str_value%type              default null,
                p_timestamp_value       mts_app_cntrl_value.timestamp_value%type        default null, 
                p_number_value          mts_app_cntrl_value.number_value%type           default null,
                p_active                mts_app_cntrl_value.active%type                 default 1) ;    

        procedure delete_app_cntrl_value(  p_app_cntrl_value_id   mts_app_cntrl_value.id%type  );        

        function get_app_cntrl_str_value( 
                p_app_cntrl_name        mts_app_cntrl.name%type,
                p_key                   mts_app_cntrl_value.key%type) return mts_app_cntrl_value.str_value%type;

        function get_app_cntrl_timestamp_value( 
                p_app_cntrl_name        mts_app_cntrl.name%type,
                p_key                   mts_app_cntrl_value.key%type) return mts_app_cntrl_value.timestamp_value%type;

        function get_app_cntrl_number_value( 
                p_app_cntrl_name        mts_app_cntrl.name%type,
                p_key                   mts_app_cntrl_value.key%type) return mts_app_cntrl_value.number_value%type;



        --------------------------------------------------------------------------------------
        --    APP_PROCESS_LOG
        --------------------------------------------------------------------------------------
        PROCEDURE LOG_MESSAGE (
                P_PACKAGE_NAME	MTS_APP_PROCESS_LOG.PACKAGE_NAME%TYPE DEFAULT NULL,
                P_PROCESS_NAME	MTS_APP_PROCESS_LOG.PROCESS_NAME%TYPE  DEFAULT NULL,
                p_LOG_TYPE      CHAR DEFAULT 'E',
                P_MSG_STR 	MTS_APP_PROCESS_LOG.MSG_STR%TYPE  DEFAULT NULL,
                p_MSG_CLOB	MTS_APP_PROCESS_LOG.MSG_CLOB%TYPE  DEFAULT NULL);

        

                
end pkg_mts_app_util;
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_app_util as
 
        --------------------------------------------------------------------------------------
        --    APP_CNTRL
        --------------------------------------------------------------------------------------
        -- procedure => set_app_cntrl
        procedure set_app_cntrl (
                        p_app_cntrl_id          in out mts_app_cntrl.id%type ,
                        p_name                  mts_app_cntrl.name%type default null,
                        p_description           mts_app_cntrl.description%type  default null,
                        p_active                mts_app_cntrl.active%type       default 1 )
        is
        begin
                update  mts_app_cntrl
                set     name = nvl(p_name,name),
                        description = nvl(p_description,description),
                        active = nvl(p_active,active)
                where   id = p_app_cntrl_id; 

                if sql%rowcount = 0 then 
                        insert into mts_app_cntrl ( name, description, active)
                        values (p_name, p_description, p_active) returning id into p_app_cntrl_id;
                end if;

        end set_app_cntrl;

        -- procedure => delete_app_cntrl
        procedure delete_app_cntrl(  p_app_cntrl_id   mts_app_cntrl.id%type  )
        is      
        begin

            delete from mts_app_cntrl where id = p_app_cntrl_id;

        end delete_app_cntrl;

        

        -- function => get_app_cntrl_id
        function get_app_cntrl_id( p_name  mts_app_cntrl.name%type) return mts_app_cntrl.id%type
        is
                l_app_cntrl_id  mts_app_cntrl.id%type;
        begin
                
                select  id 
                into    l_app_cntrl_id
                from    mts_app_cntrl
                where   lower(name) = lower(p_name);

                return l_app_cntrl_id;
        exception
                when no_data_found then
                        return null;
        end get_app_cntrl_id;


        --------------------------------------------------------------------------------------
        --    APP_CNTRL_VALUE
        --------------------------------------------------------------------------------------
        -- procedure => set_app_cntrl_value
        procedure set_app_cntrl_value(
                p_app_cntrl_value_id    in out mts_app_cntrl_value.id%type ,
                p_app_cntrl_id          mts_app_cntrl_value.app_cntrl_id%type,
                p_key                   mts_app_cntrl_value.key%type,
                p_str_value             mts_app_cntrl_value.str_value%type              default null,
                p_timestamp_value       mts_app_cntrl_value.timestamp_value%type        default null, 
                p_number_value          mts_app_cntrl_value.number_value%type           default null,
                p_active                mts_app_cntrl_value.active%type                 default 1)                
        is
        begin
                update mts_app_cntrl_value
                set     str_value = nvl(p_str_value, str_value),
                        timestamp_value = nvl(p_timestamp_value, timestamp_value),
                        number_value = nvl(p_number_value, number_value),
                        active = nvl(p_active,active)
                where   app_cntrl_id = p_app_cntrl_id
                and     key = p_key;       

                if sql%rowcount = 0 then
                        insert into mts_app_cntrl_value ( app_cntrl_id, key, str_value, timestamp_value, number_value, active)
                        values (p_app_cntrl_id, p_key, p_str_value, p_timestamp_value, p_number_value, p_active) returning id into p_app_cntrl_value_id;
                end if;

        end set_app_cntrl_value;


        -- procedure => delete_app_cntrl_value
        procedure delete_app_cntrl_value(  p_app_cntrl_value_id   mts_app_cntrl_value.id%type  )
        is
        begin
                delete from mts_app_cntrl_value
                where id = p_app_cntrl_value_id;  

        end delete_app_cntrl_value;
        

        -- function => get_app_cntrl_str_value
        function get_app_cntrl_str_value( 
                p_app_cntrl_name        mts_app_cntrl.name%type,
                p_key                   mts_app_cntrl_value.key%type) return mts_app_cntrl_value.str_value%type
        is
                l_str_value     mts_app_cntrl_value.str_value%type;
        begin
                select  str_value
                into    l_str_value
                from    mts_app_cntrl_value cv
                join    mts_app_cntrl c on c.id = cv.app_cntrl_id
                where   lower(c.name) = lower(p_app_cntrl_name)
                and     lower(cv.key) = lower(p_key);

                return l_str_value;
        exception 
                when no_data_found then
                        return null;
        end get_app_cntrl_str_value;


        -- function => get_app_cntrl_timestamp_value
        function get_app_cntrl_timestamp_value( 
                p_app_cntrl_name        mts_app_cntrl.name%type,
                p_key                   mts_app_cntrl_value.key%type) return mts_app_cntrl_value.timestamp_value%type
        is
                l_timestamp_value       mts_app_cntrl_value.timestamp_value%type;
        begin
                select str_value
                into    l_timestamp_value
                from    mts_app_cntrl_value cv
                join    mts_app_cntrl c on c.id = cv.app_cntrl_id
                where   lower(c.name) = lower(p_app_cntrl_name)
                and     lower(cv.key) = lower(p_key);

                return l_timestamp_value;
        exception 
                when no_data_found then
                        return null;
        end get_app_cntrl_timestamp_value;


        -- function => get_app_cntrl_number_value
        function get_app_cntrl_number_value( 
                p_app_cntrl_name        mts_app_cntrl.name%type,
                p_key                   mts_app_cntrl_value.key%type) return mts_app_cntrl_value.number_value%type
        is
                l_number_value       mts_app_cntrl_value.number_value%type;
        begin
                select  number_value
                into    l_number_value
                from    mts_app_cntrl_value cv
                join    mts_app_cntrl c on c.id = cv.app_cntrl_id
                where   lower(c.name) = lower(p_app_cntrl_name)
                and     lower(cv.key) = lower(p_key);

                return l_number_value;
        exception 
                when no_data_found then
                        return null;
        end get_app_cntrl_number_value;

        

        -- procedure => LOG_MESSAGE
        PROCEDURE LOG_MESSAGE (
                P_PACKAGE_NAME	MTS_APP_PROCESS_LOG.PACKAGE_NAME%TYPE DEFAULT NULL,
                P_PROCESS_NAME	MTS_APP_PROCESS_LOG.PROCESS_NAME%TYPE  DEFAULT NULL,
                p_LOG_TYPE      CHAR DEFAULT 'E',
                P_MSG_STR 	MTS_APP_PROCESS_LOG.MSG_STR%TYPE  DEFAULT NULL,
                p_MSG_CLOB	MTS_APP_PROCESS_LOG.MSG_CLOB%TYPE  DEFAULT NULL)
                                
        AS
                PL_LOG_MSG          char(1);
        
        BEGIN
                PL_LOG_MSG := get_app_cntrl_str_value( 
                                                        p_app_cntrl_name => 'MTS_APP_CONFIG',
                                                        p_key => 'LOG_MSG');

                IF ( P_LOG_TYPE = 'E' OR PL_LOG_MSG = 'Y' ) then
                        INSERT INTO MTS_APP_PROCESS_LOG (PACKAGE_NAME, PROCESS_NAME, MSG_STR, MSG_CLOB)                
                        VALUES (P_PACKAGE_NAME, P_PROCESS_NAME,  P_MSG_STR, p_MSG_CLOB);   

                        COMMIT;  
                END IF;

                

        END LOG_MESSAGE; 


end pkg_mts_app_util;
/