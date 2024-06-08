/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_plan
as


    function get_user_id return mts_user.user_id%type;
    function get_pay_product_id (p_product_id mts_product.id%type) return mts_product.pay_product_id%type;
    function get_pay_plan_id (p_plan_id mts_plan.id%type) return mts_plan.pay_plan_id%type;
    function get_cart_id ( p_user_id    mts_shopping_cart.user_id%type ) return mts_shopping_cart.cart_id%type ;

    -- ============================================================================================
    --                                      PRODUCT 
    -- ============================================================================================
    procedure create_product(
        p_name              mts_product.name%type,
        p_description       mts_product.description%type
    );

    procedure update_product(
        p_product_id        mts_product.id%type,
        p_name              mts_product.name%type default null,
        p_description       mts_product.description%type default null, 
        p_pay_product_id    mts_product.pay_product_id%type default null,  
        p_active            mts_product.active%type default null      
    );    
     
    -- ============================================================================================
    --                                      PLAN 
    -- ============================================================================================
    procedure create_plan(
        p_product_id        mts_plan.product_id%type,
        p_name              mts_plan.name%type,
        p_description       mts_plan.description%type,
        p_amount            mts_plan.amount%type,
        p_currency          mts_plan.currency%type,
        p_interval          mts_plan.interval%type,
        p_interval_count    mts_plan.interval_count%type
    );

    procedure update_plan(
        p_plan_id           mts_plan.id%type,
        p_name              mts_plan.name%type default null,
        p_description       mts_plan.description%type default null,
        p_amount            mts_plan.amount%type default null,
        p_currency          mts_plan.currency%type default null,
        p_interval          mts_plan.interval%type,
        p_interval_count    mts_plan.interval_count%type,
        p_pay_plan_id       mts_plan.pay_plan_id%type default null,
        p_active            mts_plan.active%type default null 
       
    );


    -- ============================================================================================
    --                                      SHOPPING CART 
    -- ============================================================================================
    procedure create_cart (
        p_cart_id      out mts_shopping_cart.cart_id%type,
        p_user_id      mts_shopping_cart.user_id%type
    );
    procedure close_cart (
        p_user_id      mts_shopping_cart.user_id%type
    );

    procedure create_cart_item (
        p_cart_id          mts_shopping_cart.cart_id%type,
        p_plan_id          mts_shopping_cart_item.plan_id%type
        
    );

    procedure remove_cart_item (
        p_cart_id          mts_shopping_cart.cart_id%type,
        p_plan_id          mts_shopping_cart_item.plan_id%type
        
    );
