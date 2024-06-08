CREATE OR REPLACE  VIEW V_MTS_YTD_CLOSE_TRADE
AS 
select  user_id, portfolio_id, symbol, 
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) As ORDER_TYPE,        
        MIN(OPEN_DATE) OPEN_DATE,
        SUM(OPEN_QTY) OPEN_QTY,
        SUM(OPEN_PRICE) OPEN_PRICE,
        MAX(CLOSE_DATE) CLOSE_DATE,
        SUM(CLOSE_QTY) CLOSE_QTY,
        SUM(CLOSE_PRICE) CLOSE_PRICE,
        SUM(PL) as PL
from    v_mts_close_trade
WHERE   TO_CHAR(CLOSE_DATE,'YYYY') = TO_CHAR(CURRENT_TIMESTAMP,'YYYY')
GROUP BY user_id, portfolio_id, symbol, 
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) 
;
