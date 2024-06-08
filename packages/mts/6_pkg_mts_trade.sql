/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_trade as

    function get_action( p_code     mts_trade_action.code%type ) return mts_trade_action.name%type; 
    function get_order_type( p_code     mts_order_type.code%type ) return mts_order_type.name%type ;
    function get_portfolio_name(p_portfolio_id  mts_portfolio.id%type) return mts_portfolio.portfolio_name%type;
    function get_trade_code( 
                             p_symbol   mts_trade_tran.symbol%type,
                             p_exp_date   mts_trade_tran.exp_date%type,
                             p_order_type   mts_trade_tran.order_type%type,
                             p_strike   mts_trade_tran.strike%type

                            ) return varchar2;

    function get_action_code(   p_portfolio_id  mts_trade_tran.portfolio_id%type,
                                p_trade_code    mts_trade_tran.trade_code%type) return mts_trade_action.code%type;

    procedure merge_trade_tran(
            p_trade_tran_id         in  out mts_trade_tran.id%type,
            p_portfolio_id          in  mts_trade_tran.portfolio_id%type     default null,
            p_tran_date             in  mts_trade_tran.tran_date%type        default null,
            p_symbol                in  mts_trade_tran.symbol%type           default null,
            p_exp_date              in  mts_trade_tran.exp_date%type         default null,
            p_order_type            in  mts_trade_tran.order_type%type       default null,
            p_strike                in  mts_trade_tran.strike%type           default null,
            p_action_code           in  mts_trade_tran.action_code%type      default null,
            p_qty                   in  mts_trade_tran.qty%type              default null,
            p_price                 in  mts_trade_tran.price%type            default null,
            p_commission            in  mts_trade_tran.commission%type       default null,
            p_fees                  in  mts_trade_tran.fees%type             default null,
            p_source_order_id       in  mts_trade_tran.source_order_id%type  default null
        );

    

end pkg_mts_trade;
/
/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
 create or replace package body pkg_mts_trade as
    /***************************************************************************
        procedure: get_action
     ***************************************************************************/
    function get_action( p_code mts_trade_action.code%type ) return mts_trade_action.name%type
    as 
        pl_return       mts_trade_action.name%type; 
    begin 
 
        begin 
            select name into pl_return 
            from mts_trade_action 
            where code = P_code; 
        exception 
            when no_data_found then 
                pl_return := 'n/a'; 
        end; 
 
        return pl_return; 
    end get_action; 
 
    
    /***************************************************************************
        procedure: get_order_type
     ***************************************************************************/
    function get_order_type( p_code mts_order_type.code%type ) return mts_order_type.name%type 
    as 
        pl_return       mts_order_type.name%type ; 
    begin 
 
        begin 
            select  name  
            into    pl_return 
            from    mts_order_type 
            where   code = p_code; 
        exception 
            when no_data_found then 
                pl_return := 'n/a'; 
        end; 
 
        return pl_return; 
    end get_order_type; 

    function get_portfolio_name(p_portfolio_id  mts_portfolio.id%type) return mts_portfolio.portfolio_name%type
    as 
        pl_return       mts_portfolio.portfolio_name%type ; 
    begin 
 
        begin 
            select  portfolio_name  
            into    pl_return 
            from    mts_portfolio 
            where   id = p_portfolio_id; 
        exception 
            when no_data_found then 
                pl_return := 'n/a'; 
        end; 
 
        return pl_return; 
    end get_portfolio_name; 

    function get_action_code(   p_portfolio_id  mts_trade_tran.portfolio_id%type,
                                p_trade_code    mts_trade_tran.trade_code%type) return mts_trade_action.code%type
    as
        l_return       mts_trade_action.code%type ; 
    begin 
 
        begin 
            select  action_code  
            into    l_return 
            from    mts_trade_tran
            where   portfolio_id = p_portfolio_id
            and     trade_code = p_trade_code
            and     action_code in ( 'BTO','STO')
            order by 1 desc
            fetch first 1 rows only; 
        exception 
            when no_data_found then 
                l_return := null; 
        end; 
 
        return l_return; 
    end get_action_code; 

    function get_trade_code( 
                             p_symbol   mts_trade_tran.symbol%type,
                             p_exp_date   mts_trade_tran.exp_date%type,
                             p_order_type   mts_trade_tran.order_type%type,
                             p_strike   mts_trade_tran.strike%type

                            ) return varchar2

    as
    begin
        return trim(p_symbol) || '-' || nvl(to_char(p_exp_date,'YYYYMMDD'),'99991231')|| '-'|| nvl(p_order_type,'E') || '-' || to_char(NVL(p_strike,'999999'));
    end ;
     

    /***************************************************************************
        procedure: merge_trade_tran
     ***************************************************************************/
    procedure merge_trade_tran(
            p_trade_tran_id         in  out mts_trade_tran.id%type,
            p_portfolio_id          in  mts_trade_tran.portfolio_id%type     default null,
            p_tran_date             in  mts_trade_tran.tran_date%type        default null,
            p_symbol                in  mts_trade_tran.symbol%type           default null,
            p_exp_date              in  mts_trade_tran.exp_date%type         default null,
            p_order_type            in  mts_trade_tran.order_type%type       default null,
            p_strike                in  mts_trade_tran.strike%type           default null,
            p_action_code           in  mts_trade_tran.action_code%type      default null,
            p_qty                   in  mts_trade_tran.qty%type              default null,
            p_price                 in  mts_trade_tran.price%type            default null,
            p_commission            in  mts_trade_tran.commission%type       default null,
            p_fees                  in  mts_trade_tran.fees%type             default null,
            p_source_order_id       in  mts_trade_tran.source_order_id%type  default null
        )
    is

        pl_rec_count        number;
        pl_rec              mts_trade_tran%rowtype;
    begin

            
            begin
                select  * 
                into    pl_rec
                from    mts_trade_tran
                where   id  = p_trade_tran_id; 

                

                IF sql%rowcount != 0 THEN
                    update  mts_trade_tran
                        set     portfolio_id    = nvl(p_portfolio_id,portfolio_id),
                                tran_date       = nvl(p_tran_date,tran_date),
                                symbol          = nvl(p_symbol,symbol),
                                exp_date        = nvl(p_exp_date,exp_date),
                                order_type      = nvl(p_order_type,order_type),
                                strike          = nvl(p_strike,strike),
                                action_code     = nvl(p_action_code,action_code),
                                qty             = nvl(p_qty,qty),
                                price           = nvl(p_price,price),
                                commission      = nvl(p_commission,commission),
                                fees            = nvl(p_fees,fees),
                                source_order_id = nvl(p_source_order_id,source_order_id)  
                        where   id  = p_trade_tran_id; 
                ELSE
                    pl_rec.portfolio_id   := p_portfolio_id;
                    pl_rec.symbol         := p_symbol;
                    pl_rec.exp_date       := p_exp_date;
                    pl_rec.order_type     := p_order_type;
                    pl_rec.strike         := p_strike;
                    pl_rec.action_code    := p_action_code;
                    pl_rec.tran_date      := p_tran_date;
                    pl_rec.qty              := p_qty;
                    pl_rec.price            := p_price;
                    pl_rec.commission       := p_commission;
                    pl_rec.fees             := p_fees;                    
                    pl_rec.source_order_id  := p_source_order_id;
                    insert into mts_trade_tran values pl_rec returning id into p_trade_tran_id;
                END IF;

            end;

    end merge_trade_tran;

    

end pkg_mts_trade;
/