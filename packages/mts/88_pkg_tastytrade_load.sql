create or replace package pkg_tastytrade_load
as
   
    procedure sync_transaction (    
        p_login         varchar2,
        p_password      varchar2,
        p_user_id       mts_user.user_id%type,
        p_broker_id     mts_broker.id%type,
        p_portfolio_id  mts_portfolio.id%type,
        p_import_log_id out mts_import_trade_log.id%type) ;

end pkg_tastytrade_load;
/
create or replace package body pkg_tastytrade_load
as

    pl_msg_clob                 varchar2(32000);
    pl_new_line                 char(1) := chr(10);

    --------------------------------------------------------------------------------------
    --    PROCEDURE : load_import_trade_data_to_ws
    --------------------------------------------------------------------------------------
    procedure reset_mts_ws_trade_record(p_rec_id in out mts_ws_trade%rowtype)
    as
    begin
        p_rec_id.seq_no := null;
        p_rec_id.user_id := null;
        p_rec_id.portfolio_id := null;
        p_rec_id.symbol := null;
        p_rec_id.exp_date := null;
        p_rec_id.order_type := null;
        p_rec_id.strike := null;
        p_rec_id.action_code := null;
        p_rec_id.qty := null;
        p_rec_id.price := null;
        p_rec_id.commission := null;
        p_rec_id.fees := null;
        p_rec_id.source_order_id := null;
    end;

    --------------------------------------------------------------------------------------
    --    PROCEDURE : process_trade_tran
    --------------------------------------------------------------------------------------
    PROCEDURE process_trade_tran( 
        p_imp_trade_rec     v_mts_tastytrade_import_data%rowtype,
        p_imp_log_rec       mts_import_trade_log%rowtype,
        p_status  out char )
    AS
        pl_ws_trade_rec             mts_ws_trade%rowtype;
        pl_tmp_action_code          mts_trade_tran.action_code%type;
        
    BEGIN
        reset_mts_ws_trade_record(p_rec_id => pl_ws_trade_rec);
        pl_ws_trade_rec.seq_no := p_imp_trade_rec.line_number ;
        pl_ws_trade_rec.user_id         := p_imp_log_rec.user_id;
        pl_ws_trade_rec.portfolio_id    := p_imp_log_rec.portfolio_id;
        pl_msg_clob := '';
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.user_id] = ' ||  pl_ws_trade_rec.user_id || pl_new_line;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.portfolio_id] = ' ||  pl_ws_trade_rec.portfolio_id || pl_new_line;
        
        -- get tran_date
        --pl_ws_trade_rec.tran_date := TO_UTC_TIMESTAMP_TZ(p_imp_trade_rec.col_10);
        --select TO_TIMESTAMP_TZ('2024-07-09T21:00:00.000+00:00', 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM') AT TIME ZONE 'UTC' AS utc_time from dual;
        --select CAST(p_imp_trade_rec.executed_at AT TIME ZONE 'UTC' AS TIMESTAMP) AT TIME ZONE 'America/New_York' into pl_ws_trade_rec.tran_date from dual;
        SELECT  TO_TIMESTAMP_TZ(p_imp_trade_rec.executed_at, 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM') AT TIME ZONE 'America/New_York' 
        INTO    pl_ws_trade_rec.tran_date
        FROM dual;
        
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.tran_date] = ' ||  pl_ws_trade_rec.tran_date || pl_new_line;
        
        ---- get symbol
        pl_ws_trade_rec.symbol  := trim(substr(replace(p_imp_trade_rec.symbol,'.',''),1,6));  
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.symbol] = ' ||  pl_ws_trade_rec.symbol || pl_new_line;      
        
        -- if instrument_type is options then get symbol, exp_date, order_type and strike price from symbol column.
        if ( lower(p_imp_trade_rec.instrument_type) like '%future option%')  then
            pl_ws_trade_rec.exp_date    := to_timestamp(substr(p_imp_trade_rec.symbol,14,6),'RRMMDD');
            if ( substr(p_imp_trade_rec.symbol,20,1) = 'C') then
                pl_ws_trade_rec.order_type := 'CALL';
            else
                pl_ws_trade_rec.order_type := 'PUT';
            end if;
            pl_ws_trade_rec.strike      := to_number(substr(p_imp_trade_rec.symbol,21));
            pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.exp_date] = ' ||  pl_ws_trade_rec.exp_date || pl_new_line;
            pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.strike] = ' ||  pl_ws_trade_rec.strike || pl_new_line;
            pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.order_type] = ' ||  pl_ws_trade_rec.order_type || pl_new_line; 

        elsif ( lower(p_imp_trade_rec.instrument_type) like '%equity option%')  then
            pl_ws_trade_rec.exp_date    := to_timestamp(substr(p_imp_trade_rec.symbol,7,6),'RRMMDD');
            if ( substr(p_imp_trade_rec.symbol,13,1) = 'C') then
                pl_ws_trade_rec.order_type := 'CALL';
            else
                pl_ws_trade_rec.order_type := 'PUT';
            end if;  
            pl_ws_trade_rec.strike      := to_number(substr(p_imp_trade_rec.symbol,14))/1000;       
                    
        elsif ( lower(p_imp_trade_rec.instrument_type) like ('%future%')) then
            pl_ws_trade_rec.order_type := 'FUTURE';
        elsif ( lower(p_imp_trade_rec.instrument_type) like ('%bond%')) then
            pl_ws_trade_rec.order_type := 'BOND';
        elsif ( lower(p_imp_trade_rec.instrument_type) like ('%equity%')) then
            pl_ws_trade_rec.order_type := 'EQUITY';
        else
            pl_ws_trade_rec.order_type := 'EQUITY';
        end if;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.exp_date] = ' ||  pl_ws_trade_rec.exp_date || pl_new_line;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.strike] = ' ||  pl_ws_trade_rec.strike || pl_new_line;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.order_type] = ' ||  pl_ws_trade_rec.order_type || pl_new_line; 

        

        -- get action_code
        if lower(trim(p_imp_trade_rec.action)) in ( 'buy to open','buy_to_open') then
            pl_ws_trade_rec.action_code := 'BTO';
        elsif lower(trim(p_imp_trade_rec.action)) in ( 'sell to open','sell_to_open') then
            pl_ws_trade_rec.action_code := 'STO';
        elsif lower(trim(p_imp_trade_rec.action)) in ( 'buy to close','buy_to_close') then
            pl_ws_trade_rec.action_code := 'BTC';
        elsif lower(trim(p_imp_trade_rec.action)) in ( 'sell to close','sell_to_close') then
            pl_ws_trade_rec.action_code := 'STC';
        elsif lower(trim(p_imp_trade_rec.action)) in ( 'buy') then
            pl_ws_trade_rec.action_code := 'BUY';
        elsif lower(trim(p_imp_trade_rec.action)) in ( 'sell') then
            pl_ws_trade_rec.action_code := 'SELL';                
        elsif ( lower(p_imp_trade_rec.description) like '%removal of option%') then
            pl_ws_trade_rec.action_code := 'REMO';
        else
            pl_ws_trade_rec.action_code := NULL;
        end if;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.action_code] = ' ||  pl_ws_trade_rec.action_code || pl_new_line;
        
        -- get quantity
        pl_ws_trade_rec.qty := to_number(p_imp_trade_rec.quantity);
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.qty] = ' ||  pl_ws_trade_rec.qty || pl_new_line;
        -- get price
        if ( lower(p_imp_trade_rec.value_effect) = 'debit'  ) then
            pl_ws_trade_rec.price := to_number(p_imp_trade_rec.value) *-1;
        else  
            pl_ws_trade_rec.price := to_number(p_imp_trade_rec.value);
        end if;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.price] = ' ||  pl_ws_trade_rec.price || pl_new_line;
        -- get commission
        pl_ws_trade_rec.commission := to_number(p_imp_trade_rec.commission)*-1 ;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.commission] = ' ||  pl_ws_trade_rec.commission || pl_new_line;
        -- get fees
        pl_ws_trade_rec.fees := to_number(p_imp_trade_rec.regulatory_fees)*-1  + to_number(p_imp_trade_rec.clearing_fees)*-1 ;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.fees] = ' ||  pl_ws_trade_rec.fees || pl_new_line;
        -- order id
        pl_ws_trade_rec.source_order_id := p_imp_trade_rec.order_id;
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.source_order_id] = ' ||  pl_ws_trade_rec.source_order_id || pl_new_line;
        pl_ws_trade_rec.notes := p_imp_trade_rec.description; 
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.notes] = ' ||  pl_ws_trade_rec.notes || pl_new_line;
        pl_ws_trade_rec.trade_code := pkg_mts_util.get_trade_code(
                                                                    p_symbol => pl_ws_trade_rec.symbol,
                                                                    p_exp_date => pl_ws_trade_rec.exp_date,
                                                                    p_order_type => pl_ws_trade_rec.order_type,
                                                                    p_strike => pl_ws_trade_rec.strike
                                                                    );
        pl_msg_clob := pl_msg_clob || '[process_trade_tran].[pl_ws_trade_rec.trade_code] = ' ||  pl_ws_trade_rec.trade_code || pl_new_line;
        if ( pl_ws_trade_rec.action_code = 'REMO') THEN
                    
            pl_tmp_action_code := pkg_mts_trade.get_action_code(
                                                                p_portfolio_id => pl_ws_trade_rec.portfolio_id,
                                                                p_trade_code => pl_ws_trade_rec.trade_code);

            if ( pl_tmp_action_code is null) then   
                pl_tmp_action_code := pkg_mts_ws_trade.get_action_code(
                                                                p_portfolio_id => pl_ws_trade_rec.portfolio_id,
                                                                p_trade_code => pl_ws_trade_rec.trade_code);
            end if;
            pl_msg_clob := pl_msg_clob || '[process_trade_tran].[l_tmp_action_code] = ' || pl_tmp_action_code || pl_new_line;
            if ( nvl(pl_tmp_action_code,'XXX') = 'BTO') then
                pl_ws_trade_rec.qty := abs(pl_ws_trade_rec.qty) *-1 ;
            elsif ( nvl(pl_tmp_action_code,'XXX') = 'STO' )  then
                pl_ws_trade_rec.qty := abs(pl_ws_trade_rec.qty);
            end if;           

        end if;
        
        
        insert into mts_ws_trade values pl_ws_trade_rec;

        p_status := 'S';
    exception
        when others then 
            p_status := 'E';
            --dbms_output.put_line('[pkg_tastytrade_load].[process_trade_tran][LineNumber] = ' ||  pl_ws_trade_rec.line_number || '-' || SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250));
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_tastytrade_load',
                P_PROCESS_NAME => 'process_trade_tran',
                P_LOG_TYPE => 'E',
                P_MSG_CLOB => pl_msg_clob,
                P_MSG_STR => '[LINE_NUMBER][ERROR] => [' || p_imp_trade_rec.line_number || '] ['|| SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250) || ']'
            );
    END;

    --------------------------------------------------------------------------------------
    --    PROCEDURE : process_portfolio_tran
    --------------------------------------------------------------------------------------
    PROCEDURE process_portfolio_tran( 
        p_imp_trade_rec     v_mts_tastytrade_import_data%rowtype,
        p_imp_log_rec       mts_import_trade_log%rowtype,
        p_status  out char)
    AS
        pl_status  char(1);
        pl_portfolio_tran_rec   mts_portfolio_tran%rowtype;
        pl_tran_type            mts_portfolio_tran.tran_type%type; 
        pl_tran_source          mts_portfolio_tran.tran_source%type;         
    BEGIN
        pl_msg_clob := '';
        pl_msg_clob := pl_msg_clob || '[pkg_tastytrade_load][process_portfolio_tran][p_imp_trade_rec.line_number] ' || p_imp_trade_rec.line_number || pl_new_line;
        pl_tran_type := (CASE lower(p_imp_trade_rec.transaction_sub_type)
                            WHEN 'deposit' THEN 'DEPOSIT'
                            WHEN 'dividend' THEN 'DIVIDEND'
                            WHEN 'credit interest' THEN 'CREDIT_INTEREST'
                            WHEN 'debit interest' THEN 'DEBIT_INTEREST'
                            WHEN 'withdraw' THEN 'WITHDRAW'
                            ELSE
                                NULL
                        END);
        pl_msg_clob := pl_msg_clob || '[pkg_tastytrade_load][process_portfolio_tran][pl_tran_type] ' || pl_tran_type || pl_new_line;
        IF pl_tran_type in ('DEPOSIT') THEN
            pl_tran_source := 'Bank';
        elsif pl_tran_type in ('DEPOSIT','CREDIT_INTEREST','DEBIT_INTEREST') THEN
            pl_tran_source := 'Broker';
        elsif pl_tran_type in ('DIVIDEND') THEN
            pl_tran_source := p_imp_trade_rec.underlying_symbol;
        end if;

        pl_msg_clob := pl_msg_clob || '[pkg_tastytrade_load][process_portfolio_tran][p_imp_trade_rec.executed_at] ' || p_imp_trade_rec.executed_at || pl_new_line;
        pl_msg_clob := pl_msg_clob || '[pkg_tastytrade_load][process_portfolio_tran][pl_tran_source] ' || pl_tran_source || pl_new_line;
        pl_msg_clob := pl_msg_clob || '[pkg_tastytrade_load][process_portfolio_tran][p_imp_trade_rec.value] ' || p_imp_trade_rec.value || pl_new_line;
        pl_msg_clob := pl_msg_clob || '[pkg_tastytrade_load][process_portfolio_tran][p_imp_trade_rec.description] ' || p_imp_trade_rec.description || pl_new_line;
        insert into mts_portfolio_tran ( user_id, portfolio_id, tran_date, tran_type, tran_source,amount, remarks )
        values ( p_imp_log_rec.user_id, p_imp_log_rec.portfolio_id, TO_UTC_TIMESTAMP_TZ(p_imp_trade_rec.executed_at), pl_tran_type, pl_tran_source,to_number(p_imp_trade_rec.value), p_imp_trade_rec.description );

        p_status := 'S';
    exception
        when others then 
            p_status := 'E';
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_tastytrade_load',
                P_PROCESS_NAME => 'process_portfolio_tran',
                P_LOG_TYPE => 'E',
                P_MSG_CLOB => pl_msg_clob,
                P_MSG_STR => '[LINE_NUMBER][ERROR] => [' || p_imp_trade_rec.line_number || '] ['|| SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250) || ']'
            );
    END;

    --------------------------------------------------------------------------------------
    --    PROCEDURE : process_transaction
    --------------------------------------------------------------------------------------
    procedure process_transaction(p_import_log_id  mts_import_trade_log.id%type)
    as
        pl_import_log_rec           mts_import_trade_log%rowtype;
        pl_ws_trade_rec             mts_ws_trade%rowtype;
        pl_rec_count                number := 0;
        pl_success_count            number := 0;
        pl_failed_count             number := 0;
        pl_open_trade_count         number := 0;
        pl_log_msg                  varchar2(1000);
        pl_start_time               timestamp := current_timestamp;
        pl_end_time                 timestamp;
        pl_load_status              mts_import_trade_log.load_status%type := 'S';
        pl_overall_load_status      mts_import_trade_log.load_status%type;
        
        l_tmp_action_code           mts_trade_action.code%type;

        cursor c1 is
        select  *
        from    v_mts_tastytrade_import_data
        where   import_trade_log_id = p_import_log_id
        --and     col_2 is not null 
        and     load_status = 'N' 
        order by TO_UTC_TIMESTAMP_TZ(executed_at) asc;
    begin
        begin
            select  *
            into    pl_import_log_rec 
            from    mts_import_trade_log 
            where   id = p_import_log_id;
        exception
            when no_data_found then
                raise_application_error(-20000, '[process_transaction] Wrong import log id.', true);
        end;

        -- get imported data from import_trade_data.
        for c1rec in c1 loop
            begin
                pl_rec_count := pl_rec_count + 1;
                IF ( lower(c1rec.transaction_type) = 'money movement' and lower(c1rec.transaction_sub_type) in ('deposit','dividend','credit interest','debit interest','withdraw') )  THEN

                    process_portfolio_tran( p_imp_trade_rec => c1rec,
                                            p_imp_log_rec => pl_import_log_rec,
                                            p_status => pl_load_status);
                ELSE
                    process_trade_tran( p_imp_trade_rec => c1rec,
                                        p_imp_log_rec => pl_import_log_rec,                                           
                                        p_status => pl_load_status); 
                END IF;
                
                IF pl_load_status = 'S' THEN
                    pl_success_count := pl_success_count + 1;
                ELSE
                    pl_failed_count := pl_failed_count + 1; 
                END IF;
                
                        
                update  mts_import_trade_data
                set     load_status = pl_load_status,
                        log_msg = DECODE(pl_load_status,'S','SUCCESS','ERROR')
                where   import_trade_log_id = p_import_log_id
                and     line_number = c1rec.line_number;
            end;
            
        end loop;

        IF ( pl_success_count > 0 and pl_failed_count > 0  ) THEN
            pl_overall_load_status := 'P' ;   
        ELSIF (pl_success_count > 0 and pl_failed_count = 0 ) THEN
            pl_overall_load_status := 'S' ;
        ELSIF (pl_success_count = 0 and pl_failed_count > 0 ) THEN
            pl_overall_load_status := 'E' ;
        END IF;


        update  mts_import_trade_log 
        set     start_time      = pl_start_time,
                end_time        = current_timestamp,
                record_count    = pl_rec_count,
                success_count   = pl_success_count,
                failed_count    = pl_failed_count,
                load_status     = pl_overall_load_status,
                log_msg         = DECODE(pl_overall_load_status,'S','SUCCESS','E','ERROR','P', 'PARTIAL SUCCESS',null)
        where   id = p_import_log_id;
        
    end process_transaction; 
    
    --------------------------------------------------------------------------------------
    --    PROCEDURE : tastytrade_sync_trade
    --------------------------------------------------------------------------------------
    procedure sync_transaction (    
        p_login         varchar2,
        p_password      varchar2,
        p_user_id       mts_user.user_id%type,
        p_broker_id     mts_broker.id%type,
        p_portfolio_id  mts_portfolio.id%type,
        p_import_log_id out mts_import_trade_log.id%type
    ) 
    as 
        pl_token            varchar2(250);
        pl_import_log_id    mts_import_trade_log.id%type;
        pl_rec_count        number;
        pl_load_date        timestamp := current_timestamp;
    begin 

        pl_token := pkg_tastytrade_api.get_session_token(
                        p_user_id  => p_user_id,
                        p_login  => p_login ,
                        p_password => p_password    
                    );

        pkg_tastytrade_api.get_transaction( 
                            p_token => pl_token, 
                            p_portfolio_id  => p_portfolio_id);

        
        -- load data to import_trade_data table.
        begin 
            select count(*) into pl_rec_count
            from   mts_tastytrade_tran_stg
            where  portfolio_id = p_portfolio_id;

            if (pl_rec_count > 0 ) then
                -- create record in mts_trade_import_log table
                insert into mts_import_trade_log (user_id,portfolio_id,broker_id,import_type,load_date)
                values (p_user_id,p_portfolio_id,p_broker_id,'API',pl_load_date) returning id into pl_import_log_id;

                insert into mts_import_trade_data ( import_trade_log_id, line_number,
                                                col_1, col_2, col_3, col_4, col_5, col_6,
                                                col_7, col_8, col_9, col_10, col_11, 
                                                col_12, col_13, col_14, col_15, col_16 ,
                                                col_17, col_18, col_19 )        

                select  pl_import_log_id,line_number,
                        account_number, symbol, instrument_type, underlying_symbol,transaction_type,transaction_sub_type,  
                        description, action, quantity,price, executed_at, 
                        value, value_effect, regulatory_fees, clearing_fees, net_value,
                        commission,order_id ,currency
                from   mts_tastytrade_tran_stg
                where  portfolio_id = p_portfolio_id;

                commit;
            end if;
        exception
            when no_data_found then
                null;
        end;
        dbms_output.put_line('[pkg_tastytrade_load][sync_transaction][pl_import_log_id] ' || pl_import_log_id );
        if ( pl_import_log_id is not null) then
            process_transaction(p_import_log_id => pl_import_log_id);
            p_import_log_id := pl_import_log_id;
        end if;

    exception
        when others then   
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_tastytrade_load',
                P_PROCESS_NAME => 'sync_transaction',
                P_LOG_TYPE => 'E',
                P_MSG_STR => SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250)
            );
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250), true);     
    end sync_transaction;


end pkg_tastytrade_load;
/