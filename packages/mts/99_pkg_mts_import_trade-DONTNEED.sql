/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package  pkg_mts_import_trade as
  

    procedure create_import_log (
        p_import_log_id         out mts_import_trade_log.id%type,
        p_user_id               mts_import_trade_log.user_id%type,
        p_portfolio_id          mts_import_trade_log.portfolio_id%type,
        p_broker_id             mts_import_trade_log.broker_id%type,
        p_load_date             mts_import_trade_log.load_date%type default current_timestamp
    );

    
    

    procedure load_broker_trade_data(   p_user_id           mts_user.user_id%type,
                                        p_broker_id        mts_broker.id%type,
                                        p_portfolio_id     mts_portfolio.id%type,
                                        p_import_log_id    out mts_import_trade_log.id%type );

    PROCEDURE   sync_trade_data(    p_user_id            mts_user.user_id%type,
                                    p_portfolio_id       mts_portfolio.id%type,
                                    p_import_log_id      out mts_import_trade_log.id%type );


    

end pkg_mts_import_trade;
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_import_trade as
    --------------------------------------------------------------------------------------
    --    PROCEDURE : create_import_log
    --------------------------------------------------------------------------------------
    procedure create_import_log(
        p_import_log_id         out mts_import_trade_log.id%type,
        p_user_id               mts_import_trade_log.user_id%type,
        p_portfolio_id          mts_import_trade_log.portfolio_id%type,
        p_broker_id             mts_import_trade_log.broker_id%type,
        p_load_date             mts_import_trade_log.load_date%type default current_timestamp
    )
    as
       
    begin
        insert into mts_import_trade_log (user_id,portfolio_id,broker_id,load_date)
        values (p_user_id,p_portfolio_id,p_broker_id,p_load_date) returning id into p_import_log_id;

    end create_import_log;
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
    --    PROCEDURE : load_import_trade_data_to_ws
    --------------------------------------------------------------------------------------
    procedure load_import_trade_data_to_ws(p_import_log_id  mts_import_trade_log.id%type)
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
        
        l_tmp_action_code           mts_trade_action.code%type;

        cursor c1 is
        select * 
        from    mts_import_trade_data
        where   import_trade_log_id = p_import_log_id
        and     col_2 is not null 
        and     load_status = 'N' 
        order by TO_UTC_TIMESTAMP_TZ(col_10) asc;
    begin
        begin
            select  *
            into    pl_import_log_rec 
            from    mts_import_trade_log 
            where   id = p_import_log_id;
        exception
            when no_data_found then
                raise_application_error(-20000, '[load_import_trade_data_to_ws] Wrong import log id.', true);
        end;

        -- get imported data from import_trade_data.
        for c1rec in c1 loop
            begin
                reset_mts_ws_trade_record(p_rec_id => pl_ws_trade_rec);
                pl_rec_count := pl_rec_count + 1;
                pl_ws_trade_rec.seq_no := c1rec.line_number ;
                pl_ws_trade_rec.user_id         := pl_import_log_rec.user_id;
                pl_ws_trade_rec.portfolio_id    := pl_import_log_rec.portfolio_id;
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.user_id] = ' ||  pl_ws_trade_rec.user_id);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.portfolio_id] = ' ||  pl_ws_trade_rec.portfolio_id);
                -- get tran_date
                select TO_UTC_TIMESTAMP_TZ(c1rec.col_10) into pl_ws_trade_rec.tran_date from dual;
                --pl_ws_trade_rec.tran_date       := TO_UTC_TIMESTAMP_TZ(c1rec.col_10) ;
                pl_ws_trade_rec.symbol          := trim(substr(replace(c1rec.col_2,'.',''),1,6));
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.tran_date] = ' ||  pl_ws_trade_rec.tran_date);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.symbol] = ' ||  pl_ws_trade_rec.symbol);
                    
                -- if instrument_type is options then get symbol, exp_date, order_type and strike price from symbol column.
                if ( lower(c1rec.col_3) like '%future option%')  then
                    pl_ws_trade_rec.exp_date    := to_timestamp(substr(c1rec.col_2,14,6),'RRMMDD');
                    if ( substr(c1rec.col_2,20,1) = 'C') then
                        pl_ws_trade_rec.order_type := 'CALL';
                    else
                        pl_ws_trade_rec.order_type := 'PUT';
                    end if;
                    pl_ws_trade_rec.strike      := to_number(substr(c1rec.col_2,21));   
                    dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.exp_date] = ' ||  pl_ws_trade_rec.exp_date);
                    dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.strike] = ' ||  pl_ws_trade_rec.strike);
                    dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.order_type] = ' ||  pl_ws_trade_rec.order_type);    
                elsif   ( lower(c1rec.col_3) like '%equity option%')  then
                    pl_ws_trade_rec.exp_date    := to_timestamp(substr(c1rec.col_2,7,6),'RRMMDD');
                    if ( substr(c1rec.col_2,13,1) = 'C') then
                        pl_ws_trade_rec.order_type := 'CALL';
                    else
                        pl_ws_trade_rec.order_type := 'PUT';
                    end if;  
                    pl_ws_trade_rec.strike      := to_number(substr(c1rec.col_2,14))/1000;       
                            
                elsif ( lower(c1rec.col_3) like ('%future%')) then
                    pl_ws_trade_rec.order_type := 'FUTURE';
                elsif ( lower(c1rec.col_3) like ('%bond%')) then
                    pl_ws_trade_rec.order_type := 'BOND';
                elsif ( lower(c1rec.col_3) like ('%equity%')) then
                    pl_ws_trade_rec.order_type := 'EQUITY';
                else
                    pl_ws_trade_rec.order_type := 'EQUITY';
                end if;
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.exp_date] = ' ||  pl_ws_trade_rec.exp_date);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.strike] = ' ||  pl_ws_trade_rec.strike);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.order_type] = ' ||  pl_ws_trade_rec.order_type);

                
                -- get action_code
                if lower(trim(c1rec.col_7)) in ( 'buy to open','buy_to_open') then
                    pl_ws_trade_rec.action_code := 'BTO';
                elsif lower(trim(c1rec.col_7)) in ( 'sell to open','sell_to_open') then
                    pl_ws_trade_rec.action_code := 'STO';
                elsif lower(trim(c1rec.col_7)) in ( 'buy to close','buy_to_close') then
                    pl_ws_trade_rec.action_code := 'BTC';
                elsif lower(trim(c1rec.col_7)) in ( 'sell to close','sell_to_close') then
                    pl_ws_trade_rec.action_code := 'STC';
                elsif lower(trim(c1rec.col_7)) in ( 'buy') then
                    pl_ws_trade_rec.action_code := 'BUY';
                elsif lower(trim(c1rec.col_7)) in ( 'sell') then
                    pl_ws_trade_rec.action_code := 'SELL';                
                elsif ( lower(c1rec.col_6) like '%removal of option%') then
                    pl_ws_trade_rec.action_code := 'REMO';
                else
                    pl_ws_trade_rec.action_code := NULL;
                end if;
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.action_code] = ' ||  pl_ws_trade_rec.action_code);

                -- get quantity
                pl_ws_trade_rec.qty := to_number(c1rec.col_8);
                -- get price
                if ( lower(c1rec.col_12) = 'debit'  ) then
                    pl_ws_trade_rec.price := to_number(c1rec.col_11) *-1;
                else  
                    pl_ws_trade_rec.price := to_number(c1rec.col_11);
                end if;
                -- get commission
                pl_ws_trade_rec.commission := to_number(c1rec.col_16)*-1 ;
                -- get fees
                pl_ws_trade_rec.fees := to_number(c1rec.col_13)*-1  + to_number(c1rec.col_14)*-1 ;
                -- order id
                pl_ws_trade_rec.source_order_id := c1rec.col_17;
                pl_ws_trade_rec.notes := c1rec.col_6; 
                pl_ws_trade_rec.trade_code := pkg_mts_util.get_trade_code(
                                                                            p_symbol => pl_ws_trade_rec.symbol,
                                                                            p_exp_date => pl_ws_trade_rec.exp_date,
                                                                            p_order_type => pl_ws_trade_rec.order_type,
                                                                            p_strike => pl_ws_trade_rec.strike
                                                                            );
                
                if ( pl_ws_trade_rec.action_code = 'REMO') THEN
                    
                    l_tmp_action_code := pkg_mts_trade.get_action_code(
                                                                        p_portfolio_id => pl_ws_trade_rec.portfolio_id,
                                                                        p_trade_code => pl_ws_trade_rec.trade_code);

                    if ( l_tmp_action_code is null) then   
                        l_tmp_action_code := pkg_mts_ws_trade.get_action_code(
                                                                        p_portfolio_id => pl_ws_trade_rec.portfolio_id,
                                                                        p_trade_code => pl_ws_trade_rec.trade_code);
                    end if;
                    
                    dbms_output.put_line('[load_import_trade_data_to_ws].[l_tmp_action_code] = ' || l_tmp_action_code); 
                    if ( nvl(l_tmp_action_code,'XXX') = 'BTO') then
                        pl_ws_trade_rec.qty := abs(pl_ws_trade_rec.qty) *-1 ;
                        dbms_output.put_line('[1.load_import_trade_data_to_ws].[pl_ws_trade_rec.qty--] = ' || pl_ws_trade_rec.qty );
                    elsif ( nvl(l_tmp_action_code,'XXX') = 'STO' )  then
                        dbms_output.put_line('[2.load_import_trade_data_to_ws].[pl_ws_trade_rec.qty--] = ' || pl_ws_trade_rec.qty );
                        pl_ws_trade_rec.qty := abs(pl_ws_trade_rec.qty);
                    end if;
                    

                end if;
                

                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.qty] = ' ||  pl_ws_trade_rec.qty);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.price] = ' ||  pl_ws_trade_rec.price);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.commission] = ' ||  pl_ws_trade_rec.commission);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.fees] = ' ||  pl_ws_trade_rec.fees);
                dbms_output.put_line('[load_import_trade_data_to_ws].[pl_ws_trade_rec.source_order_id] = ' ||  pl_ws_trade_rec.source_order_id);

                insert into mts_ws_trade values pl_ws_trade_rec;
                pl_success_count := pl_success_count + 1;

                pl_load_status := 'E';           
                        
                update  mts_import_trade_data
                set     load_status = 'S',
                        log_msg = 'SUCCESS'
                where   import_trade_log_id = p_import_log_id
                and     line_number = c1rec.line_number;

            exception
                when others then
                    

                    pl_log_msg := to_char(sqlcode) || ' - ' || substr(sqlerrm,1,64);
                    pl_failed_count := pl_failed_count + 1; 
                    pl_load_status := 'E';           
                        
                    update  mts_import_trade_data
                    set     load_status = 'E',
                            log_msg = pl_log_msg
                    where   import_trade_log_id = p_import_log_id
                    and     line_number = c1rec.line_number;

            end;
        end loop;

        update  mts_import_trade_log 
        set     start_time      = pl_start_time,
                end_time        = current_timestamp,
                record_count    = pl_rec_count,
                success_count   = pl_success_count,
                failed_count    = pl_failed_count,
                load_status     = pl_load_status,
                log_msg         = pl_log_msg
        where   id = p_import_log_id;
        
    end load_import_trade_data_to_ws; 

    
    --------------------------------------------------------------------------------------
    --    PROCEDURE : load_tastytrade_data
    --------------------------------------------------------------------------------------
    PROCEDURE   load_tastytrade_data(p_import_log_id        out mts_import_trade_log.id%type,
                                     p_user_id              mts_user.user_id%type,
                                     p_broker_id            mts_broker.id%type,
                                     p_portfolio_id         mts_portfolio.id%type)
    AS
        pl_rec_count         number; 
        pl_import_log_id         mts_import_trade_log.id%type;
    BEGIN
        -- Load Trade Transaction from TastyTrade Staging table to mts_import_trade_log/data table.
        begin 
            select count(*) into pl_rec_count
            from   mts_tastytrade_tran_stg
            where  portfolio_id = p_portfolio_id;

            if (pl_rec_count > 0 ) then
                -- create record in mts_trade_import_log table
                create_import_log(
                                    p_import_log_id => pl_import_log_id ,
                                    p_user_id => p_user_id,
                                    p_portfolio_id => p_portfolio_id,
                                    p_broker_id => p_broker_id
                );

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

                p_import_log_id := pl_import_log_id;

                commit;
            else  
                p_import_log_id := null;
            end if;
        exception
            when no_data_found then
                null;
        end;
    
    end load_tastytrade_data;

    --------------------------------------------------------------------------------------
    --    PROCEDURE : load_broker_trade_data
    --------------------------------------------------------------------------------------
    procedure load_broker_trade_data(   p_user_id           mts_user.user_id%type,
                                        p_broker_id        mts_broker.id%type,
                                        p_portfolio_id     mts_portfolio.id%type,
                                        p_import_log_id    out mts_import_trade_log.id%type )

    AS
        pl_broker_rec       mts_broker%rowtype;
        pl_import_log_id    mts_import_trade_log.id%type;
    BEGIN
        
        BEGIN
                select  *
                into    pl_broker_rec
                from    mts_broker
                where   id = p_broker_id;

                if ( pl_broker_rec.id is null ) then
                    raise_application_error(-20000, 'Broker is not set for auto sync.', true); 
                end if;
        EXCEPTION
            when no_data_found then 
                raise_application_error(-20000, 'Broker not found.', true);   
        END;

        
        if ( lower(pl_broker_rec.broker_name) = 'tastytrade' ) THEN
            load_tastytrade_data(   p_import_log_id => pl_import_log_id,
                                    p_user_id => p_user_id,
                                    p_broker_id => p_broker_id,
                                    p_portfolio_id => pl_import_log_id) ;  
        end if;
       
   
        p_import_log_id := pl_import_log_id;
        
    END load_broker_trade_data;


    --------------------------------------------------------------------------------------
    --    PROCEDURE : sync_trade_data
    --------------------------------------------------------------------------------------
    PROCEDURE   sync_trade_data(    p_user_id            mts_user.user_id%type,
                                    p_portfolio_id       mts_portfolio.id%type,
                                    p_token              varchar2,
                                    p_import_log_id      out mts_import_trade_log.id%type )
    AS  
        pl_import_log_id     mts_import_trade_log.id%type;
        pl_portfolio_rec     mts_portfolio%rowtype;
         
    BEGIN

        BEGIN
                select  *
                into    pl_portfolio_rec
                from    mts_portfolio
                where   id = p_portfolio_id;

                if ( pl_portfolio_rec.broker_id is null OR pl_portfolio_rec.account_num is null) then
                    raise_application_error(-20000, 'Portfolio is not set for auto sync.', true); 
                end if;
        EXCEPTION
            when no_data_found then 
                raise_application_error(-20000, 'Portfolio not found.', true);   
        END;

        -- Get Transaction from TastyTrade
        pkg_tastytrade_api.get_transaction(  p_portfolio_id => p_portfolio_id );

        load_broker_trade_data( p_user_id => p_user_id,
                                p_broker_id => pl_portfolio_rec.broker_id,
                                p_portfolio_id => p_portfolio_id,
                                p_import_log_id => pl_import_log_id);

        -- Move data from mts_import_trade_data table to mts_ws_trade ( Trade Workspace ) 
        if ( pl_import_log_id is not null ) then
            DBMS_OUTPUT.PUT_LINE('[pkg_mts_import_trade][sync_trade_data][pl_import_log_id] = ' || pl_import_log_id);
            load_import_trade_data_to_ws(p_import_log_id => pl_import_log_id);

            -- Finalize Trade.
            pkg_mts_ws_trade.finalize_trade(p_user_id=> p_user_id);
        end if;

    END sync_trade_data;

    

end pkg_mts_import_trade;
/