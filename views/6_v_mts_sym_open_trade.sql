CREATE OR REPLACE  VIEW V_MTS_SYM_OPEN_TRADE
AS 
select  user_id, portfolio_id, symbol,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) As ORDER_TYPE, 
        MIN(OPEN_DATE) OPEN_DATE,
        SUM(OPEN_QTY) OPEN_QTY, 
        SUM(OPEN_PRICE) OPEN_PRICE,
        SUM(COMMISSION) COMMISSION,
        SUM(FEES) FEES
from    v_mts_open_trade
group by user_id, portfolio_id, symbol,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END);