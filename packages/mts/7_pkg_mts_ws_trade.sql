/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
 create or replace package pkg_mts_ws_trade as

    function  get_seq_no_nextval(p_user_id            mts_ws_trade.user_id%type)  return number;

    function get_action_code(   p_portfolio_id  mts_trade_tran.portfolio_id%type,
                                p_trade_code    mts_trade_tran.trade_code%type) return mts_trade_action.code%type;

    procedure truncate_ws_trade(p_user_id             mts_ws_trade.user_id%type);
    
    procedure build_ws_trade_from_Strategy(p_user_id        mts_ws_trade.user_id%type,
                                           p_portfolio_id   mts_portfolio.id%type,
                                           p_strategy_id    mts_strategy.id%type);

    procedure add_ws_trade(     p_user_id             mts_ws_trade.user_id%type,
                                p_portfolio_id        mts_ws_trade.portfolio_id%type ,
                                p_tran_date           mts_ws_trade.tran_date%type default null,
                                p_trade_code          mts_ws_trade.trade_code%type  default null , 
                                p_symbol              mts_ws_trade.trade_code%type  default null , 
                                p_exp_date            mts_ws_trade.exp_date%type default null, 
                                p_order_type          mts_ws_trade.order_type%type  default null , 
                                p_strike              mts_ws_trade.strike%type    default null , 
                                p_action_code         mts_ws_trade.action_code%type  default null , 
                                p_qty                 mts_ws_trade.qty%type    default null , 
                                p_price               mts_ws_trade.price%type    default null, 
                                p_commission          mts_ws_trade.commission%type    default null,
                                p_fees                mts_ws_trade.fees%type    default null,         
                                p_source_order_id     mts_ws_trade.source_order_id%type  default null ,
                                p_group_name          mts_ws_trade.group_name%type  default null
                            );

    procedure update_ws_trade(  p_user_id             mts_ws_trade.user_id%type,
                                p_seq_no              mts_ws_trade.seq_no%type,
                                p_tran_date           mts_ws_trade.tran_date%type default null,
                                p_trade_code          mts_ws_trade.trade_code%type  default null , 
                                p_symbol              mts_ws_trade.trade_code%type  default null , 
                                p_exp_date            mts_ws_trade.exp_date%type default null, 
                                p_order_type          mts_ws_trade.order_type%type  default null , 
                                p_strike              mts_ws_trade.strike%type    default null , 
                                p_action_code         mts_ws_trade.action_code%type  default null , 
                                p_qty                 mts_ws_trade.qty%type    default null , 
                                p_price               mts_ws_trade.price%type    default null, 
                                p_commission          mts_ws_trade.commission%type    default null,
                                p_fees                mts_ws_trade.fees%type    default null,         
                                p_source_order_id     mts_ws_trade.source_order_id%type  default null ,
                                p_group_name          mts_ws_trade.group_name%type  default null
                            );
    procedure delete_ws_trade(  p_user_id  mts_ws_trade.user_id%type,
                                p_seq_no   mts_ws_trade.seq_no%type);

    procedure resequence_ws_trade(p_user_id  mts_ws_trade.user_id%type );

    procedure finalize_trade(p_user_id mts_ws_trade.user_id%type);
    


