/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_stripe_api
as
    --------------------------------------------------------------------------------------
    --    API : CUSTOMER
    --------------------------------------------------------------------------------------
    procedure create_customer (
        p_pay_customer_id       out mts_user.pay_customer_id%type,
        p_email                 mts_user.email%type,
        p_name                  varchar2
    );

    procedure update_customer (
        p_pay_customer_id       in mts_user.pay_customer_id%type,
        p_email                 mts_user.email%type,
        p_name                  varchar2
    );

    procedure delete_customer ( p_pay_customer_id       in mts_user.pay_customer_id%type);

    --------------------------------------------------------------------------------------
    --    API : PRODUCT
    --------------------------------------------------------------------------------------
    procedure create_product (  p_pay_product_id       out mts_product.pay_product_id%type,
                                p_name                 mts_product.name%type,
                                p_description          mts_product.description%type);

    procedure update_product (  p_pay_product_id       out mts_product.pay_product_id%type,
                                p_name                 mts_product.name%type,
                                p_description          mts_product.description%type);

    procedure delete_product (  p_pay_product_id       in mts_product.pay_product_id%type);

    --------------------------------------------------------------------------------------
    --    API : PLAN
    --------------------------------------------------------------------------------------
    procedure create_plan (     p_pay_plan_id       out mts_plan.pay_plan_id%type,
                                p_product_id            mts_plan.product_id%type,
                                p_name                  mts_plan.name%type,
                                p_amount                mts_plan.amount%type,
                                p_currency              mts_plan.currency%type,
                                p_interval              mts_plan.interval%type,
                                p_interval_count        mts_plan.interval_count%type);

    procedure update_plan (     p_pay_plan_id           mts_plan.pay_plan_id%type,
                                p_name                  mts_plan.name%type,
                                p_amount                mts_plan.amount%type,
                                p_currency              mts_plan.currency%type,
                                p_interval              mts_plan.interval%type,
                                p_interval_count        mts_plan.interval_count%type);

    procedure delete_plan (     p_pay_plan_id           mts_plan.pay_plan_id%type);

