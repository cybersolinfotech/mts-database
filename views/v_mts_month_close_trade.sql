
CREATE OR REPLACE VIEW V_MTS_MONTH_CLOSE_TRADE
AS 
select  user_id, portfolio_id, symbol,
        TO_CHAR(CLOSE_DATE,'YYYYMM') YEAR,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) AS ORDER_TYPE,
        SUM(OPEN_PRICE) OPEN_PRICE,
        SUM(CLOSE_PRICE) CLOSE_PRICE,
        SUM(PL) PL
from    v_mts_close_trade
WHERE   TO_CHAR(CLOSE_DATE,'YYYYMM') = TO_CHAR(CURRENT_TIMESTAMP,'YYYYMM')
GROUP BY user_id, portfolio_id, symbol,
        TO_CHAR(CLOSE_DATE,'YYYYMM') ,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) 
;