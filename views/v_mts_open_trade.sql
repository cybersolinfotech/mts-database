CREATE OR REPLACE  VIEW V_MTS_OPEN_TRADE
AS 
select user_id, portfolio_id, symbol, exp_date, order_type, strike, trade_code,
        OPEN_DATE,
        (ABS(OPEN_QTY) - ABS(CLOSE_QTY)) OPEN_QTY ,
        round(OPEN_UNIT_PRICE * (ABS(OPEN_QTY) - ABS(CLOSE_QTY)),4) as OPEN_PRICE,        
        OPEN_UNIT_PRICE,
        COMMISSION,
        FEES
from    v_mts_trade
where   ABS(OPEN_QTY) != ABS(CLOSE_QTY);