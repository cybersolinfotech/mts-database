CREATE OR REPLACE VIEW V_MTS_OPEN_TRADE
AS 
select  user_id, portfolio_id, symbol, exp_date, order_type, strike, trade_code,
        OPEN_DATE,
        
        (OPEN_QTY + CLOSE_QTY) OPEN_QTY,
        ROUND(OPEN_UNIT_PRICE * (OPEN_QTY - CLOSE_QTY),4) as OPEN_PRICE,
        OPEN_UNIT_PRICE,
        COMMISSION,
        FEES ,
        extract(day from (CURRENT_TIMESTAMP - OPEN_DATE))  day_duration,
        extract(hour from (CURRENT_TIMESTAMP - OPEN_DATE))  hour_duration,
        extract(minute from (CURRENT_TIMESTAMP - OPEN_DATE))  min_duration       
from    v_mts_trade
where   OPEN_QTY + CLOSE_QTY != 0;