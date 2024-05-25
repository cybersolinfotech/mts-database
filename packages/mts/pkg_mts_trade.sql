/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_trade as

    function get_action( p_code     mts_trade_action.code%type ) return mts_trade_action.name%type; 
    function get_order_type( p_code     mts_order_type.code%type ) return mts_order_type.name%type ;
    function get_portfolio_name(p_portfolio_id  mts_portfolio.id%type) return mts_portfolio.portfolio_name%type;


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

    procedure merge_trade_vue(
            p_trade_vue_id      in  out mts_trade_vue.id%type,
            p_user_id           in mts_trade_vue.user_id%type,
            p_portfolio_id      in  mts_trade_vue.portfolio_id%type     default null,
            p_symbol            in  mts_trade_vue.symbol%type           default null,
            p_exp_date          in  mts_trade_vue.exp_date%type         default null,
            p_order_type        in  mts_trade_vue.order_type%type       default null,
            p_strike            in  mts_trade_vue.strike%type           default null,
            p_trade_code        in  mts_trade_vue.trade_code%type       default null,
            p_open_action_code       in  mts_trade_vue.open_action_code%type      default null,
            p_open_date               in  mts_trade_vue.open_date%type              default null,
            p_open_qty               in  mts_trade_vue.open_qty%type              default null,
            p_open_price             in  mts_trade_vue.open_price%type            default null,
            p_open_commission        in  mts_trade_vue.open_commission%type       default null,
            p_open_fees              in  mts_trade_vue.open_fees%type             default null,
            p_close_action_code               in  mts_trade_vue.close_action_code%type              default null,
            p_close_date               in  mts_trade_vue.close_date%type              default null,
            p_close_qty               in  mts_trade_vue.close_qty%type              default null,
            p_close_price             in  mts_trade_vue.close_price%type            default null,
            p_close_commission        in  mts_trade_vue.close_commission%type       default null,
            p_close_fees              in  mts_trade_vue.close_fees%type             default null,
            p_group_name        in  mts_trade_vue.group_name%type       default null,
            p_notes             IN  mts_trade_vue.notes%TYPE        default NULL       
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

    /***************************************************************************
        procedure: merge_trade_vue
     ***************************************************************************/
    procedure merge_trade_vue(
            p_trade_vue_id      in  out mts_trade_vue.id%type,
            p_user_id           in mts_trade_vue.user_id%type,
            p_portfolio_id      in  mts_trade_vue.portfolio_id%type     default null,
            p_symbol            in  mts_trade_vue.symbol%type           default null,
            p_exp_date          in  mts_trade_vue.exp_date%type         default null,
            p_order_type        in  mts_trade_vue.order_type%type       default null,
            p_strike            in  mts_trade_vue.strike%type           default null,
            p_trade_code        in  mts_trade_vue.trade_code%type       default null,
            p_open_action_code       in  mts_trade_vue.open_action_code%type      default null,
            p_open_date               in  mts_trade_vue.open_date%type              default null,
            p_open_qty               in  mts_trade_vue.open_qty%type              default null,
            p_open_price             in  mts_trade_vue.open_price%type            default null,
            p_open_commission        in  mts_trade_vue.open_commission%type       default null,
            p_open_fees              in  mts_trade_vue.open_fees%type             default null,
            p_close_action_code               in  mts_trade_vue.close_action_code%type              default null,
            p_close_date               in  mts_trade_vue.close_date%type              default null,
            p_close_qty               in  mts_trade_vue.close_qty%type              default null,
            p_close_price             in  mts_trade_vue.close_price%type            default null,
            p_close_commission        in  mts_trade_vue.close_commission%type       default null,
            p_close_fees              in  mts_trade_vue.close_fees%type             default null,
            p_group_name        in  mts_trade_vue.group_name%type       default null,
            p_notes             IN  mts_trade_vue.notes%TYPE        default NULL       
        )
    is

        pl_rec_count        number;
        pl_rec              mts_trade_vue%rowtype;
    begin

            
            begin
                select  * 
                into    pl_rec
                from    mts_trade_vue
                where   id  = p_trade_vue_id; 

                update  mts_trade_vue
                        set     portfolio_id    = nvl(p_portfolio_id,portfolio_id),
                                symbol          = nvl(p_symbol,symbol),
                                exp_date        = nvl(p_exp_date,exp_date),
                                order_type      = nvl(p_order_type,order_type),
                                strike          = nvl(p_strike,strike),
                                trade_code      = nvl(p_trade_code,trade_code),
                                open_action_code  = nvl(p_open_action_code,open_action_code),
                                open_date       = nvl(p_open_date,open_date),
                                open_qty        = nvl(p_open_qty,open_qty),
                                open_price      = nvl(p_open_price,open_price),
                                open_commission = nvl(p_open_commission,open_commission),
                                open_fees       = nvl(p_open_fees,open_fees),
                                close_action_code      = nvl(p_close_action_code,close_action_code),
                                close_date      = nvl(p_close_date,close_date),
                                close_qty       = nvl(p_close_qty,close_qty),
                                close_price     = nvl(p_close_price,close_price),
                                close_commission = nvl(p_close_commission,close_commission),
                                close_fees      = nvl(p_close_fees,close_fees),
                                notes           = nvl(p_notes,notes)  
                        where   id  = p_trade_vue_id; 

            EXCEPTION
                when no_data_found THEN
                    pl_rec.id              := mts_trade_vue_seq.nextval;
                    pl_rec.user_id         := p_user_id;
                    pl_rec.portfolio_id    := p_portfolio_id;
                    pl_rec.symbol          := p_symbol;
                    pl_rec.exp_date        := p_exp_date;
                    pl_rec.order_type      := p_order_type;
                    pl_rec.strike          := p_strike;
                    pl_rec.trade_code      := p_trade_code;
                    pl_rec.open_action_code     := p_open_action_code;
                    pl_rec.open_date       := p_open_date;
                    pl_rec.open_qty        := p_open_qty;
                    pl_rec.open_price      := p_open_price;
                    pl_rec.open_commission := p_open_commission;
                    pl_rec.open_fees       := p_open_fees;
                    pl_rec.close_action_code     := p_close_action_code;
                    pl_rec.close_date      := p_close_date;
                    pl_rec.close_qty       := p_close_qty;
                    pl_rec.close_price     := p_close_price;
                    pl_rec.close_commission := p_close_commission;
                    pl_rec.close_fees       := p_close_fees;
                    pl_rec.active           := 1;
                    pl_rec.created_by       := coalesce(sys_context('apex$session','app_user'),user);
                    pl_rec.create_date       := current_timestamp;
                    pl_rec.notes           := p_notes;

                    insert into mts_trade_vue values pl_rec returning id into p_trade_vue_id;
                
            end;

    end merge_trade_vue;

end pkg_mts_trade;
/