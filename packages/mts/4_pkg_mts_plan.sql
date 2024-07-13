/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_plan
as
    function get_user_id return mts_user.user_id%type;
    function get_pay_product_id (p_product_id mts_product.id%type) return mts_product.pay_product_id%type;
    function get_pay_plan_id (p_plan_id mts_plan.id%type) return mts_plan.pay_plan_id%type;
    function get_cart_id ( p_user_id    mts_shopping_cart.user_id%type ) return mts_shopping_cart.cart_id%type ;
    function checkout(p_cart_id   mts_shopping_cart.cart_id%type) return varchar2;
    -- ============================================================================================
    --                                      PRODUCT 
    -- ============================================================================================
    procedure product(
        p_action           in varchar2,
        p_rec              in out nocopy mts_product%rowtype
    );

    
    -- ============================================================================================
    --                                      PLAN 
    -- ============================================================================================
    procedure plan(
        p_action           in varchar2,
        p_rec              in out nocopy mts_plan%rowtype
    );

    -- ============================================================================================
    --                                      SHOPPING CART 
    -- ============================================================================================
    procedure cart (
        p_action            in varchar2,
        p_rec               in out nocopy mts_shopping_cart%rowtype
    );

    procedure close_cart (
        p_user_id      mts_shopping_cart.user_id%type
    );

    procedure cart_item (
        p_action            in varchar2,
        p_rec               in out nocopy mts_shopping_cart_item%rowtype
    );


    procedure   pay_request(
        p_action            in varchar2,
        p_rec               in out nocopy mts_pay_request%rowtype
    );

   
