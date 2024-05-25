create or replace view v_mts_trade_position_sy
as
select user_id, portfolio_id, open_date, symbol,
exp_date,
strike,
extract(day from (current_timestamp - open_date))  day_duration,
extract(hour from (current_timestamp - open_date))  hour_duration,
extract(minute from (current_timestamp - open_date))  min_duration,
(CASE 
  WHEN (open_qty > 0) THEN 'Long'
  ELSE 'Short'
END) as Position,
decode(order_type, 'PUT', 'PUT OPTION', 'CALL','CALL OPTION', ORDER_TYPE) Order_type,
open_qty,
open_price,
(case when abs(open_qty) = abs(close_qty)  then 'close'
      else 'open'
end) status,
NOTES
from mts_trade_vue
where nvl(close_qty,0) = 0 ;