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
        --    API_VENDOR
        --------------------------------------------------------------------------------------
        function get_api_token_interval ( p_vendor_code mts_api_vendor.vendor_code%type ) 
        return mts_api_vendor.token_interval%type;

        procedure set_api_vendor (
                p_vendor_code                   mts_api_vendor.vendor_code%type ,
                p_vendor_name                   mts_api_vendor.vendor_name%type         ,
                p_token_interval                mts_api_vendor.token_interval%type      default 1440,
                p_active                        mts_api_vendor.active%type              default 1 );

                
        procedure delete_api_vendor( p_vendor_code     mts_api_vendor.vendor_code%type  );

        --------------------------------------------------------------------------------------
        --    API_VENDOR_TOKEN
        --------------------------------------------------------------------------------------
        function get_api_token( p_user_id                       mts_api_vendor_token.user_id%type,
                                p_vendor_code                   mts_api_vendor.vendor_code%type )
        return  mts_api_vendor_token.token%type ;

        procedure set_api_vendor_token (
                        p_user_id                       mts_api_vendor_token.user_id%type,
                        p_vendor_code                   mts_api_vendor.vendor_code%type ,
                        p_token				mts_api_vendor_token.token%type ,
                        p_issued_at 			timestamp default current_timestamp );

        procedure purge_api_vendor_token;

        --------------------------------------------------------------------------------------
        --    APP_PROCESS_LOG
        --------------------------------------------------------------------------------------
        PROCEDURE LOG_MESSAGE (
                                P_PACKAGE_NAME	MTS_APP_PROCESS_LOG.PACKAGE_NAME%TYPE DEFAULT NULL,
	                        P_PROCESS_NAME	MTS_APP_PROCESS_LOG.PROCESS_NAME%TYPE  DEFAULT NULL,
	                        P_LOG_LEVEL	MTS_APP_PROCESS_LOG.LOG_LEVEL%TYPE  DEFAULT 9999,
	                        P_LOG_MSG 	MTS_APP_PROCESS_LOG.LOG_MSG%TYPE  DEFAULT NULL,
	                        P_LOG_CLOB	MTS_APP_PROCESS_LOG.LOG_CLOB%TYPE  DEFAULT NULL);

        

                
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
                where   id = nvl(p_app_cntrl_id,0); 

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

        --------------------------------------------------------------------------------------
        --    API_VENDOR
        --------------------------------------------------------------------------------------

        -- function => get_api_token_interval
        function get_api_token_interval ( p_vendor_code mts_api_vendor.vendor_code%type ) 
        return mts_api_vendor.token_interval%type
        as
                pl_token_interval       number;
        begin
                begin
                        select  nvl(token_interval,0) into pl_token_interval
                        from    mts_api_vendor
                        where   vendor_code =   p_vendor_code;
                exception
                        when no_data_found then
                                pl_token_interval := 0; 
                end;

                return pl_token_interval;
        end;

        -- procedure => set_api_vendor
        procedure set_api_vendor (
                p_vendor_code                   mts_api_vendor.vendor_code%type ,
                p_vendor_name                   mts_api_vendor.vendor_name%type         ,
                p_token_interval                mts_api_vendor.token_interval%type      default 1440,
                p_active                        mts_api_vendor.active%type              default 1 )
        as
        begin

                update mts_api_vendor
                set     
                        vendor_name = nvl(p_vendor_name,vendor_name),
                        token_interval = nvl(p_token_interval,token_interval),
                        active = nvl(p_active,active)
                where   vendor_code = p_vendor_code ;  

                if sql%rowcount = 0 then
                        insert into mts_api_vendor (vendor_code,vendor_name,token_interval,active)
                        values (p_vendor_code,p_vendor_name,p_token_interval,p_active);
                end if;     


        end set_api_vendor;

        -- procedure => delete_api_vendor       
        procedure delete_api_vendor( p_vendor_code     mts_api_vendor.vendor_code%type  )
        as
        begin
                raise_application_error(-20000, 'delete_api_vendor:' || 'method not implemented.', true);
        
        end delete_api_vendor;

        --------------------------------------------------------------------------------------
        --    API_VENDOR_TOKEN
        --------------------------------------------------------------------------------------

        -- function => get_api_token  
        function get_api_token( p_user_id                       mts_api_vendor_token.user_id%type,
                                p_vendor_code                   mts_api_vendor.vendor_code%type )
        return  mts_api_vendor_token.token%type 
        as
                pl_token      mts_api_vendor_token.token%type ;  
        begin
                --return token only if it is valid
                begin
                        select  token
                        into    pl_token
                        from    mts_api_vendor_token
                        where   user_id = p_user_id
                        and     vendor_code = p_vendor_code
                        and     current_timestamp < expire_at;

                exception
                        when no_data_found then
                                pl_token := null;           
                end;

                return pl_token;
        end ;

        -- procedure => set_api_vendor_token
        procedure set_api_vendor_token (
                        p_user_id                       mts_api_vendor_token.user_id%type,
                        p_vendor_code                   mts_api_vendor.vendor_code%type ,
                        p_token				mts_api_vendor_token.token%type ,
                        p_issued_at 			timestamp default current_timestamp  )
        as
                
                pl_expire_at            timestamp;    
        begin

                pl_expire_at := p_issued_at + numtodsinterval(get_api_token_interval(p_vendor_code => p_vendor_code), 'minute');

                update mts_api_vendor_token
                set     
                        token = p_token,
                        issued_at = p_issued_at,
                        expire_at = pl_expire_at
                where   user_id = p_user_id
                and     vendor_code = p_vendor_code ;  

                if sql%rowcount = 0 then
                        insert into mts_api_vendor_token (user_id, vendor_code, token, issued_at, expire_at)
                        values (p_user_id, p_vendor_code, p_token, p_issued_at, pl_expire_at );
                end if;           


        end set_api_vendor_token;                

        -- procedure => purge_api_vendor_token
        procedure purge_api_vendor_token
        as
        begin
                raise_application_error(-20000, 'purge_api_vendor_token:' || 'method not implemented.', true);

        end purge_api_vendor_token;

        -- procedure => LOG_MESSAGE
        PROCEDURE LOG_MESSAGE (
                                P_PACKAGE_NAME	MTS_APP_PROCESS_LOG.PACKAGE_NAME%TYPE DEFAULT NULL,
	                        P_PROCESS_NAME	MTS_APP_PROCESS_LOG.PROCESS_NAME%TYPE  DEFAULT NULL,
	                        P_LOG_LEVEL	MTS_APP_PROCESS_LOG.LOG_LEVEL%TYPE  DEFAULT 9999,
	                        P_LOG_MSG 	MTS_APP_PROCESS_LOG.LOG_MSG%TYPE  DEFAULT NULL,
	                        P_LOG_CLOB	MTS_APP_PROCESS_LOG.LOG_CLOB%TYPE  DEFAULT NULL)
                                
        AS
                PL_LOG_LEVEL   mts_app_cntrl_value.number_value%type;
                PL_LOG         BOOLEAN;
        
        BEGIN
                PL_LOG_LEVEL := get_app_cntrl_number_value( 
                                                        p_app_cntrl_name => 'MTS_APP_CONFIG',
                                                        p_key => 'LOG_LEVEL');

                IF PL_LOG_LEVEL <= P_LOG_LEVEL THEN  
                        INSERT INTO MTS_APP_PROCESS_LOG (PACKAGE_NAME, PROCESS_NAME, LOG_LEVEL, LOG_MSG, LOG_CLOB)                
                        VALUES (P_PACKAGE_NAME, P_PROCESS_NAME, P_LOG_LEVEL, P_LOG_MSG, P_LOG_CLOB);     
                END IF;

        END LOG_MESSAGE; 


end pkg_mts_app_util;
/