CREATE OR REPLACE VIEW V_MTS_CLOSE_TRADE_PL
AS 
select  user_id, portfolio_id, symbol,
        TRUNC(CLOSE_DATE) CLOSE_DATE,  
        TO_CHAR(CLOSE_DATE,'YYYY') YYYY,
        TO_CHAR(CLOSE_DATE,'MM') MM,
        TO_CHAR(CLOSE_DATE,'MON') MON,
        TO_CHAR(CLOSE_DATE,'WW') WW,
        TO_CHAR(CLOSE_DATE,'DD') DD,
        TO_CHAR(CLOSE_DATE,'DAY') DAY,
        (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
              ELSE ORDER_TYPE
        END) AS ORDER_TYPE,
        SUM(OPEN_PRICE) OPEN_PRICE,
        SUM(CLOSE_PRICE) CLOSE_PRICE,
        SUM(PL) PL,
        (CASE WHEN SUM(PL) > 0 THEN 'WIN'
             WHEN SUM(PL) < 0 THEN 'LOSS'
             ELSE 'NPL'
        END) WIN_LOSS
from    v_mts_close_trade
WHERE   TO_CHAR(CLOSE_DATE,'YYYY') = to_char(current_timestamp,'YYYY')
GROUP BY 
      user_id, portfolio_id, symbol,
      TRUNC(CLOSE_DATE),
      TO_CHAR(CLOSE_DATE,'YYYY') ,
      TO_CHAR(CLOSE_DATE,'MM') ,
      TO_CHAR(CLOSE_DATE,'MON') ,
      TO_CHAR(CLOSE_DATE,'WW') ,
      TO_CHAR(CLOSE_DATE,'DD') ,
      TO_CHAR(CLOSE_DATE,'DAY') ,
      (CASE WHEN ORDER_TYPE in ('PUT','CALL') then 'OPTION'
            ELSE ORDER_TYPE
      END) 
;