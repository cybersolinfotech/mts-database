create or replace trigger mts_plan_biud 
before
insert or update or delete on mts_plan
for each row
declare
    pl_pay_plan_id   mts_plan.pay_plan_id%type; 
    pl_pay_product_id mts_product.pay_product_id%type;

begin

    if inserting then 
        
        begin
            pkg_stripe_api.create_plan( p_pay_plan_id => pl_pay_plan_id,
                                        p_product_id => :new.product_id,
                                        p_name => :new.name,
                                        p_amount => :new.amount,
                                        p_currency => :new.currency,
                                        p_interval => :new.interval,
                                        p_interval_count => :new.interval_count);

        
            :new.pay_plan_id := pl_pay_plan_id;    
        end ;
        
                 
    elsif updating then
        if ( :new.pay_plan_id is not null) then  
            if  (( :new.name != :old.name) or 
                ( :new.amount != :old.amount) or 
                ( :new.currency != :old.currency) or 
                ( :new.interval != :old.interval) or 
                ( :new.interval_count != :old.interval_count) ) then

                pkg_stripe_api.update_plan( p_pay_plan_id => :new.pay_plan_id,
                                            p_name => :new.name,
                                            p_amount => :new.amount,
                                            p_currency => :new.currency,
                                            p_interval => :new.interval,
                                            p_interval_count => :new.interval_count);
            end if;
        end if;
    elsif deleting then  
            pkg_stripe_api.delete_plan( p_pay_plan_id => :old.pay_plan_id);
    end if;

end;