end pkg_mts_ws_trade;
/
 /*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
 create or replace package body pkg_mts_ws_trade as

    function  get_seq_no_nextval(p_user_id            mts_ws_trade.user_id%type) return number
    as
        pl_return       number;
    begin
        begin
            select  nvl(max(seq_no),0) + 1
            into    pl_return
            from    mts_ws_trade
            where   user_id = p_user_id;

        exception
            when no_data_found then
                pl_return := 1;

        end;
        return pl_return;
    end;
    -- get_action_code
    function get_action_code(   p_portfolio_id  mts_trade_tran.portfolio_id%type,
                                p_trade_code    mts_trade_tran.trade_code%type) return mts_trade_action.code%type
    as
         
        l_return       mts_trade_action.code%type ; 
    begin 
 
        begin 
            select  action_code  
            into    l_return 
            from    mts_ws_trade
            where   portfolio_id = p_portfolio_id
            and     pkg_mts_util.get_trade_code( symbol, exp_date, order_type, strike) = p_trade_code
            and     action_code in ( 'BTO','STO')
            order by 1 desc
            fetch first 1 rows only; 
        exception 
            when no_data_found then 
                l_return := null; 
        end; 
 
        return l_return; 
    end get_action_code; 

    /***************************************************************************
        procedure: merge_trade
     ***************************************************************************/
    procedure truncate_ws_trade(p_user_id  mts_ws_trade.user_id%type)
    as
    begin
        delete from mts_ws_trade where user_id = p_user_id;
        commit;

    end truncate_ws_trade;


    /***************************************************************************
        procedure: build_ws_trade_from_Strategy
     ***************************************************************************/
    procedure build_ws_trade_from_Strategy(p_user_id        mts_ws_trade.user_id%type,
                                           p_portfolio_id   mts_portfolio.id%type,
                                           p_strategy_id    mts_strategy.id%type)
    as
    begin

        truncate_ws_trade(p_user_id);
        --
        insert into mts_ws_trade (user_id, seq_no, portfolio_id, symbol, exp_date, order_type, strike, action_code, qty)
        select p_user_id, rownum, p_portfolio_id, symbol, exp_date, order_type, strike, action_code, qty
        from   mts_strategy_template
        where   strategy_id = p_strategy_id;
        --
        commit;
    
    
    end build_ws_trade_from_Strategy;

    /***************************************************************************
        procedure: add_ws_trade
     ***************************************************************************/
    procedure add_ws_trade(     p_user_id             mts_ws_trade.user_id%type,
                                p_portfolio_id        mts_ws_trade.portfolio_id%type ,
                                p_tran_date           mts_ws_trade.tran_date%type default null,
                                p_trade_code          mts_ws_trade.trade_code%type  default null , 
                                p_symbol              mts_ws_trade.trade_code%type  default null , 
                                p_exp_date            mts_ws_trade.exp_date%type default null, 
                                p_order_type          mts_ws_trade.order_type%type  default null , 
                                p_strike              mts_ws_trade.strike%type    default null , 
                                p_action_code         mts_ws_trade.action_code%type  default null , 
                                p_qty                 mts_ws_trade.qty%type    default null , 
                                p_price               mts_ws_trade.price%type    default null, 
                                p_commission          mts_ws_trade.commission%type    default null,
                                p_fees                mts_ws_trade.fees%type    default null,         
                                p_source_order_id     mts_ws_trade.source_order_id%type  default null ,
                                p_group_name          mts_ws_trade.group_name%type  default null
                            )
    as
    begin
        insert into mts_ws_trade ( user_id ,
                                seq_no,
                                portfolio_id,
                                tran_date,
                                symbol,
                                exp_date,
                                order_type,
                                strike,
                                action_code,
                                qty,
                                price,
                                commission,
                                fees,
                                source_order_id,
                                group_name 
                            )
        values              (   p_user_id ,
                                get_seq_no_nextval(p_user_id),
                                p_portfolio_id,
                                p_tran_date,
                                p_symbol,
                                p_exp_date,
                                p_order_type,
                                p_strike,
                                p_action_code,
                                p_qty,
                                p_price,
                                p_commission,
                                p_fees,
                                p_source_order_id,
                                p_group_name
                            ) ;
        
        commit;


    end add_ws_trade;


    /***************************************************************************
        procedure: update_ws_trade
     ***************************************************************************/
    procedure update_ws_trade(  p_user_id             mts_ws_trade.user_id%type,
                                p_seq_no              mts_ws_trade.seq_no%type,
                                p_tran_date           mts_ws_trade.tran_date%type default null,
                                p_trade_code          mts_ws_trade.trade_code%type  default null , 
                                p_symbol              mts_ws_trade.trade_code%type  default null , 
                                p_exp_date            mts_ws_trade.exp_date%type default null, 
                                p_order_type          mts_ws_trade.order_type%type  default null , 
                                p_strike              mts_ws_trade.strike%type    default null , 
                                p_action_code         mts_ws_trade.action_code%type  default null , 
                                p_qty                 mts_ws_trade.qty%type    default null , 
                                p_price               mts_ws_trade.price%type    default null, 
                                p_commission          mts_ws_trade.commission%type    default null,
                                p_fees                mts_ws_trade.fees%type    default null,         
                                p_source_order_id     mts_ws_trade.source_order_id%type  default null ,
                                p_group_name          mts_ws_trade.group_name%type  default null
                            )
    as
    begin
        update  mts_ws_trade
        set     tran_date = nvl(p_tran_date,tran_date),
                symbol = nvl(p_symbol,symbol),
                exp_date = nvl(p_exp_date,exp_date),
                order_type = nvl(p_order_type,order_type),
                strike = nvl(p_strike,strike),
                action_code = nvl(p_action_code,action_code),
                qty = nvl(p_qty,qty),
                price = nvl(p_price,price),
                commission = nvl(p_commission,commission),
                fees = nvl(p_fees,fees),
                source_order_id = nvl(p_source_order_id,source_order_id) ,
                group_name = nvl(p_group_name,group_name)                
        where   user_id  = p_user_id
        and     seq_no = p_seq_no; 

        commit;

    end update_ws_trade;


    /***************************************************************************
        procedure: delete_ws_trade
     ***************************************************************************/
    procedure delete_ws_trade(  p_user_id  mts_ws_trade.user_id%type,
                                p_seq_no   mts_ws_trade.seq_no%type
                              )
                            
    as
    begin
        delete from mts_ws_trade where user_id = p_user_id and seq_no = p_seq_no;

        commit;

    end delete_ws_trade;


    /***************************************************************************
        procedure: resequence_ws_trade
     ***************************************************************************/
    procedure resequence_ws_trade(p_user_id  mts_ws_trade.user_id%type )
    as
    begin
        update mts_ws_trade set seq_no = 0
        where  user_id = p_user_id;

        update mts_ws_trade set seq_no = get_seq_no_nextval(p_user_id)
        where  user_id = p_user_id;

        commit;

    end resequence_ws_trade;

    /***************************************************************************
        procedure: finalize_trade
     ***************************************************************************/
    procedure finalize_trade(p_user_id mts_ws_trade.user_id%type)
    as
    begin
        insert into mts_trade_tran ( user_id,
                                portfolio_id,
                                tran_date,
                                symbol,
                                exp_date,
                                order_type,
                                strike,
                                action_code,
                                qty,
                                price,
                                commission,
                                fees,
                                source_order_id,
                                notes
                            )
        select  user_id,
                portfolio_id,
                tran_date,
                symbol,
                exp_date,
                order_type,
                strike,
                action_code,
                qty,
                price,
                commission,
                fees,
                source_order_id ,
                notes
        from    mts_ws_trade
        where   user_id = p_user_id 
        order by tran_date asc;

        truncate_ws_trade(p_user_id);

        commit;
    exception 
        when others then   
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_mts_ws_trade',
                P_PROCESS_NAME => 'finalize_trade',
                P_LOG_TYPE => 'E',
                P_MSG_STR => SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250)
            );
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250), true); 
    end;

end pkg_mts_ws_trade;
/