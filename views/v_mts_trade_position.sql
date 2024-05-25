create or replace view v_mts_open_position
as
select  
        user_id, 
        portfolio_id, 
        symbol,
        min(open_date) open_date,
        extract(day from (current_timestamp - min(open_date)))  duration,
        sum(open_price) open_price        
from    mts_trade_vue
where   nvl(close_qty,0) = 0 
group by user_id, 
        portfolio_id, 
        symbol;

