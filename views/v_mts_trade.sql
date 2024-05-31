CREATE OR REPLACE  VIEW "V_MTS_TRADE" 
AS 
select user_id, portfolio_id, symbol, exp_date, order_type, strike, trade_code,
        min( case when action_code in ( 'BTO','STO', 'BUY') then tran_date
                  else NULL
             end )AS OPEN_DATE,
        sum((   case    when action_code in ( 'BTO','STO', 'BUY') then qty  
                        else 0
                
             end)) as OPEN_QTY,
        sum((   case    when action_code in ( 'BTO','STO','BUY') then price  
                        else 0
                
             end)) as OPEN_PRICE,        
        pkg_mts_util.get_unit_price( p_qty =>  sum((case    when action_code in ( 'BTO','STO', 'BUY') then qty  
                                                            else 0
                                                    end)),
                                     p_price => sum((case   when action_code in ( 'BTO','STO', 'BUY') then price  
                                                            else 0                                                        
                                                     end))
                                    ) AS OPEN_UNIT_PRICE,
        max( case when action_code in ( 'BTC','STC','SELL','REMO') then tran_date
                  else NULL
             end ) AS CLOSE_DATE,
        sum((   case    when action_code in ( 'BTC','STC','SELL','REMO') then qty  
                        else 0
                end)) as CLOSE_QTY,
        sum((   case    when action_code in ( 'BTC','STC','SELL','REMO') then price  
                        else 0
                end)) as CLOSE_PRICE,
        sum(commission) commission,
        sum(fees) fees,
        pkg_mts_util.get_unit_price( p_qty =>  sum((case    when action_code in ( 'BTC','STC','SELL','REMO') then qty  
                                                            else 0
                                                    end)),
                                     p_price => sum((case   when action_code in ( 'BTC','STC','SELL','REMO') then price  
                                                            else 0                                                        
                                                     end))
                                    ) AS CLOSE_UNIT_PRICE,
        pkg_mts_util.get_profit_loss(
            p_open_qty => sum((   case    when action_code in ( 'BTO','STO', 'BUY') then qty  
                        else 0
                
             end)) ,
            p_open_price => sum((   case    when action_code in ( 'BTO','STO', 'BUY') then price  
                        else 0
                
             end)),
            p_close_qty =>  sum((   case    when action_code in ( 'BTC','STC','SELL','REMO') then qty  
                        else 0
                end)) ,
            p_close_price => sum((   case    when action_code in ( 'BTC','STC','SELL','REMO') then price  
                        else 0
                end))   
        ) as PL
        
from mts_trade_tran
group by user_id, portfolio_id, symbol, exp_date, order_type, strike, trade_code;