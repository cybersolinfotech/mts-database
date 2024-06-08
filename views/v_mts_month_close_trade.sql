
CREATE OR REPLACE VIEW V_MTS_MONTH_CLOSE_TRADE
AS 
select  user_id, portfolio_id, symbol,
        TO_CHAR(CLOSE_DATE,'YYYY') YEAR,
        TO_CHAR(CLOSE_DATE,'MM') MONTH,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) AS ORDER_TYPE,
        SUM(OPEN_PRICE) OPEN_PRICE,
        SUM(CLOSE_PRICE) CLOSE_PRICE,
        SUM(PL) PL
from    v_mts_close_trade
GROUP BY user_id, portfolio_id, symbol,
        TO_CHAR(CLOSE_DATE,'YYYY') ,TO_CHAR(CLOSE_DATE,'MM') ,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) 
;