create or replace view v_mts_trade_pivot
as
select   user_id, portfolio_id, symbol , 
        SUM((CASE WHEN WW = TO_CHAR(SYSDATE,'WW') then PL
                ELSE 0
        END )) WEEK_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN WW = TO_CHAR(SYSDATE,'WW') then PL
                ELSE 0
        END ))) WEEK_PL_CLS, 

        SUM((CASE WHEN MON = 'JAN' then PL
                ELSE 0
        END )) JAN_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'JAN' then PL
                ELSE 0
        END ))) JAN_PL_CLS,
        
        SUM((CASE WHEN MON = 'FEB' then PL
                ELSE 0
        END )) FEB_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'FEB' then PL
                ELSE 0
        END ))) FEB_PL_CLS,

        SUM((CASE WHEN MON = 'MAR' then PL
                ELSE 0
        END )) MAR_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'MAR' then PL
                ELSE 0
        END ))) MAR_PL_CLS,

        SUM((CASE WHEN MON = 'APR' then PL
                ELSE 0
        END )) APR_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'APR' then PL
                ELSE 0
        END ))) APR_PL_CLS,

        SUM((CASE WHEN MON = 'MAY' then PL
                ELSE 0
        END )) MAY_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'MAY' then PL
                ELSE 0
        END ))) MAY_PL_CLS,

        SUM((CASE WHEN MON = 'JUN' then PL
                ELSE 0
        END )) JUN_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'JUN' then PL
                ELSE 0
        END ))) JUN_PL_CLS,

        SUM((CASE WHEN MON = 'JUL' then PL
                ELSE 0
        END )) JUL_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'JUL' then PL
                ELSE 0
        END ))) JUL_PL_CLS,

        SUM((CASE WHEN MON = 'AUG' then PL
                ELSE 0
        END )) AUG_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'AUG' then PL
                ELSE 0
        END ))) AUG_PL_CLS,
        
        SUM((CASE WHEN MON = 'SEP' then PL
                ELSE 0
        END )) SEP_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'SEP' then PL
                ELSE 0
        END ))) SEP_PL_CLS,
        
        SUM((CASE WHEN MON = 'OCT' then PL
                ELSE 0
        END )) OCT_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'OCT' then PL
                ELSE 0
        END ))) OCT_PL_CLS,

        SUM((CASE WHEN MON = 'NOV' then PL
                ELSE 0
        END )) NOV_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'NOV' then PL
                ELSE 0
        END ))) NOV_PL_CLS,

        SUM((CASE WHEN MON = 'DEC' then PL
                ELSE 0
        END )) DEC_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN MON = 'DEC' then PL
                ELSE 0
        END ))) DEC_PL_CLS,

        SUM((CASE WHEN YYYY = TO_CHAR(SYSDATE,'YYYY') then PL
                ELSE 0
        END )) YEAR_PL,
        PKG_MTS_UTIL.GET_NUM_CLASS(SUM((CASE WHEN YYYY = TO_CHAR(SYSDATE,'YYYY') then PL
                ELSE 0
        END ))) YEAR_PL_CLS
FROM   v_mts_close_trade_pl 
GROUP BY user_id, portfolio_id, symbol