/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_api_vendor as

        MESSAGE         CONSTANT NUMBER := 10;
        INFO            CONSTANT NUMBER := 20;
        WARNING         CONSTANT NUMBER := 30;
        ERROR           CONSTANT NUMBER := 9999;

                --------------------------------------------------------------------------------------
        --    API_VENDOR
        --------------------------------------------------------------------------------------
        function get_api_token_interval ( p_vendor_code mts_api_vendor.vendor_code%type ) 
        return mts_api_vendor.token_interval%type;

        procedure set_api_vendor (
                p_vendor_code                   mts_api_vendor.vendor_code%type ,
                p_vendor_name                   mts_api_vendor.vendor_name%type         default null,
                p_token_interval                mts_api_vendor.token_interval%type      default 1440,
                p_access_token                  mts_api_vendor.access_token%type        default null,
                p_active                        mts_api_vendor.active%type              default 1 );

                
        procedure delete_api_vendor( p_vendor_code     mts_api_vendor.vendor_code%type  );

        --------------------------------------------------------------------------------------
        --    API_VENDOR_TOKEN
        --------------------------------------------------------------------------------------
        function get_user_api_token( p_user_id                       mts_user_api_token.user_id%type,
                                p_vendor_code                        mts_user_api_token.vendor_code%type )
        return  mts_user_api_token.token%type ;

        procedure set_user_api_token (
                        p_user_id                       mts_user_api_token.user_id%type,
                        p_vendor_code                   mts_user_api_token.vendor_code%type ,
                        p_token				            mts_user_api_token.token%type ,
                        p_issued_at 			        timestamp default current_timestamp );

        procedure purge_user_api_token;
end pkg_mts_api_vendor;
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_api_vendor as
 
 

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
                p_vendor_name                   mts_api_vendor.vendor_name%type         default null,
                p_token_interval                mts_api_vendor.token_interval%type      default 1440,
                p_access_token                  mts_api_vendor.access_token%type        default null,
                p_active                        mts_api_vendor.active%type              default 1 )
        as
        begin

                update mts_api_vendor
                set     
                        vendor_name = nvl(p_vendor_name,vendor_name),
                        token_interval = nvl(p_token_interval,token_interval),
                        access_token = nvl(p_access_token,access_token),
                        active = nvl(p_active,active)
                where   vendor_code = p_vendor_code ;  

                if sql%rowcount = 0 then
                        insert into mts_api_vendor (vendor_code,vendor_name,token_interval,active)
                        values (p_vendor_code,nvl(p_vendor_name,p_vendor_code),p_token_interval,p_active);
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
        function get_user_api_token( p_user_id                       mts_user_api_token.user_id%type,
                                p_vendor_code                   mts_user_api_token.vendor_code%type )
        return  mts_user_api_token.token%type 
        as
                pl_token      mts_user_api_token.token%type ;  
        begin
                --return token only if it is valid
                begin
                        select  token
                        into    pl_token
                        from    mts_user_api_token
                        where   user_id = p_user_id
                        and     vendor_code = p_vendor_code
                        and     current_timestamp < expire_at;

                exception
                        when no_data_found then
                                pl_token := null;           
                end;

                return pl_token;
        end ;

        -- procedure => set_user_api_token
        procedure set_user_api_token (
                        p_user_id               mts_user_api_token.user_id%type,
                        p_vendor_code           mts_user_api_token.vendor_code%type ,
                        p_token				    mts_user_api_token.token%type ,
                        p_issued_at 			timestamp default current_timestamp  )
        as
                
                pl_expire_at            timestamp;    
        begin

                pl_expire_at := p_issued_at + numtodsinterval(get_api_token_interval(p_vendor_code => p_vendor_code), 'minute');

                update mts_user_api_token
                set     
                        token = p_token,
                        issued_at = p_issued_at,
                        expire_at = pl_expire_at
                where   user_id = p_user_id
                and     vendor_code = p_vendor_code ;  

                if sql%rowcount = 0 then
                        insert into mts_user_api_token (user_id, vendor_code, token, issued_at, expire_at)
                        values (p_user_id, p_vendor_code, p_token, p_issued_at, pl_expire_at );
                end if;           


        end set_user_api_token;                

        -- procedure => purge_user_api_token
        procedure purge_user_api_token
        as
        begin
                raise_application_error(-20000, 'purge_user_api_token:' || 'method not implemented.', true);

        end purge_user_api_token;
end pkg_mts_api_vendor;
/