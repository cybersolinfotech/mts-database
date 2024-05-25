


CREATE TABLE mts_product (
    id                              NUMBER(38,0)     default mts_product_seq.nextval  not null,
    user_id                         VARCHAR2(30)    not null,
    name                            VARCHAR2(256)    not null,
    description                     VARCHAR2(4000),
    pay_product_id                  VARCHAR2(64),
    active                          number(1,0) default 1 not null ,
    created_by                      varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                     timestamp (6) default current_timestamp, 
    updated_by                      varchar2(100) , 
    update_date                     timestamp (6), 
    --
	constraint mts_product_con1 check ( active in ( 1,0) ) ,	
    --
    --
    CONSTRAINT mts_product_unq1 UNIQUE (pay_product_id),
    constraint mts_product_unq2 unique ( user_id,name),    
    --    
    CONSTRAINT mts_product_pk PRIMARY KEY (id)
);
/

--drop table mts_plan;
CREATE TABLE mts_plan (
    id                              NUMBER(38,0)        default mts_plan_seq.nextval  not null,
    product_id                      NUMBER(38,0)       not null,
    name                            VARCHAR2(256)    not null,
    description                     VARCHAR2(4000),
    amount                          number(10,2)    not null,
    currency                        varchar2(10),
    interval                        varchar2(10),
    interval_count                  number(2,0) ,
    pay_plan_id                     varchar2(64),
    active                          number(1,0) default 1 not null ,
    created_by                      varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                     timestamp (6) default current_timestamp, 
    updated_by                      varchar2(100) , 
    update_date                     timestamp (6), 
    --
	constraint mts_plan_con1 check ( active in ( 1,0) ) ,	
    --
    constraint mts_plan_fk1 foreign key (product_id) references mts_product ( id),
    --
    CONSTRAINT mts_plan_unq1 UNIQUE (pay_plan_id),
    constraint mts_plan_unq2 unique (product_id,name),
    
    --    
    CONSTRAINT mts_plan_pk PRIMARY KEY (id)
);
/





CREATE TABLE mts_shopping_cart (
    cart_id                     NUMBER(38,0)     default mts_shopping_cart_seq.nextval  not null,
    user_id                     varchar2(30)      NOT NULL,
    is_closed                   number(1,0)     default 1 not null ,
    active                      number(1,0)     default 1 not null ,
    created_by                  varchar2(100)    default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                 timestamp (6)    default current_timestamp, 
    updated_by                  varchar2(100) , 
    update_date                 timestamp (6), 
    --
	constraint mts_shopping_cart_con1 check ( active in ( 1,0) ) ,	
    constraint mts_shopping_cart_con2 check ( is_closed in ( 1,0) ) ,	
    --
    constraint  mts_shopping_cart_fk1 foreign key (user_id) references mts_user(user_id),
    --
    constraint  mts_shopping_cart_pk primary key ( cart_id ) 
);
/

CREATE TABLE mts_shopping_cart_item (
    cart_id                         NUMBER(38,0)     NOT NULL,
    plan_id                         NUMBER(38,0)     NOT NULL,
    amount                          NUMBER(16,4)     NOT NULL,
    active                          number(1,0)     default 1 not null ,
    created_by                      varchar2(100)    default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                     timestamp (6)    default current_timestamp, 
    updated_by                      varchar2(100) , 
    update_date                     timestamp (6),  
    --
    constraint mts_shopping_cart_item_con1 check ( active in ( 1,0) ) ,	
    --
    constraint  mts_shopping_cart_item_fk1 foreign key ( cart_id) references mts_shopping_cart(cart_id),
    constraint  mts_shopping_cart_item_fk2 foreign key ( plan_id) references mts_plan(id),
    --
    constraint  mts_shopping_cart_item_pk primary key ( cart_id ,plan_id) 
    
);
/


CREATE TABLE mts_pay_request (
    request_id                      NUMBER(38,0)     default mts_pay_request_seq.nextval   NOT NULL,
    cart_id                         NUMBER(38,0)     NOT NULL,
    user_id                         varchar2(30)     NOT NULL,
    session_id                      NUMBER(38,0)     default sys_context('apex$session', 'app_session'),
    api_token                       VARCHAR2(64),
    api_response                    CLOB,
    is_success                      number(1,0) default 0 not null ,
    requested_at                    timestamp (6)             NOT NULL,
    response_at                     timestamp (6),
    active                          number(1,0) default 1 not null ,
    created_by                      varchar2(100)    default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                     timestamp (6)    default current_timestamp, 
    updated_by                      varchar2(100) , 
    update_date                     timestamp (6),  
    --
    constraint mts_pay_request_con1 check ( active in ( 1,0) ) ,	
    constraint mts_pay_request_con2 check ( is_success in ( 1,0) ) ,	
    --
    constraint  mts_pay_request_fk1 foreign key ( cart_id) references mts_shopping_cart(cart_id),
    constraint  mts_pay_request_fk2 foreign key ( user_id) references mts_user(user_id),
    --
    constraint  mts_pay_request_pk primary key ( request_id) 
);
/