end  pkg_stripe_api;
/

 /*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_stripe_api
as

    pl_private_key  constant    mts_app_cntrl_value.str_value%type  := pkg_mts_app_setup.get_app_cntrl_str_value(  p_app_cntrl_name  => 'STRIPE_API',
                                                                                                                                p_key => 'PRIVATE_KEY');   

    pl_base_url     constant    mts_app_cntrl_value.str_value%type  := pkg_mts_app_setup.get_app_cntrl_str_value(  p_app_cntrl_name  => 'STRIPE_API',
                                                                                                             p_key => 'BASE_URL') || '/v1';  

    pl_billing_scheme constant  varchar2(100) := 'per_unit';         

    --------------------------------------------------------------------------------------
    --    API : CUSTOMER
    --------------------------------------------------------------------------------------

    -- create customer --
    procedure create_customer (
        p_pay_customer_id       out mts_user.pay_customer_id%type,
        p_email                 mts_user.email%type,
        p_name                  varchar2
    )
    as
        pl_response         clob;
        pl_param_name         apex_application_global.vc_arr2;
        pl_param_value       apex_application_global.vc_arr2;
        pl_token            varchar2(60);
        pl_url              varchar2(1000);
        pl_index            number := 1;
    begin
        pl_url := pl_base_url || '/customers';
        dbms_output.put_line('[create_customer].[pl_url] = ' || pl_url);
        dbms_output.put_line('[create_customer].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[create_customer].[p_email] = ' || p_email);      
        dbms_output.put_line('[create_customer].[p_name] = ' || p_name);  

        -- build param request
        pl_param_name(pl_index)  := 'name';
        pl_param_value(pl_index) := p_name;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'email';
        pl_param_value(pl_index) := p_email;

        

        -- 
        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';
        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'POST',
                        p_parm_name  => pl_param_name,
                        p_parm_value => pl_param_value);


        dbms_output.put_line('[create_customer].[pl_response] = ' || pl_response);

        apex_json.parse(pl_response);
        
        p_pay_customer_id :=  apex_json.get_varchar2(p_path => 'id');

        dbms_output.put_line('[create_customer].[p_pay_customer_id] = ' || p_pay_customer_id);

    end  create_customer;

    -- update customer --
    procedure update_customer (
        p_pay_customer_id       in mts_user.pay_customer_id%type,
        p_email                 mts_user.email%type,
        p_name                  varchar2
    )
    as
        pl_response         clob;
        pl_param_name         apex_application_global.vc_arr2;
        pl_param_value       apex_application_global.vc_arr2;
        pl_token            varchar2(60);
        pl_url              varchar2(1000);
        pl_index            number := 1;
    begin
        pl_url := pl_base_url || '/customers/' || p_pay_customer_id;
        dbms_output.put_line('[update_customer].[pl_url] = ' || pl_url);
        dbms_output.put_line('[update_customer].[pl_private_key] = ' || pl_private_key);

        dbms_output.put_line('[update_customer].[p_pay_customer_id] = ' || p_pay_customer_id);
        dbms_output.put_line('[update_customer].[p_email] = ' || p_email);      
        dbms_output.put_line('[update_customer].[p_name] = ' || p_name);  

        pl_param_name(pl_index)  := 'name';
        pl_param_value(pl_index) := p_name;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'email';
        pl_param_value(pl_index) := p_email;

        -- 
        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';
        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'POST',
                        p_parm_name  => pl_param_name,
                        p_parm_value => pl_param_value);

        dbms_output.put_line('[update_customer].[pl_response] = ' || pl_response);

        
    end  update_customer;

    -- delete customer --
    procedure delete_customer (
        p_pay_customer_id       in mts_user.pay_customer_id%type
    )
    as
        pl_response         clob;
        pl_url              varchar2(1000);
    begin

        pl_url := pl_base_url || '/customers/' || p_pay_customer_id;
        dbms_output.put_line('[delete_customer].[pl_url] = ' || pl_url);
        dbms_output.put_line('[delete_customer].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[delete_customer].[p_pay_customer_id] = ' || p_pay_customer_id);

        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';

        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'DELETE');
        
        dbms_output.put_line('[delete_customer].[pl_response] = ' || pl_response);

    end delete_customer; 

    --------------------------------------------------------------------------------------
    --    API : PRODUCT
    --------------------------------------------------------------------------------------
    -- create product --
    procedure create_product (  p_pay_product_id       out mts_product.pay_product_id%type,
                                p_name                 mts_product.name%type,
                                p_description          mts_product.description%type)
    as    
        pl_response         clob;
        pl_param_name       apex_application_global.vc_arr2;
        pl_param_value      apex_application_global.vc_arr2;
        pl_token            varchar2(60);
        pl_url              varchar2(1000);
        pl_index            number := 1;
    begin
        pl_url := pl_base_url || '/products';
        dbms_output.put_line('[create_product].[pl_url] = ' || pl_url);
        dbms_output.put_line('[create_product].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[create_product].[p_name] = ' || p_name);      
        dbms_output.put_line('[create_product].[p_description] = ' || p_description);  

        -- build param request       

        pl_param_name(pl_index)  := 'name';
        pl_param_value(pl_index) := p_name;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'description';
        pl_param_value(pl_index) := p_description;

        

        -- 
        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';
        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'POST',
                        p_parm_name  => pl_param_name,
                        p_parm_value => pl_param_value);


        dbms_output.put_line('[create_product].[pl_response] = ' || pl_response);

        apex_json.parse(pl_response);
        
        p_pay_product_id :=  apex_json.get_varchar2(p_path => 'id');

        dbms_output.put_line('[create_product].[p_pay_customer_id] = ' || p_pay_product_id);
    
    end create_product;
    
    -- update product --
    procedure update_product (  p_pay_product_id       out mts_product.pay_product_id%type,
                                p_name                 mts_product.name%type,
                                p_description          mts_product.description%type)
    as
        pl_response         clob;
        pl_param_name         apex_application_global.vc_arr2;
        pl_param_value       apex_application_global.vc_arr2;
        pl_token            varchar2(60);
        pl_url              varchar2(1000);
        pl_index            number := 1;
    begin
        pl_url := pl_base_url || '/products/' || p_pay_product_id;
        dbms_output.put_line('[update_product].[pl_url] = ' || pl_url);
        dbms_output.put_line('[update_product].[pl_private_key] = ' || pl_private_key);

        dbms_output.put_line('[update_product].[p_pay_product_id] = ' || p_pay_product_id);
        dbms_output.put_line('[update_product].[p_name] = ' || p_name);      
        dbms_output.put_line('[update_product].[p_description] = ' || p_description);  

        pl_param_name(pl_index)  := 'name';
        pl_param_value(pl_index) := p_name;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'description';
        pl_param_value(pl_index) := p_description;

        -- 
        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';
        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'POST',
                        p_parm_name  => pl_param_name,
                        p_parm_value => pl_param_value);

        dbms_output.put_line('[update_product].[pl_response] = ' || pl_response);

    end  update_product;

    -- delete product --
    procedure delete_product (
        p_pay_product_id       in mts_product.pay_product_id%type
    )
    as
        pl_response         clob;
        pl_url              varchar2(1000);
    begin

        pl_url := pl_base_url || '/products/' || p_pay_product_id;
        dbms_output.put_line('[delete_product].[pl_url] = ' || pl_url);
        dbms_output.put_line('[delete_product].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[delete_product].[p_pay_product_id] = ' || p_pay_product_id);

        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';

        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'DELETE');

        dbms_output.put_line('[delete_product].[pl_response] = ' || pl_response);

    end delete_product; 

    --------------------------------------------------------------------------------------
    --    API : PRODUCT
    --------------------------------------------------------------------------------------
    -- create plan --
    procedure create_plan (     p_pay_plan_id       out mts_plan.pay_plan_id%type,
                                p_product_id            mts_plan.product_id%type,
                                p_name                  mts_plan.name%type,
                                p_amount                mts_plan.amount%type,
                                p_currency              mts_plan.currency%type,
                                p_interval              mts_plan.interval%type,
                                p_interval_count        mts_plan.interval_count%type)
    as 
        pl_pay_product_id    mts_product.pay_product_id%type  ; 
        pl_response         clob;
        pl_param_name       apex_application_global.vc_arr2;
        pl_param_value      apex_application_global.vc_arr2;
        pl_token            varchar2(60);
        pl_url              varchar2(1000);
        pl_index            number := 1;
    begin
        pl_url := pl_base_url || '/plans';
        dbms_output.put_line('[create_plan].[pl_url] = ' || pl_url);
        dbms_output.put_line('[create_plan].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[create_plan].[p_product_id] = ' || p_product_id);      
        dbms_output.put_line('[create_plan].[p_name] = ' || p_name);  
        dbms_output.put_line('[create_plan].[p_amount] = ' || p_amount);      
        dbms_output.put_line('[create_plan].[p_currency] = ' || p_currency);  
        dbms_output.put_line('[create_plan].[p_interval] = ' || p_interval);      
        dbms_output.put_line('[create_plan].[p_interval_count] = ' || p_interval_count);  

        --get pay_product_id 
        pl_pay_product_id := pkg_mts_plan.get_pay_product_id(p_product_id => p_product_id);


        -- build param request      

        pl_param_name(pl_index)  := 'product';
        pl_param_value(pl_index) := pl_pay_product_id;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'nickname';
        pl_param_value(pl_index) := p_name;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'amount_decimal';
        pl_param_value(pl_index) := p_amount;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'billing_scheme';
        pl_param_value(pl_index) := pl_billing_scheme;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'interval';
        pl_param_value(pl_index) := p_interval;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'interval_count';
        pl_param_value(pl_index) := p_interval_count;
        pl_index := pl_index + 1;
        

        -- 
        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';
        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'POST',
                        p_parm_name  => pl_param_name,
                        p_parm_value => pl_param_value);


        dbms_output.put_line('[create_plan].[pl_response] = ' || pl_response);

        apex_json.parse(pl_response);
        
        p_pay_plan_id :=  apex_json.get_varchar2(p_path => 'id');

        dbms_output.put_line('[create_plan].[p_pay_plan_id] = ' || p_pay_plan_id);
    end create_plan;

    -- update plan --
    procedure update_plan (     p_pay_plan_id           mts_plan.pay_plan_id%type,
                                p_name                  mts_plan.name%type,
                                p_amount                mts_plan.amount%type,
                                p_currency              mts_plan.currency%type,
                                p_interval              mts_plan.interval%type,
                                p_interval_count        mts_plan.interval_count%type)
    as
        pl_response         clob;
        pl_param_name         apex_application_global.vc_arr2;
        pl_param_value       apex_application_global.vc_arr2;
        pl_token            varchar2(60);
        pl_url              varchar2(1000);
        pl_index            number := 1;
    begin
        pl_url := pl_base_url || '/plans/' || p_pay_plan_id;
        dbms_output.put_line('[update_product].[pl_url] = ' || pl_url);
        dbms_output.put_line('[update_product].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[update_product].[p_name] = ' || p_name);  
        dbms_output.put_line('[update_product].[p_amount] = ' || p_amount);      
        dbms_output.put_line('[update_product].[p_currency] = ' || p_currency);  
        dbms_output.put_line('[update_product].[p_interval] = ' || p_interval);      
        dbms_output.put_line('[update_product].[p_interval_count] = ' || p_interval_count);  

        pl_param_name(pl_index)  := 'nickname';
        pl_param_value(pl_index) := p_name;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'amount_decimal';
        pl_param_value(pl_index) := p_amount;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'billing_scheme';
        pl_param_value(pl_index) := pl_billing_scheme;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'interval';
        pl_param_value(pl_index) := p_interval;
        pl_index := pl_index + 1;

        pl_param_name(pl_index)  := 'interval_count';
        pl_param_value(pl_index) := p_interval_count;
        pl_index := pl_index + 1;

        -- 
        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';
        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'POST',
                        p_parm_name  => pl_param_name,
                        p_parm_value => pl_param_value);

        dbms_output.put_line('[update_product].[pl_response] = ' || pl_response);

    end  update_plan;                            

    -- delete plan --
    procedure delete_plan (     p_pay_plan_id           mts_plan.pay_plan_id%type)
    as
        pl_response         clob;
        pl_url              varchar2(1000);
    begin

        pl_url := pl_base_url || '/plans/' || p_pay_plan_id;
        dbms_output.put_line('[delete_product].[pl_url] = ' || pl_url);
        dbms_output.put_line('[delete_product].[pl_private_key] = ' || pl_private_key);
        dbms_output.put_line('[delete_product].[p_pay_plan_id] = ' || p_pay_plan_id);

        apex_web_service.g_request_headers(1).name  := 'authorization';
        apex_web_service.g_request_headers(1).value := 'bearer ' || pl_private_key;
        apex_web_service.g_request_headers(2).name  := 'content-type';
        apex_web_service.g_request_headers(2).value := 'application/x-www-form-urlencoded';

        pl_response := apex_web_service.make_rest_request(
                        p_url => pl_url,
                        p_http_method => 'DELETE');

        dbms_output.put_line('[delete_product].[pl_response] = ' || pl_response);

    end delete_plan; 


end pkg_stripe_api;