create or replace view v_mts_trade_vue
as
select user_id, portfolio_id, open_date, close_date, symbol, 
exp_date,
strike,
extract(day from (close_date - open_date))  day_duration,
extract(hour from (close_date - open_date))  hour_duration,
extract(minute from (close_date - open_date))  min_duration,
(CASE 
  WHEN (open_qty > 0) THEN 'Long'
  ELSE 'Short'
END) as Position,
decode(order_type, 'PUT', 'PUT OPTION', 'CALL','CALL OPTION', ORDER_TYPE) Order_type,
open_qty,
open_price,
close_qty,
close_price,
(case when abs(open_qty) = abs(close_qty)  then 'close'
      else 'open'
end) status,
pkg_mts_util.get_profit_loss(open_qty, open_price, close_qty, close_price) as PL,
pkg_mts_util.get_profit_loss_percent(open_qty, open_price, close_qty, close_price) as pl_percent,
NOTES
from mts_trade_vue
where nvl(close_qty,0) != 0 ;