end pkg_mts_plan;
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_plan
as

    pl_log_msg              mts_app_process_log.msg_str%type;
    pl_newline              char(1) := chr(10);
    pl_method_name          varchar2(100);

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
    procedure product(
        p_action           in varchar2,
        p_rec              in out nocopy mts_product%rowtype
    )
    is
        pl_db_rec           mts_product%rowtype;  
          
    begin
        pl_method_name      := '[pkg_mts_plan].[product][' || p_action  ||'] '; 

        if lower(p_action) = 'create' then
            if p_rec.id is not null then
                raise_application_error(-20001, pl_method_name || 'product id needs to be null for new record.', true); 
            else
                p_rec.id := sys_guid();
                insert into mts_product values p_rec;   
            end if;
        elsif lower(p_action) = 'update' then
            if p_rec.id is null then
                raise_application_error(-20001, pl_method_name || 'product id is required to update product.', true); 
            else
                begin
                    select  * 
                    into    pl_db_rec
                    from    mts_product
                    where   id = p_rec.id;

                    pl_db_rec.name := p_rec.name;
                    pl_db_rec.description := p_rec.description;
                    pl_db_rec.pay_product_id := p_rec.pay_product_id;

                    update  mts_product
                    set     row = pl_db_rec
                    where   id = p_rec.id;
                exception
                    when no_data_found then
                        raise_application_error(-20001, pl_method_name || 'product not found', true);    
                end;                
            end if;

        elsif lower(p_action) = 'delete' then
            if p_rec.id is null then
                raise_application_error(-20001, pl_method_name || 'product id is required to delete product.', true); 
            else 
                delete from mts_product where id = p_rec.id;
            end if;   
        else
            raise_application_error(-20001, pl_method_name || 'Wrong action code.', true); 
        end if;
    exception
        when others then
            raise;

    end product;

    
    -- ============================================================================================
    --                                      PLAN 
    -- ============================================================================================
    procedure plan(
        p_action           in varchar2,
        p_rec              in out nocopy mts_plan%rowtype
    )
    is
        pl_db_rec            mts_plan%rowtype;
    begin
        pl_method_name      := '[pkg_mts_plan].[plan][' || p_action  ||'] '; 

        if lower(p_action) = 'create' then
            if p_rec.id is not null then
                raise_application_error(-20001, pl_method_name || 'plan id needs to be null for new record.', true); 
            else
                p_rec.id := sys_guid();
                insert into mts_plan values p_rec;   
            end if;
        elsif lower(p_action) = 'update' then
            if p_rec.id is null then
                raise_application_error(-20001, pl_method_name || 'plan id is required to update plan.', true); 
            else
                begin
                    select  * 
                    into    pl_db_rec
                    from    mts_plan
                    where   id = p_rec.id;

                    
                    pl_db_rec.product_id := p_rec.product_id;
                    pl_db_rec.name     := p_rec.name;
                    pl_db_rec.description := p_rec.description;
                    pl_db_rec.amount := p_rec.amount;
                    pl_db_rec.currency := p_rec.currency;
                    pl_db_rec.interval := p_rec.interval;
                    pl_db_rec.interval_count := p_rec.interval_count;

                    update  mts_plan
                    set     row = pl_db_rec
                    where   id = p_rec.id;
                exception
                    when no_data_found then
                        raise_application_error(-20000, pl_method_name || 'plan not found', true);    
                end;    
            end if;

        elsif lower(p_action) = 'delete' then
            if p_rec.id is null then
                raise_application_error(-20001, pl_method_name || 'plan id is required to delete plan.', true); 
            else 
                delete from mts_plan where id = p_rec.id;
            end if;   
        else
            raise_application_error(-20001, pl_method_name || 'Wrong action code.', true); 
        end if;

    exception
        when others then
            raise;

    end plan;     


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

    ------------- function => checkout -------------------
    function checkout(p_cart_id   mts_shopping_cart.cart_id%type)
    return varchar2
    as

        pl_new_rec              mts_pay_request%rowtype;
        pl_cart_rec             mts_shopping_cart%rowtype;
        pl_cart_item_rec        mts_shopping_cart_item%rowtype;


        pl_checkout_url         varchar2(1000);
        pl_param_name           apex_application_global.vc_arr2;
        pl_param_value          apex_application_global.vc_arr2;
        pl_index                number := 1;
        pl_item_no              number := 0;
        

        cursor c1 is 
        select  * 
        from    mts_shopping_cart_item
        where   cart_id = p_cart_id;
    begin
        pl_method_name      := '[pkg_mts_plan].[checkout] '; 
        begin
            select  *
            into    pl_cart_rec
            from    mts_shopping_cart
            where   cart_id = p_cart_id
            and     is_closed = 0;
        exception
            when no_data_found then
                raise_application_error(-20001,pl_method_name || 'cart not found.' );
        end;

        

        pl_param_name(pl_index) := 'mode';
        pl_param_value(pl_index) := 'payment';
        pl_index := pl_index + 1;

        pl_param_name(pl_index) := 'client_reference_id';
        pl_param_value(pl_index) := p_cart_id;
        pl_index := pl_index + 1;

        pl_param_name(pl_index) := 'customer_email';
        pl_param_value(pl_index) := 'payment';
        pl_index := pl_index + 1;

        pl_param_name(pl_index) := 'success_url';
        pl_param_value(pl_index) := 'payment';
        pl_index := pl_index + 1;

        pl_param_name(pl_index) := 'cancel_url';
        pl_param_value(pl_index) := 'payment';
        pl_index := pl_index + 1;        

        for c1rec in c1
        loop
            pl_param_name(pl_index)  := 'line_items[' || pl_item_no || '][price]';
            pl_param_value(pl_index) := get_pay_plan_id(p_plan_id => c1rec.plan_id);
            pl_index := pl_index + 1;
            

            pl_param_name(pl_index) := 'line_items[' || pl_item_no || '][quantity]';
            pl_param_value(pl_index) := 1;
            pl_index := pl_index + 1;

            pl_item_no := pl_item_no + 1;
        end loop;


        pl_new_rec.request_id := sys_guid();
        pl_new_rec.cart_id := p_cart_id;
        pl_new_rec.user_id := pl_cart_rec.user_id;
        pl_new_rec.requested_at := current_timestamp;
        pl_new_rec.pay_request := APEX_UTIL.TABLE_TO_STRING ( p_table => pl_param_name) || pl_newline || APEX_UTIL.TABLE_TO_STRING ( p_table => pl_param_value) ;
        
        pl_checkout_url := pkg_stripe_api.create_checkout_session(
                                            p_request_rec   => pl_new_rec,
                                            p_param_name    => pl_param_name,
                                            p_param_value   => pl_param_value   
                                        );
        
        return pl_checkout_url;
    exception
        when others then
            raise;

        
    end checkout;


   
    -- procedure => manage_cart
    procedure cart (
        p_action            in varchar2,
        p_rec               in out nocopy mts_shopping_cart%rowtype
    )
    as
        pl_db_rec           mts_shopping_cart%rowtype;
    begin
        pl_method_name      := '[pkg_mts_plan].[cart][' || p_action  ||'] ';
        if lower(p_action) = 'create' then
            close_cart(p_rec.user_id);
            if p_rec.cart_id is not null then
                raise_application_error(-20001, pl_method_name || 'cart id needs to be null for new record.', true); 
            else
                p_rec.cart_id := sys_guid();
                insert into mts_shopping_cart values p_rec;   
            end if;
        elsif lower(p_action) = 'update' then
            if p_rec.cart_id is null then
                raise_application_error(-20001, pl_method_name || 'cart id is required to update cart.', true); 
            else
                begin
                    select  * 
                    into    pl_db_rec
                    from    mts_shopping_cart
                    where   cart_id = p_rec.cart_id;

                    
                    pl_db_rec.is_closed := p_rec.is_closed;
                    pl_db_rec.active := p_rec.active;

                    update  mts_shopping_cart
                    set     row = pl_db_rec
                    where   cart_id = p_rec.cart_id;
                exception
                    when no_data_found then
                        raise_application_error(-20000, pl_method_name || 'cart not found', true);    
                end;    
            end if;

        elsif lower(p_action) = 'delete' then
            if p_rec.cart_id is null then
                raise_application_error(-20001, pl_method_name || 'cart id is required to delete cart.', true); 
            else 
                delete from mts_shopping_cart where cart_id = p_rec.cart_id;
            end if; 
        else
            raise_application_error(-20001, pl_method_name || 'Wrong action code.', true); 
        end if;
    end cart;

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

    procedure cart_item (
        p_action            in varchar2,
        p_rec               in out nocopy mts_shopping_cart_item%rowtype   
    )
    is
        pl_db_rec           mts_shopping_cart_item%rowtype;
    begin

        pl_method_name      := '[pkg_mts_plan].[cart_item][' || p_action  ||'] ';
        if lower(p_action) = 'create' then
            insert into mts_shopping_cart_item values p_rec;   
            
        elsif lower(p_action) = 'update' then
            if p_rec.cart_id is null or p_rec.plan_id is null then
                raise_application_error(-20001, pl_method_name || 'cart id and plan_id is required to update cart item.', true); 
            else
                begin
                    select  * 
                    into    pl_db_rec
                    from    mts_shopping_cart_item
                    where   cart_id = p_rec.cart_id
                    and     plan_id = p_rec.plan_id;

                    
                    pl_db_rec.active := p_rec.active;

                    update  mts_shopping_cart_item
                    set     row = pl_db_rec
                    where   cart_id = p_rec.cart_id
                    and     plan_id = p_rec.plan_id;
                exception
                    when no_data_found then
                        raise_application_error(-20001, pl_method_name || 'cart item not found', true);    
                end;    
            end if;

        elsif lower(p_action) = 'delete' then
            if p_rec.cart_id is null or p_rec.plan_id is null then
                raise_application_error(-20001, pl_method_name || 'cart id and plan_id is required to delete cart item.', true); 
            else 
                delete from mts_shopping_cart_item where cart_id = p_rec.cart_id and plan_id = p_rec.plan_id;
            end if; 
        else
            raise_application_error(-20001, pl_method_name || 'Wrong action code.', true); 
        end if;  


    end cart_item;


    

    procedure pay_request(
        p_action            in varchar2,
        p_rec               in out nocopy mts_pay_request%rowtype 
    )
    is
        pl_db_rec              mts_pay_request%rowtype;
    begin

        pl_method_name      := '[pkg_mts_plan].[pay_request][' || p_action  ||'] ';
        if lower(p_action) = 'create' then
            if p_rec.request_id is not null then
                raise_application_error(-20001, pl_method_name || 'request_id needs to be null for new record.', true); 
            else
                p_rec.request_id := sys_guid();
                insert into mts_pay_request values p_rec;   
            end if;
            
            
        elsif lower(p_action) = 'update' then
            if p_rec.request_id is null  then
                raise_application_error(-20001, pl_method_name || 'request_id is required to update pay_request.', true); 
            else
                begin
                    select  * 
                    into    pl_db_rec
                    from    mts_pay_request
                    where   request_id = p_rec.request_id;

                    
                    pl_db_rec.active := p_rec.active;
                    pl_db_rec.pay_session_id    := nvl(p_rec.pay_session_id,pl_db_rec.pay_session_id);
                    pl_db_rec.pay_request       := nvl(p_rec.pay_request,pl_db_rec.pay_request);
                    pl_db_rec.pay_response      := nvl(p_rec.pay_response,pl_db_rec.pay_response);
                    pl_db_rec.is_success        := nvl(p_rec.is_success,pl_db_rec.is_success);
                    pl_db_rec.requested_at      := nvl(p_rec.requested_at,pl_db_rec.requested_at);
                    pl_db_rec.response_at       := nvl(p_rec.response_at,pl_db_rec.response_at);
                    pl_db_rec.active            := nvl(p_rec.active,pl_db_rec.active);
                    
                    update  mts_pay_request
                    set     row = pl_db_rec
                    where   request_id = p_rec.request_id;
                exception
                    when no_data_found then
                        raise_application_error(-20001, pl_method_name || 'pay_request not found', true);    
                end;    
            end if;

        elsif lower(p_action) = 'delete' then
            if p_rec.request_id is null then
                raise_application_error(-20001, pl_method_name || 'request_id is required to delete pay_request.', true); 
            else 
                delete from mts_pay_request where request_id = p_rec.request_id;
            end if; 
        else
            raise_application_error(-20001, pl_method_name || 'Wrong action code.', true); 
        end if;  

    end pay_request;

       
    
end pkg_mts_plan;