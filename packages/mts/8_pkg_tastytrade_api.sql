/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_tastytrade_api
as

    g_url       constant varchar2(60)   := pkg_mts_app_util.get_app_cntrl_str_value(            
                                            p_app_cntrl_name  => 'TASTYTRADE_API',
                                            p_key => 'BASE_URL');

    
    function get_session_token( p_user_id       mts_user.user_id%type,
                                p_login         varchar2 ,
                                p_password      varchar2  ,
                                p_remember_me   boolean default true                              
                              ) return mts_user_api_token.token%type;
    
    procedure  get_transaction( p_token             mts_user_api_token.token%type, 
                                p_portfolio_id      mts_portfolio.id%type);

    procedure   get_account_snapshot(p_portfolio_id mts_portfolio.id%type);

    
    /*
    function get_session_token( p_user_id       mts_user.user_id%type,
                                p_login         varchar2 ,
                                p_password      varchar2  ,
                                p_remember_me   boolean default true                              
                              ) return mts_api_vendor_token.token%type;
    */

   

    --function get_account_balance(p_account_number  varchar2 ) return clob;   
    
    

end pkg_tastytrade_api;
/

 /*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_tastytrade_api
as
    
    
    pl_full_url             varchar2(1000);
    pl_vendor_code          mts_api_vendor.vendor_code%type     := 'TASTYTRADE';
    pl_log_msg              mts_app_process_log.msg_str%type;
    pl_newline              char(1) := chr(10);



    --------------------------------------------------------------------------------------
    --    get_session_token
    --------------------------------------------------------------------------------------
    function get_session_token( p_user_id       mts_user.user_id%type,
                                p_login         varchar2 ,
                                p_password      varchar2  ,
                                p_remember_me   boolean default true                              
                              ) return mts_user_api_token.token%type
    is
        pl_clob            clob;
        pl_body            clob;
        pl_token           mts_user_api_token.token%type;
        
    begin
        
        pl_log_msg := '';
        pl_full_url := g_url || 'sessions';
        pl_log_msg  := '[get_session_token].[p_user_id] = ' || p_user_id || pl_newline;
        

        pl_token := pkg_mts_api_vendor.get_user_api_token(p_user_id => p_user_id,
                                                    p_vendor_code => pl_vendor_code);
        
        if ( pl_token is not null ) then
            pl_log_msg  := pl_log_msg || '[get_session_token].[existing token] = ' || pl_token || pl_newline;
            return pl_token;
        end if;

        pl_log_msg  := pl_log_msg || '[get_session_token].[p_login] = ' || p_login || '  [p_login token] =' || p_password ||  pl_newline;
        pl_log_msg  := pl_log_msg || '[get_session_token].[pl_full_url] = ' || pl_full_url || pl_newline;
        
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('login',p_login);
        apex_json.write('password',p_password);
        apex_json.write('remember-me',p_remember_me);
        apex_json.close_object;
        pl_body := apex_json.get_clob_output;        
        apex_json.close_all;
        
        pl_log_msg  := pl_log_msg || '[get_session_token].[pl_body] = ' || pl_body || pl_newline;
        
        apex_web_service.g_request_headers(1).name  := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'User-Agent';
        apex_web_service.g_request_headers(2).value := 'MytradeStat/1.0';
        
        pl_clob := apex_web_service.make_rest_request(
                        p_url => pl_full_url,
                        p_http_method => 'POST',
                        p_body => pl_body);

        pl_log_msg  := pl_log_msg || '[get_session_token].[pl_clob] = ' || pl_clob || pl_newline;

        apex_json.parse(pl_clob);        

        pl_token :=  apex_json.get_varchar2(p_path => 'data."session-token"');

        pkg_mts_api_vendor.set_user_api_token(p_user_id => p_user_id,
                                        p_vendor_code => pl_vendor_code,
                                        p_token => pl_token,
                                        p_issued_at => current_timestamp);

        pl_log_msg  := pl_log_msg || '[get_session_token].[pl_token] = ' || pl_token || pl_newline;
        
        return pl_token;
    EXCEPTION
        when OTHERS THEN
            pl_log_msg := pl_log_msg || SQLCODE || SUBSTR(SQLERRM, 1, 64);
            PKG_MTS_APP_UTIL.LOG_MESSAGE (
                                            P_PACKAGE_NAME	=> 'PKG_TASTYTRADE_API',
	                                        P_PROCESS_NAME	=> 'get_session_token',
	                                        P_MSG_STR 	=> SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 250),
                                            P_MSG_CLOB => pl_log_msg);
                                            
            raise_application_error(-20000, SQLCODE || SUBSTR(SQLERRM, 1, 250), true);
            
    end get_session_token;

    --------------------------------------------------------------------------------------
    --    get_transactions
    --------------------------------------------------------------------------------------
    procedure  get_transaction( p_token             mts_user_api_token.token%type, 
                                p_portfolio_id      mts_portfolio.id%type

                              )
    as
        pl_start_at             TIMESTAMP ;
        pl_end_at               TIMESTAMP := CURRENT_TIMESTAMP; 
        pl_portfolio_rec        mts_portfolio%rowtype;
        pl_response             clob;
        pl_index                number := 1;
        pl_param_name           apex_application_global.vc_arr2;
        pl_param_value          apex_application_global.vc_arr2;
        pl_total_pages          number(10);
        pl_current_page         number(10) := 0;
        pl_max_line_num         number(10);
    begin
        BEGIN
                select  *
                into    pl_portfolio_rec
                from    mts_portfolio
                where   id = p_portfolio_id;

                if ( pl_portfolio_rec.broker_id is null OR pl_portfolio_rec.account_num is null) then
                    raise_application_error(-20000, 'Portfolio is not set for auto sync.', true); 
                end if;

                pl_start_at := nvl(pl_portfolio_rec.last_import_trade_at,to_timestamp('01-01-' || to_char(current_timestamp,'YYYY'),'MM-DD-YYYY'));
               
        EXCEPTION
            when no_data_found then 
                raise_application_error(-20000, 'Portfolio not found.', true);   
        END;

        ---- DELETE PREVIOUS LOADED TRANSACTIONS ---
        DELETE FROM  mts_tastytrade_tran_stg WHERE portfolio_id = p_portfolio_id;

        ---- GET TRANSACTIONS ---
        pl_full_url  := g_url || 'accounts/' || pl_portfolio_rec.account_num || '/transactions';

        apex_web_service.g_request_headers(1).name  := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'authorization';
        apex_web_service.g_request_headers(2).value := p_token;
        apex_web_service.g_request_headers(3).name  := 'User-Agent';
        apex_web_service.g_request_headers(3).value := 'MytradeStat/1.0';

        pl_param_name(pl_index)  := 'sort';
        pl_param_value(pl_index) := 'Asc';
        pl_index := pl_index + 1;        

        pl_param_name(pl_index)  := 'start-at';
        pl_param_value(pl_index) := to_char(CAST(pl_start_at AT TIME ZONE 'UTC' AS TIMESTAMP),'YYYY-MM-DD"T"HH:MI:SS');
        pl_index := pl_index + 1;        

        pl_param_name(pl_index)  := 'end-at';
        pl_param_value(pl_index) := to_char(CAST(pl_end_at AT TIME ZONE 'UTC' AS TIMESTAMP),'YYYY-MM-DD"T"HH:MI:SS');
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'types[]';
        pl_param_value(pl_index) := 'Trade';
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'types[]';
        pl_param_value(pl_index) := 'Receive Deliver';
        pl_index := pl_index + 1;
        
        pl_param_name(pl_index)  := 'types[]';
        pl_param_value(pl_index) := 'Money Movement';
        pl_index := pl_index + 1;

        loop

            pl_param_name(pl_index)  := 'page-offset';
            pl_param_value(pl_index) := pl_current_page;
            
            pl_response := apex_web_service.make_rest_request(
                            p_url => pl_full_url,
                            p_http_method => 'GET',
                            p_parm_name  => pl_param_name,
                            p_parm_value => pl_param_value);

            apex_json.parse(pl_response);
            pl_total_pages := apex_json.get_number(p_path => 'pagination."total-pages"');
           
            begin
                select  nvl(max(line_number),0) into pl_max_line_num
                from    mts_tastytrade_tran_stg
                where   portfolio_id = p_portfolio_id;
            exception
                when no_data_found then
                    pl_max_line_num := 0;
            end;

            /*
            PKG_MTS_APP_UTIL.LOG_MESSAGE (MTS_API_VENDOR_TOKEN
                                            P_PACKAGE_NAME	=> 'PKG_TASTYTRADE_API',
	                                        P_PROCESS_NAME	=> 'get_transaction',
	                                        P_LOG_LEVEL	=> PKG_MTS_APP_UTIL.ERROR,
	                                        P_LOG_CLOB 	=> pl_response);
            */
            insert into mts_tastytrade_tran_stg ( portfolio_id, line_number,
                                                  account_number, symbol, instrument_type, underlying_symbol,transaction_type, transaction_sub_type, 
                                                  description, action, quantity,price, executed_at, 
                                                  value, value_effect,regulatory_fees, clearing_fees, net_value,commission,  
                                                  order_id ,currency )       

            select  p_portfolio_id,rownum + pl_max_line_num,
                    account_number, symbol, instrument_type, underlying_symbol,transaction_type,transaction_sub_type, 
                    description, action, quantity,price, executed_at, 
                    value, value_effect, regulatory_fees, clearing_fees, net_value,commission,  
                    order_id ,currency
            from    json_table ( pl_response,  '$.data.items[*]' 
                                    COLUMNS (
                                            account_number              varchar2(100)       path '$."account-number"',   
                                            symbol                      varchar2(100)       path '$.symbol',
                                            instrument_type             varchar2(100)       path '$."instrument-type"',
                                            underlying_symbol           varchar2(100)       path '$."underlying-symbol"',
                                            transaction_type            varchar2(100)       path '$."transaction-type"',
                                            transaction_sub_type        varchar2(100)       path '$."transaction-sub-type"',
                                            description                 varchar2(100)       path '$."description"',
                                            action                      varchar2(100)       path '$."action"',
                                            quantity                    varchar2(100)       path '$."quantity"',
                                            price                       varchar2(100)       path '$."price"',
                                            executed_at                 varchar2(100)       path '$."executed-at"',
                                            value                       varchar2(100)       path '$."value"',
                                            value_effect                varchar2(100)       path '$."value-effect"',
                                            regulatory_fees             varchar2(100)       path '$."regulatory-fees"',
                                            clearing_fees               varchar2(100)       path '$."clearing-fees"',
                                            net_value                   varchar2(100)       path '$."net-value"',
                                            commission                  varchar2(100)       path '$."commission"',
                                            order_id                    varchar2(100)       path '$."order-id"',
                                            currency                    varchar2(100)       path '$."currency"'
                                    )
                        );

            if ( pl_current_page >= (pl_total_pages-1)  ) then
                exit;
            else
                pl_current_page := pl_current_page + 1;
            end if;
        end loop;

        update mts_portfolio
        set last_import_trade_at = pl_end_at
        where id = p_portfolio_id;

        commit;
    EXCEPTION
        
        when others then   
            PKG_MTS_APP_UTIL.LOG_MESSAGE (
                                            P_PACKAGE_NAME	=> 'PKG_TASTYTRADE_API',
	                                        P_PROCESS_NAME	=> 'get_transaction',
	                                        P_MSG_STR 	=> SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 250));
                                            
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 250), true);

    END;


    --------------------------------------------------------------------------------------
    --    get_account_snapshot
    --------------------------------------------------------------------------------------
    procedure  get_account_snapshot( p_portfolio_id      mts_portfolio.id%type    
                              )
    as
        pl_token                mts_user_api_token.token%type;
        pl_start_at             TIMESTAMP ;
        pl_end_at               TIMESTAMP := CURRENT_TIMESTAMP;
        pl_portfolio_rec        mts_portfolio%rowtype;
        pl_response             clob;
        pl_index                number := 1;
        pl_param_name           apex_application_global.vc_arr2;
        pl_param_value          apex_application_global.vc_arr2;
        pl_total_pages          number(10);
        pl_current_page         number(10) := 0;
        pl_max_line_num         number(10);
    begin
        BEGIN
                select  *
                into    pl_portfolio_rec
                from    mts_portfolio
                where   id = p_portfolio_id;

                if ( pl_portfolio_rec.broker_id is null OR pl_portfolio_rec.account_num is null) then
                    raise_application_error(-20000, 'Portfolio is not set for auto sync.', true); 
                end if;

                pl_start_at := nvl(pl_portfolio_rec.last_account_snapshot_at,to_timestamp('01-01-' || to_char(current_timestamp,'YYYY'),'MM-DD-YYYY'));
        EXCEPTION
            when no_data_found then 
                raise_application_error(-20000, 'Portfolio not found.', true);   
        END;

        ---- DELETE PREVIOUS LOADED TRANSACTIONS ---
        DELETE FROM  mts_tastytrade_acct_balance_stg WHERE portfolio_id = p_portfolio_id;

        ---- GET API TOKEN ---
        pl_token := get_session_token(  p_user_id => pl_portfolio_rec.user_id,
                                        p_login   => pl_portfolio_rec.broker_login ,
                                        p_password  => pl_portfolio_rec.broker_password  );
        
        
        ---- GET ACCOUNT SNAPSHOT ---
        --pl_full_url  := g_url || 'accounts/' || pl_portfolio_rec.account_num || '/balance-snapshots';
        pl_full_url  := g_url || 'accounts/' || pl_portfolio_rec.account_num || '/balances';

        apex_web_service.g_request_headers(1).name  := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'authorization';
        apex_web_service.g_request_headers(2).value := pl_token;
        apex_web_service.g_request_headers(3).name  := 'User-Agent';
        apex_web_service.g_request_headers(3).value := 'MytradeStat/1.0';

        pl_param_name(pl_index)  := 'time-of-day';
        pl_param_value(pl_index) := 'EOD';
        pl_index := pl_index + 1;        

        pl_param_name(pl_index)  := 'start-at';
        pl_param_value(pl_index) := to_char(pl_start_at,'YYYY-MM-DD"T"HH:MI:SS');
        pl_index := pl_index + 1;        

        pl_param_name(pl_index)  := 'end-at';
        pl_param_value(pl_index) := to_char(pl_end_at,'YYYY-MM-DD"T"HH:MI:SS');
        pl_index := pl_index + 1;

        

        loop

            pl_param_name(pl_index)  := 'page-offset';
            pl_param_value(pl_index) := pl_current_page;
            
            pl_response := apex_web_service.make_rest_request(
                            p_url => pl_full_url,
                            p_http_method => 'GET',
                            p_parm_name  => pl_param_name,
                            p_parm_value => pl_param_value);

            apex_json.parse(pl_response);
            pl_total_pages := apex_json.get_number(p_path => 'pagination."total-pages"');
           
            begin
                select  nvl(max(line_number),0) into pl_max_line_num
                from    mts_tastytrade_tran_stg
                where   portfolio_id = p_portfolio_id;
            exception
                when no_data_found then
                    pl_max_line_num := 0;
            end;

            /*
            PKG_MTS_APP_UTIL.LOG_MESSAGE (
                                            P_PACKAGE_NAME	=> 'PKG_TASTYTRADE_API',
	                                        P_PROCESS_NAME	=> 'get_transaction',
	                                        P_LOG_LEVEL	=> PKG_MTS_APP_UTIL.ERROR,
	                                        P_LOG_CLOB 	=> pl_response);
            */
            insert into mts_tastytrade_acct_balance_stg ( portfolio_id, snapshot_date , account_number, futures_margin_requirement , 
                                                        total_settle_balance , cash_settle_balance , maintenance_requirement , pending_cash ,
                                                        bond_margin_requirement ,long_bond_value , day_trade_excess , cash_available_to_withdraw
                                                        )       

            select  p_portfolio_id, snapshot_date , account_number, futures_margin_requirement , 
                    total_settle_balance , cash_settle_balance , maintenance_requirement , pending_cash ,
                    bond_margin_requirement ,long_bond_value , day_trade_excess , cash_available_to_withdraw
            from    json_table ( pl_response,  '$.data.items[*]' 
                                    COLUMNS (
                                            snapshot_date               varchar2(100)       path '$."snapshot-date"',   
                                            account_number              varchar2(100)       path '$."account-number"',
                                            futures_margin_requirement  varchar2(100)       path '$."futures-margin-requirement"',
                                            total_settle_balance        varchar2(100)       path '$."total-settle-balance"',
                                            cash_settle_balance         varchar2(100)       path '$."cash-settle-balance"',
                                            maintenance_requirement     varchar2(100)       path '$."maintenance-requirement"',
                                            pending_cash                varchar2(100)       path '$."pending-cash"',
                                            bond_margin_requirement     varchar2(100)       path '$."bond-margin-requirement"',
                                            long_bond_value             varchar2(100)       path '$."long-bond-value"',
                                            day_trade_excess            varchar2(100)       path '$."day-trade-excess"',
                                            cash_available_to_withdraw  varchar2(100)       path '$."cash-available-to-withdraw"'
                                    )
                        );

            if ( pl_current_page >= (pl_total_pages-1)  ) then
                exit;
            else
                pl_current_page := pl_current_page + 1;
            end if;
        end loop;

        update mts_portfolio
        set last_account_snapshot_at = pl_end_at
        where id = p_portfolio_id;

        commit;
    EXCEPTION
        when OTHERS THEN
            pl_log_msg := pl_log_msg || SQLCODE || SUBSTR(SQLERRM, 1, 64);
            PKG_MTS_APP_UTIL.LOG_MESSAGE (
                                            P_PACKAGE_NAME	=> 'PKG_TASTYTRADE_API',
	                                        P_PROCESS_NAME	=> 'get_account_snapshot',
	                                        P_MSG_STR 	=> SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 250));
                                            
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 250), true);

    END;


    

    

end pkg_tastytrade_api;