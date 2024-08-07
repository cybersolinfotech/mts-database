CREATE OR REPLACE VIEW V_MTS_CLOSE_TRADE
AS 
select user_id, portfolio_id, symbol, exp_date, order_type, strike, trade_code,
        OPEN_DATE,
        OPEN_QTY OPEN_QTY ,
        ROUND(OPEN_UNIT_PRICE * ABS(CLOSE_QTY),4) as OPEN_PRICE,        
        OPEN_UNIT_PRICE,
        CLOSE_DATE,
        CLOSE_QTY,
        CLOSE_PRICE,
        CLOSE_UNIT_PRICE,
        (abs(close_qty) * unit_commission) COMMISSION ,
        (abs(close_qty) * unit_fees) FEES,
        pkg_mts_util.get_profit_loss(
            p_open_qty => abs(CLOSE_QTY) ,
            p_open_price => (OPEN_UNIT_PRICE * abs(CLOSE_QTY)),
            p_close_qty =>  abs(CLOSE_QTY),
            p_close_price => CLOSE_PRICE) as PL ,
        
        extract(day from (CLOSE_DATE - OPEN_DATE))  day_duration,
        extract(hour from (CLOSE_DATE - OPEN_DATE))  hour_duration,
        extract(minute from (CLOSE_DATE - OPEN_DATE))  min_duration       
from    v_mts_trade
where   OPEN_QTY != 0 
AND     CLOSE_QTY != 0;