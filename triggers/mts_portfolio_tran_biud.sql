create or replace trigger mts_portfolio_tran_biud 
before
insert or update or delete on mts_portfolio_tran
for each row
begin
	
	if inserting then
        
		if lower(:new.tran_type) = 'deposit' then
			:new.amount := abs(:new.amount);
		else
			:new.amount := (abs(:new.amount)*-1);
		end if;
		
		if :new.amount is not null then
			update mts_portfolio
			set balance = balance + :new.amount
			where id = :new.portfolio_id;
		end if;
		
	elsif updating then

        :new.update_date := current_timestamp;	
		:new.updated_by := coalesce(sys_context('apex$session','app_user'),user); 	
	
		
		if lower(:new.tran_type) = 'deposit' then
			:new.amount := abs(:new.amount);
		else
			:new.amount := (abs(:new.amount)*-1);
		end if;
		
		if nvl(:new.amount,0) != 0 then
			update  mts_portfolio
			set     balance = balance + ( nvl(:new.amount,0) - nvl(:old.amount,0) )
			where   id = :new.portfolio_id;
		end if;

        
	else
		if nvl(:new.amount,0) != 0 then
			update  mts_portfolio
			set     balance = balance - nvl(:old.amount,0)
			where   id = :new.portfolio_id;
		end if;	

	end if;
end;
/