
create or replace view v_mts_dividend_tran
as
select  user_id, portfolio_id,
        tran_date,
        TO_CHAR(tran_date,'YYYY') YYYY,
        TO_CHAR(tran_date,'MM') MM,
        TO_CHAR(tran_date,'MON') MON,
        TO_CHAR(tran_date,'WW') WW,
        TO_CHAR(tran_date,'DD') DD,
        TO_CHAR(tran_date,'DAY') DAY,
        tran_source, 
        amount, 
        REMARKS
from    mts_portfolio_tran
where   tran_type = 'DIVIDEND';