--rem -- deploying trigger mts_trade_tran_biud
create or replace editionable trigger mts_trade_tran_biud 
before
insert or update or delete on mts_trade_tran
for each row
begin
	
	if inserting or updating then
		if :new.trade_code is null then
			:new.trade_code := pkg_mts_util.get_trade_code(
                                                                            p_symbol => :new.symbol,
                                                                            p_exp_date => :new.exp_date,
                                                                            p_order_type => :new.order_type,
                                                                            p_strike => :new.strike
                                                                            );
        	--:new.trade_code := trim(:new.symbol) || '-' || nvl(to_char(:new.exp_date,'YYYYMMDD'),'99991231')|| '-'|| nvl(:new.order_type,'E') || '-' || to_char(NVL(:new.strike,'999999'));
		end if;
		dbms_output.put_line('Action Code = ' || :new.action_code );
		if lower(:new.action_code) in ( 'bto','btc','buy') then
			:new.qty := round(abs(nvl(:new.qty,0)),2);
			dbms_output.put_line('Action Code = ' || :new.price );
			dbms_output.put_line('Action Code = ' || :new.qty );
		elsif lower(:new.action_code) in ( 'sto','stc','sell') then
			:new.qty := round(abs(nvl(:new.qty,0))*-1,2);
			dbms_output.put_line('Action Code1 = ' || :new.price );
			dbms_output.put_line('Action Code1 = ' || :new.qty );
		elsif lower(:new.action_code) in ( 'REMO') then
			:new.qty := round(nvl(:new.qty,0),2);			
		else  
			if ( nvl(:new.price,0) < 0 and lower(:new.notes) like '%mark to market%') then
				:new.action_code := 'BUY';	
				:new.qty := 0;
			elsif ( nvl(:new.price,0) > 0 and lower(:new.notes) like '%mark to market%') then
				:new.action_code := 'SELL';
				:new.qty := 0;
			end if;
		end if;
	end if;	

    
end;
/