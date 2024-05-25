/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_tastytrade_api
as


    g_url           constant varchar2(60)    := pkg_mts_app_setup.get_app_cntrl_str_value(            
                                                            p_app_cntrl_name  => 'TASTYTRADE_API',
                                                            p_key => 'BASE_URL');


    function get_session_token( p_user_id       mts_user.user_id%type,
                                p_login         varchar2 ,
                                p_password      varchar2  ,
                                p_remember_me   boolean default true                              
                              ) return mts_api_vendor_token.token%type;

    procedure load_trade_transaction(   p_session_token     varchar2, 
                                        p_user_id           mts_user.user_id%type,
                                        p_account_number    mts_portfolio.account_num%type,
                                        p_portfolio_id      mts_portfolio.id%type,
                                        p_broker_id         mts_broker.id%type,    
                                        p_start_at          timestamp,
                                        p_end_at            timestamp) ;

    --function get_account_balance(p_account_number  varchar2 ) return clob;   

    

end pkg_tastytrade_api;
/

 /*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_tastytrade_api
as
    c_default_currency      constant char(3)        := 'USD';
    c_default_splitter      constant char(1)        := ':';
    c_alt_splitter          constant char(1)        := '^';
    --
    c_result_server         constant varchar2(256)  := 'denim.maxapex.net';
    c_result_page_id        constant number(8)      := 200;
    --
    c_type_success          constant varchar2(8)    := 'success';
    c_type_cancel           constant varchar2(8)    := 'cancel';

    
    pl_full_url             varchar2(1000);
    pl_vendor_code          mts_api_vendor.vendor_code%type     := 'TASTYTRADE';

    --------------------------------------------------------------------------------------
    --    get_private_key
    --------------------------------------------------------------------------------------
    function get_private_key    return mts_app_cntrl_value.str_value%type
    as
    begin
        return pkg_mts_app_setup.get_app_cntrl_str_value(            
                p_app_cntrl_name  => 'TASTYTRADE_API',
                p_key => 'PRIVATE_KEY');
    end;

    --------------------------------------------------------------------------------------
    --    get_session_token
    --------------------------------------------------------------------------------------
    function get_session_token( p_user_id       mts_user.user_id%type,
                                p_login         varchar2 ,
                                p_password      varchar2  ,
                                p_remember_me   boolean default true                              
                              ) return mts_api_vendor_token.token%type
    is
        pl_clob            clob;
        pl_body            clob;
        pl_token           mts_api_vendor_token.token%type;
        
    begin

        pl_full_url := g_url || 'sessions';
        dbms_output.put_line('get_session_token.p_user_id = ' || p_user_id);

        pl_token := pkg_mts_app_setup.get_api_token(p_user_id => p_user_id,
                                                    p_vendor_code => pl_vendor_code);
        
        if ( pl_token is not null ) then
            dbms_output.put_line('get_session_token.[existing token]  = ' || pl_token);
            return pl_token;
        end if;


        dbms_output.put_line('get_session_token.p_login = ' || p_login);
        dbms_output.put_line('get_session_token.p_password = ' || p_password);
        dbms_output.put_line('get_session_token.pl_full_url = ' || pl_full_url);

        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('login',p_login);
        apex_json.write('password',p_password);
        apex_json.write('remember-me',p_remember_me);
        apex_json.close_object;
        pl_body := apex_json.get_clob_output;        
        apex_json.close_all;
        
        dbms_output.put_line('get_session_token.pl_body = ' || pl_body);

        apex_web_service.g_request_headers(1).name  := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'User-Agent';
        apex_web_service.g_request_headers(2).value := 'MytradeStat/1.0';
        
        pl_clob := apex_web_service.make_rest_request(
                        p_url => pl_full_url,
                        p_http_method => 'POST',
                        p_body => pl_body);

        dbms_output.put_line('get_session_token.pl_clob = ' || pl_clob);

        apex_json.parse(pl_clob);
        
        pl_token :=  apex_json.get_varchar2(p_path => 'data."session-token"');

        pkg_mts_app_setup.set_api_vendor_token(p_user_id => p_user_id,
                                        p_vendor_code => pl_vendor_code,
                                        p_token => pl_token,
                                        p_issued_at => current_timestamp);

        dbms_output.put_line('get_session_token.pl_token = ' || pl_token);

        return pl_token;
    end get_session_token;


    --------------------------------------------------------------------------------------
    --    get_transactions
    --------------------------------------------------------------------------------------
    procedure load_trade_transaction(   p_session_token     varchar2, 
                                        p_user_id           mts_user.user_id%type,
                                        p_account_number    mts_portfolio.account_num%type,
                                        p_portfolio_id      mts_portfolio.id%type,
                                        p_broker_id         mts_broker.id%type,    
                                        p_start_at          timestamp,
                                        p_end_at            timestamp) 
    as
        pl_response             clob;
        pl_index                number := 1;
        pl_param_name           apex_application_global.vc_arr2;
        pl_param_value          apex_application_global.vc_arr2;
        pl_total_pages          number(10);
        pl_current_page         number(10) := 0;
        pl_import_log_id        mts_import_trade_log.id%type;
        pl_max_line_num         number(10);
    begin
        -- create record in mts_trade_import_log table
        pkg_mts_import_trade.create_import_log(
                                                p_import_log_id => pl_import_log_id ,
                                                p_user_id => p_user_id,
                                                p_portfolio_id => p_portfolio_id,
                                                p_broker_id => p_broker_id
        );
        dbms_output.put_line('[get_transactions].[pl_import_log_id] = ' || pl_import_log_id);

        -- Set api calls headers and parameters.
        pl_full_url  := g_url || 'accounts/' || p_account_number || '/transactions';
        
        dbms_output.put_line('[get_transactions].[p_account_number] = ' || p_account_number);
        dbms_output.put_line('[get_transactions].[pl_full_url] = ' || pl_full_url);
        dbms_output.put_line('[get_transactions].[p_start_at] = ' || p_start_at);
        dbms_output.put_line('[get_transactions].[p_end_at] = ' || p_end_at);

        apex_web_service.g_request_headers(1).name  := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'authorization';
        apex_web_service.g_request_headers(2).value := p_session_token;
        apex_web_service.g_request_headers(3).name  := 'User-Agent';
        apex_web_service.g_request_headers(3).value := 'MytradeStat/1.0';

        pl_param_name(pl_index)  := 'sort';
        pl_param_value(pl_index) := 'Asc';
        dbms_output.put_line('[get_transactions].[pl_param_name.sort-name] = ' || pl_param_name(pl_index));
        dbms_output.put_line('[get_transactions].[pl_param_value.sort-value] = ' ||  pl_param_value(pl_index));
        pl_index := pl_index + 1;        

        pl_param_name(pl_index)  := 'start-at';
        pl_param_value(pl_index) := to_char(p_start_at,'YYYY-MM-DD"T"HH:MI:SS');
        dbms_output.put_line('[get_transactions].[pl_param_name.start-at-name] = ' || pl_param_name(pl_index));
        dbms_output.put_line('[get_transactions].[pl_param_value.start-at-value] = ' ||  pl_param_value(pl_index));
        pl_index := pl_index + 1;        

        pl_param_name(pl_index)  := 'end-at';
        pl_param_value(pl_index) := to_char(current_timestamp,'YYYY-MM-DD"T"HH:MI:SS');
        dbms_output.put_line('[get_transactions].[pl_param_name.end-at-name] = ' || pl_param_name(pl_index));
        dbms_output.put_line('[get_transactions].[pl_param_value.end-at-value] = ' ||  pl_param_value(pl_index));
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'types[]';
        pl_param_value(pl_index) := 'Trade';
        dbms_output.put_line('[get_transactions].[pl_param_name.types[]] = ' || pl_param_name(pl_index));
        dbms_output.put_line('[get_transactions].[pl_param_value.types[]] = ' ||  pl_param_value(pl_index));
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'types[]';
        pl_param_value(pl_index) := 'Receive Deliver';
        dbms_output.put_line('[get_transactions].[pl_param_name.types[]] = ' || pl_param_name(pl_index));
        dbms_output.put_line('[get_transactions].[pl_param_value.types[]] = ' ||  pl_param_value(pl_index));
        pl_index := pl_index + 1;
        
        pl_param_name(pl_index)  := 'types[]';
        pl_param_value(pl_index) := 'Money Movement';
        dbms_output.put_line('[get_transactions].[pl_param_name.types[]] = ' || pl_param_name(pl_index));
        dbms_output.put_line('[get_transactions].[pl_param_value.types[]] = ' ||  pl_param_value(pl_index));
        pl_index := pl_index + 1;
        


        loop

            pl_param_name(pl_index)  := 'page-offset';
            pl_param_value(pl_index) := pl_current_page;
            dbms_output.put_line('[get_transactions].[pl_param_name.page-offset-name] = ' || pl_param_name(pl_index));
            dbms_output.put_line('[get_transactions].[pl_param_value.page-offset-value] = ' ||  pl_param_value(pl_index));

            pl_response := apex_web_service.make_rest_request(
                            p_url => pl_full_url,
                            p_http_method => 'GET',
                            p_parm_name  => pl_param_name,
                            p_parm_value => pl_param_value);

            apex_json.parse(pl_response);
            pl_total_pages := apex_json.get_number(p_path => 'pagination."total-pages"');
            dbms_output.put_line('[get_transactions].[pl_total_pages] = ' ||  pl_total_pages);

            begin
                select  nvl(max(line_number),0) into pl_max_line_num
                from    mts_import_trade_data
                where   import_trade_log_id = pl_import_log_id;
            exception
                when no_data_found then
                    pl_max_line_num := 0;
            end;
            dbms_output.put_line('[get_transactions].[pl_max_line_num] = ' ||  pl_max_line_num);

            insert into mts_import_trade_data ( import_trade_log_id, line_number,
                                                col_1, col_2, col_3, col_4, col_5, 
                                                col_6, col_7, col_8, col_9, col_10, 
                                                col_11, col_12, col_13, col_14, col_15 ,
                                                col_16, col_17 )        

            select  pl_import_log_id,rownum + pl_max_line_num,
                    account_number, symbol, instrument_type, underlying_symbol,transaction_type, 
                    description, action, quantity,price, executed_at, 
                    value, regulatory_fees, clearing_fees, net_value,commission,  
                    order_id ,currency
            from    json_table ( pl_response,  '$.data.items[*]' 
                                    COLUMNS (
                                            account_number              varchar2(100)       path '$."account-number"',   
                                            symbol                      varchar2(100)       path '$.symbol',
                                            instrument_type             varchar2(100)       path '$."instrument-type"',
                                            underlying_symbol           varchar2(100)       path '$."underlying-symbol"',
                                            transaction_type            varchar2(100)       path '$."transaction-type"',
                                            description                 varchar2(100)       path '$."description"',
                                            action                      varchar2(100)       path '$."action"',
                                            quantity                    varchar2(100)       path '$."quantity"',
                                            price                       varchar2(100)       path '$."price"',
                                            executed_at                 varchar2(100)       path '$."executed-at"',
                                            value                       varchar2(100)       path '$."value"',
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


    end;


end pkg_tastytrade_api;