--rem ---1. creating view => v_mts_open_trade
create or replace view v_mts_open_trade as 
select  id,user_id,portfolio_id,tran_date,trade_code,symbol,action_code,order_type,qty,price,
        exp_date,strike,source_order_id,group_name,active,create_date,update_date 
from    mts_trade
where   lower(action_code) in ( 'bto','sto','buy');
/

--rem ---2. creating view => v_mts_close_trade
create or replace  view v_mts_close_trade  as 
select    id,user_id,portfolio_id,tran_date,trade_code,symbol,action_code,order_type,qty,price,exp_date,
          strike,source_order_id,group_name,active,create_date,update_date 
from      mts_trade
where lower(action_code) in ( 'btc','stc','sell');
/

--rem ---3. creating view => v_mts_open_position
create or replace  view v_mts_open_position as 
select user_id,portfolio_id,group_name, max(tran_date) tran_date , trade_code,symbol, order_type,  trunc(exp_date) exp_date, strike, sum(abs(nvl(qty,0))) qty, nvl(sum(nvl(price,0)),0) price
from v_mts_open_trade
group by user_id,portfolio_id,group_name,  trade_code,symbol, order_type,trunc(exp_date) ,strike;
/

--rem ---4. creating view => v_mts_close_position
create or replace  view v_mts_close_position
as
select user_id,portfolio_id,group_name, max(tran_date) tran_date, trade_code,symbol, order_type, trunc(exp_date) exp_date, strike, sum(abs(nvl(qty,0))) qty, nvl(sum(nvl(price,0)),0) price
from v_mts_close_trade
group by user_id,portfolio_id,group_name,  trade_code,symbol, order_type,trunc(exp_date) ,strike;
/

--rem ---5. creating view => v_mts_trade_position
create or replace  view v_mts_trade_position  as 
select      o.user_id, o.portfolio_id, o.group_name, o.trade_code,o.symbol, o.order_type, trunc(o.exp_date) exp_date, o.strike,
            max(trunc(o.tran_date)) open_date,
            max(trunc(c.tran_date)) close_date,
            nvl(sum(nvl(o.qty,0)),0) open_qty, 
            nvl(sum(nvl(o.price,0)),0) open_price,
            nvl(sum(nvl(c.qty,0)),0) close_qty, 
            nvl(sum(nvl(c.price,0)),0) close_price,
            sum(pkg_mts_util.get_profit_loss(o.qty,o.price,c.qty,c.price))  pl,     
            sum(pkg_mts_util.get_profit_loss_percent(o.qty,o.price,c.qty,c.price) ) pl_percent 
from        v_mts_open_position o
left join   v_mts_close_position c on  c.portfolio_id = o.portfolio_id 
                                and c.trade_code = o.trade_code
--where       nvl(c.qty,0) > 0
group by    o.user_id, o.portfolio_id, o.group_name,o.trade_code,o.symbol, o.order_type, trunc(o.exp_date) , o.strike --,
            --trunc(o.tran_date) ,
            --trunc(c.tran_date); 
/

--rem ---6. creating view => v_mts_group_position
create or replace view v_mts_group_position as 
select    user_id,
          portfolio_id,
          group_name,
          min(open_date) open_date,
          sum(abs(open_qty)) open_qty, 
          sum(open_price) open_price,
          max(close_date)  close_date,
          sum(abs(close_qty)) close_qty, 
          sum(close_price) close_price,       
          sum(pl) pl,
          avg(pkg_mts_util.get_profit_loss_percent(open_qty,open_price,close_qty,close_price))   pl_percent,       
          ( case  when sum(pl) > 0  then 1
                 when sum(pl) < 0 then 0
                 else 0
                 end
          ) win_loss
from      v_mts_trade_position p
group by  user_id,
          portfolio_id,
          group_name;

--rem ---7. creating view => v_mts_open_trade
create or replace  view v_mts_portfolio_position  as 
  select    p.user_id,
            p.id portfolio_id,
            sum(pl) pl,
            count(win_loss) tot_trade, 
            sum(decode(win_loss,1,1,0)) win,  
            sum(decode(win_loss,-1,1,0)) loss            
  from      mts_portfolio p 
  left join v_mts_group_position gp on gp.portfolio_id = p.id
  group by  p.user_id,
            p.id
;



