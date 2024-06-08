create or replace trigger mts_product_biud 
before
insert or update or delete on mts_product
for each row
declare
    pl_pay_product_id   mts_product.pay_product_id%type;  
begin

    if inserting then   
        pkg_stripe_api.create_product(  p_pay_product_id => pl_pay_product_id,
                                        p_name => :new.name,
                                        p_description => :new.description);
        
        :new.pay_product_id := pl_pay_product_id;             
    elsif updating then
        if ( :new.name != :old.name) or (:new.description != :old.description) then
            pkg_stripe_api.update_product(  p_pay_product_id => :new.pay_product_id,
                                            p_name => :new.name,
                                            p_description => :new.description);
        end if;
    elsif deleting then  
            pkg_stripe_api.delete_product(  p_pay_product_id => :old.pay_product_id);
    end if;

end;