end pkg_mts_plan;
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_plan
as

    -- function => get_user_id
    function get_user_id  return mts_user.user_id%type
    is
    begin
        return  coalesce(sys_context('apex$session','app_user'),user) ;
    end;

    -- function => get_pay_customer_id
    function get_pay_customer_id (p_user_id mts_user.user_id%type) return mts_user.pay_customer_id%type
    is
        pl_pay_customer_id        mts_user.pay_customer_id%type;    
    begin
        begin
            select  pay_customer_id
            into    pl_pay_customer_id
            from    mts_user
            where   user_id = p_user_id;
        exception
            when no_data_found then
                pl_pay_customer_id := null;
        end;

        return pl_pay_customer_id;
    
    end get_pay_customer_id;

    -- function => get_pay_product_id
    function get_pay_product_id (p_product_id mts_product.id%type) return mts_product.pay_product_id%type
    is
        pl_pay_product_id        mts_product.pay_product_id%type;    
    begin
        begin
            select  pay_product_id
            into    pl_pay_product_id
            from    mts_product
            where   id = p_product_id;
        exception
            when no_data_found then
                pl_pay_product_id := null;
        end;

        return pl_pay_product_id;
    
    end get_pay_product_id;

    -- function => get_pay_plan_id
    function get_pay_plan_id (p_plan_id mts_plan.id%type) return mts_plan.pay_plan_id%type
    is
        pl_pay_plan_id        mts_plan.pay_plan_id%type;    
    begin
        begin
            select  pay_plan_id
            into    pl_pay_plan_id
            from    mts_plan
            where   id = p_plan_id;
        exception
            when no_data_found then
                pl_pay_plan_id := null;
        end;
        
        return pl_pay_plan_id;

    end get_pay_plan_id;

    -- ============================================================================================
    --                                      PRODUCT 
    -- ============================================================================================
    procedure create_product(
        p_name              mts_product.name%type,
        p_description       mts_product.description%type
    )
    is
        pl_rec              mts_product%rowtype;
    begin
        begin
            select  *
            into    pl_rec
            from    mts_product p
            where   lower(p.name) = lower(p_name);
            --
            if pl_rec.id is not null then
                raise_application_error(-20000, 'pkg_mts_plan.create_product: product already exists.', true);
            end if;
        exception
            when no_data_found then
                pl_rec.name     := p_name;
                pl_rec.description := p_description;
                insert into mts_product values pl_rec;
        end;    
    end create_product;

    procedure update_product(
        p_product_id        mts_product.id%type,
        p_name              mts_product.name%type default null,
        p_description       mts_product.description%type default null, 
        p_pay_product_id    mts_product.pay_product_id%type default null,  
        p_active            mts_product.active%type default null      
    )
    is
        pl_rec              mts_product%rowtype;
    begin
        begin
            select  *
            into    pl_rec
            from    mts_product p
            where   p.id = p_product_id;
            
            update  mts_product
            set     name = nvl(p_name,name),
                    description = nvl(p_description,description),
                    pay_product_id = nvl(p_pay_product_id,pay_product_id),
                    active = nvl(p_active,active)
            where   id = p_product_id;        

        exception
            when no_data_found then
                raise_application_error(-20000, 'pkg_mts_plan.update_product: product not found', true);
        end;    

    end update_product;   

    
     

    -- ============================================================================================
    --                                      PLAN 
    -- ============================================================================================
    procedure create_plan(
        p_product_id        mts_plan.product_id%type,
        p_name              mts_plan.name%type,
        p_description       mts_plan.description%type,
        p_amount            mts_plan.amount%type,
        p_currency          mts_plan.currency%type,
        p_interval          mts_plan.interval%type,
        p_interval_count    mts_plan.interval_count%type
    )
    is
        pl_rec              mts_plan%rowtype;
    begin
        begin
            select  *
            into    pl_rec
            from    mts_plan p
            where   p.product_id = p_product_id
            and     lower(p.name) = lower(p_name);
            --
            if pl_rec.id is not null then
                raise_application_error(-20000, 'pkg_mts_plan.create_plan: plan already exists.', true);
            end if;
        exception
            when no_data_found then
                pl_rec.product_id := p_product_id;
                pl_rec.name     := p_name;
                pl_rec.description := p_description;
                pl_rec.amount := p_amount;
                pl_rec.currency := p_currency;
                pl_rec.interval := p_interval;
                pl_rec.interval_count := p_interval_count;
                insert into mts_plan values pl_rec;
        end;    
    end create_plan;



    procedure update_plan(
        p_plan_id           mts_plan.id%type,
        p_name              mts_plan.name%type default null,
        p_description       mts_plan.description%type default null,
        p_amount            mts_plan.amount%type default null,
        p_currency          mts_plan.currency%type default null,
        p_interval          mts_plan.interval%type,
        p_interval_count    mts_plan.interval_count%type,
        p_pay_plan_id       mts_plan.pay_plan_id%type default null,        
        p_active            mts_plan.active%type default null 
       
    )
    is
        pl_rec              mts_plan%rowtype;
    begin
        begin
            select  *
            into    pl_rec
            from    mts_plan p
            where   p.id = p_plan_id;
            
            update  mts_plan
            set     name = nvl(p_name,name),
                    description = nvl(p_description,description),
                    amount = nvl(p_amount,amount),
                    currency = nvl(p_currency,currency),
                    interval = nvl(p_interval,interval),
                    interval_count = nvl(p_interval_count,interval_count),
                    pay_plan_id = nvl(p_pay_plan_id,pay_plan_id),
                    active = nvl(p_active,active)
            where   id = p_plan_id;        

        exception
            when no_data_found then
                raise_application_error(-20000, 'pkg_mts_plan.update_product: product not found', true);
        end;    

    end update_plan;  


    -- ============================================================================================
    --                                      SHOPPING CART 
    -- ============================================================================================

    function get_cart_id ( p_user_id    mts_shopping_cart.user_id%type ) 
    return mts_shopping_cart.cart_id%type 
    as
        pl_cart_id      mts_shopping_cart.cart_id%type ;
    begin

        select  cart_id into pl_cart_id
        from    mts_shopping_cart
        where   user_id = p_user_id
        and     lower(nvl(is_closed,'n')) = 'n';

        return pl_cart_id;

    end;

   
    -- procedure => create_cart
    procedure create_cart (
        p_cart_id      out mts_shopping_cart.cart_id%type,
        p_user_id      mts_shopping_cart.user_id%type
    )
    as
        pl_cart_id         mts_shopping_cart.cart_id%type;
    begin
        close_cart(p_user_id);
        --
        insert into mts_shopping_cart (user_id)
        values ( p_user_id) return cart_id into p_cart_id;
    end create_cart;

    -- procedure => close_cart
    procedure close_cart (
        p_user_id      mts_shopping_cart.user_id%type
    )
    is
    begin        
        --
        update  mts_shopping_cart s
        set     s.is_closed         = 'Y'
        where   s.user_id       = p_user_id
        and     s.is_closed IS NULL;
    end close_cart;

    procedure create_cart_item (
        p_cart_id          mts_shopping_cart.cart_id%type,
        p_plan_id          mts_shopping_cart_item.plan_id%type   
    )
    is
        pl_rec              mts_shopping_cart_item%rowtype;
    begin
        begin
            select  *
            into    pl_rec
            from    mts_shopping_cart_item s
            where   cart_id = p_cart_id
            and     plan_id = p_plan_id;

        exception
            when no_data_found then
                insert into mts_shopping_cart_item  (cart_id,plan_id)
                values (p_cart_id,p_plan_id);
        end;    


    end create_cart_item;


    procedure remove_cart_item (
        p_cart_id          mts_shopping_cart.cart_id%type,
        p_plan_id          mts_shopping_cart_item.plan_id%type
    )
    is
        pl_rec              mts_shopping_cart%rowtype;
    begin
        begin
            select  *
            into    pl_rec
            from    mts_shopping_cart_item s
            where   cart_id = p_cart_id
            and     plan_id = p_plan_id;

            delete from mts_shopping_cart_item
            where   cart_id = p_cart_id
            and     plan_id = p_plan_id;

        exception
            when no_data_found then
                raise_application_error(-20000, 'pkg_mts_plan.remove_cart_item: item not found', true);
        end;    

    end remove_cart_item; 



end pkg_mts_plan;