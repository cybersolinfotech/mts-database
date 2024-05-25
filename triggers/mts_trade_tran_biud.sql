--rem -- deploying trigger mts_trade_tran_biud
create or replace editionable trigger mts_trade_tran_biud 
before
insert or update or delete on mts_trade_tran
for each row
DECLARE
    pl_rec      mts_trade_vue%rowtype;
begin

	
	
	if inserting or updating then
		if :new.trade_code is null then
        	:new.trade_code := trim(:new.symbol) || '-' || to_char(:new.exp_date,'YYYYMMDD') || '-'|| :new.order_type || '-' || to_char(:new.strike);
		end if;

		/*
		if :new.group_name is null then
			:new.group_name := trim(:new.symbol) || '-' || to_char(:new.exp_date,'DD-MON-YYYY');
		end if;
		*/
        
        --dbms_output.put_line('trade_code ' || :new.trade_code );
        --dbms_output.put_line('before price ' || :new.price );
        --dbms_output.put_line('before qty ' || :new.qty );        
		if lower(:new.action_code) in ( 'bto','btc','buy') then
			:new.price := round(abs(nvl(:new.price,0)) * -1,2);
			:new.qty := round(abs(nvl(:new.qty,0)),2);
		else
			:new.price := round(abs(nvl(:new.price,0)) ,2);
			:new.qty := round(abs(nvl(:new.qty,0))*-1,2);
		end if;
        --dbms_output.put_line(':new.user_id ' || :new.user_id );
        --dbms_output.put_line(':new.portfolio_id ' || :new.portfolio_id );
        --dbms_output.put_line(':new.exp_date ' || :new.exp_date );
        --dbms_output.put_line(':new.strike ' || :new.strike );
		-- find any open transaction ---
	begin
        
        select 	* 
        into   	pl_rec
        from 	mts_trade_vue
        where  	user_id = :new.user_id
        and     portfolio_id = :new.portfolio_id
        and		trade_code = :new.trade_code
        and     open_action_code in ( 'BTO','STO','BUY','SELL')
        and     abs(nvl(open_qty,0)) > abs(nvl(close_qty,0));
        

        
        if ( nvl(:new.action_code,'XXX') = 'XXX' and lower(:new.notes) like '%mark to market%') then 
            dbms_output.put_line('inside mark to market ' || pl_rec.open_price || ' - ' || :new.qty );  
            if inserting then
				pl_rec.open_price := nvl(pl_rec.open_price,0) + nvl(:new.price,0)*-1 ;
				pl_rec.open_commission := nvl(pl_rec.open_commission,0) + nvl(:new.commission,0)  ;
				pl_rec.open_fees := nvl(pl_rec.open_fees,0) +  nvl(:new.fees,0) ;
			else   
				pl_rec.open_price := nvl(pl_rec.open_price,0) - nvl(:old.price,0)*-1  + nvl(:new.price,0)*-1 ;
				pl_rec.open_commission := nvl(pl_rec.open_commission,0) - nvl(:old.commission,0)  + nvl(:new.commission,0)  ;
				pl_rec.open_fees := nvl(pl_rec.open_fees,0) -  nvl(:old.fees,0) +  nvl(:new.fees,0) ;
			end if; 
            dbms_output.put_line('outside mark to market ' || pl_rec.open_price );  
		elsif ( nvl(:new.action_code,'XXX') = pl_rec.open_action_code) then
			if inserting then
				pl_rec.open_qty  := nvl(pl_rec.open_qty,0)  + nvl(:new.qty,0);
				pl_rec.open_price := nvl(pl_rec.open_price,0) + nvl(:new.price,0) ;
				pl_rec.open_commission := nvl(pl_rec.open_commission,0) + nvl(:new.commission,0)  ;
				pl_rec.open_fees := nvl(pl_rec.open_fees,0) +  nvl(:new.fees,0) ;
			else   
				pl_rec.open_qty  := nvl(pl_rec.open_qty,0) - nvl(:old.qty,0) + nvl(:new.qty,0);
				pl_rec.open_price := nvl(pl_rec.open_price,0) - nvl(:old.price,0)  + nvl(:new.price,0) ;
				pl_rec.open_commission := nvl(pl_rec.open_commission,0) - nvl(:old.commission,0)  + nvl(:new.commission,0)  ;
				pl_rec.open_fees := nvl(pl_rec.open_fees,0) -  nvl(:old.fees,0) +  nvl(:new.fees,0) ;
			end if;  
		else
            dbms_output.put_line('2. after qty ' || :new.qty );
			if (:new.action_code is null) then    
				if pl_rec.open_action_code = 'BTO' then 
					:new.action_code := 'STC';
					:new.price := round(abs(nvl(:new.price,0)) ,2);
					:new.qty := round(abs(nvl(:new.qty,0))*-1,2);
				elsif pl_rec.open_action_code = 'STO' then  
					:new.action_code := 'BTC';
					:new.price := round(abs(nvl(:new.price,0)) * -1,2);
					:new.qty := round(abs(nvl(:new.qty,0)),2);
				elsif pl_rec.open_action_code = 'BUY' then   
					:new.action_code := 'SELL';
					:new.price := round(abs(nvl(:new.price,0)) ,2);
					:new.qty := round(abs(nvl(:new.qty,0))*-1,2);
				else
					:new.action_code := 'BUY';
					:new.price := round(abs(nvl(:new.price,0)) * -1,2);
					:new.qty := round(abs(nvl(:new.qty,0)),2);
				end if;

			end if;
			pl_rec.close_action_code := :new.action_code;
			if inserting then
				pl_rec.close_date := :new.tran_date;
				pl_rec.close_qty  := nvl(pl_rec.close_qty,0) + nvl(:new.qty,0);
				pl_rec.close_price := nvl(pl_rec.close_price,0) + nvl(:new.price,0) ;
				pl_rec.close_commission := nvl(pl_rec.close_commission,0) + nvl(:new.commission,0)  ;
				pl_rec.close_fees := nvl(pl_rec.close_fees,0) + nvl(:new.fees,0) ;
			else   
				pl_rec.close_date := :new.tran_date;
				pl_rec.close_qty  := nvl(pl_rec.close_qty,0) - nvl(:old.qty,0)  + nvl(:new.qty,0);
				pl_rec.close_price := nvl(pl_rec.close_price,0) - nvl(:old.price,0) + nvl(:new.price,0) ;
				pl_rec.close_commission := nvl(pl_rec.close_commission,0) - nvl(:old.commission,0) + nvl(:new.commission,0)  ;
				pl_rec.close_fees := nvl(pl_rec.close_fees,0) -  nvl(:old.fees,0) + nvl(:new.fees,0) ;
			end if;  
			
		end if;

		pl_rec.notes := nvl(pl_rec.notes,'') || ' ' || chr(10) || '=> ' || :new.notes;



	exception

		when no_data_found then 
             dbms_output.put_line('3. after qty ' || :new.qty );  
			if :new.order_type = 'BUY' then
				pl_rec.open_action_code := 'BTO';
			elsif :new.order_type = 'SELL' then
				pl_rec.open_action_code := 'STO';
			else
				pl_rec.open_action_code := :new.action_code;
			end if;
			pl_rec.id := 0;
			pl_rec.user_id :=  :new.user_id;
			pl_rec.portfolio_id := :new.portfolio_id;
			pl_rec.symbol := :new.symbol;
			pl_rec.exp_date := :new.exp_date;
			pl_rec.order_type := :new.order_type;
			pl_rec.strike := :new.strike;
			pl_rec.trade_code := :new.trade_code;
			pl_rec.open_date := :new.tran_date;
			pl_rec.open_qty := :new.qty;
			pl_rec.open_price := :new.price;
			pl_rec.open_commission := :new.commission;
			pl_rec.open_fees := :new.fees;
			pl_rec.notes :=  '=> ' || :new.notes;

			

	end ;

	pkg_mts_trade.merge_trade_vue(
            	p_trade_vue_id  => pl_rec.id,
				p_user_id => pl_rec.user_id,
            	p_portfolio_id  => pl_rec.portfolio_id,
            	p_symbol        => pl_rec.symbol,
            	p_exp_date     	=> pl_rec.exp_date,
            	p_order_type    => pl_rec.order_type,
            	p_strike        => pl_rec.strike,
				p_trade_code    => pl_rec.trade_code,
            	p_open_action_code   => pl_rec.open_action_code,
            	p_open_date     => pl_rec.open_date,
            	p_open_qty      => pl_rec.open_qty,
            	p_open_price    => pl_rec.open_price,
            	p_open_commission => pl_rec.open_commission,
            	p_open_fees       => pl_rec.open_fees,
                p_close_action_code   => pl_rec.close_action_code,
				p_close_date     => pl_rec.close_date,
            	p_close_qty      => pl_rec.close_qty,
            	p_close_price    => pl_rec.close_price,
            	p_close_commission => pl_rec.close_commission,
            	p_close_fees       => pl_rec.close_fees,
				p_notes			=> pl_rec.notes
				
				);


	end if;


	

    --pkg_trade_util.set_trade_order_status(:new.order_id);
    
end;
/