--table =>   mts_broker_trade_import_map
create table mts_broker_trade_import_map(
    id                          number(38,0) default mts_import_trade_config_seq.nextval not null,
    broker_id                   number(38,0)     not null,
    import_type                 varchar2(10)     not null,
    stg_column                  varchar2(100)    not null,
    source_column               varchar2(100)    not null,    
    target_column               varchar2(100)    ,
    active                      number(1,0) default 1 not null ,
    created_by                  varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                 timestamp (6) default current_timestamp, 
    updated_by                  varchar2(100) , 
    update_date                 timestamp (6),  
    --
	constraint mts_broker_trade_import_ma_con1 check ( active in ( 1,0) ) ,	
    -- 
    constraint mts_broker_trade_import_ma_fk1 foreign key ( broker_id) references mts_broker(id),
    --
    constraint mts_broker_trade_import_map_unq1 unique ( broker_id,stg_column, import_type) ,
    --    
    constraint mts_broker_trade_import_map_pk primary key ( id ) 
);

--table =>   mts_import_trade_config
create table mts_import_trade_config 
(	id                          number(38,0) default mts_import_trade_config_seq.nextval not null,
    broker_id                   number(38,0)     not null,
    target_column               varchar2(100)    not null,
    expression                  varchar2(4000)     ,
    active                      number(1,0) default 1 not null ,
    created_by                  varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date                 timestamp (6) default current_timestamp, 
    updated_by                  varchar2(100) , 
    update_date                 timestamp (6),  
    
    --
	constraint mts_import_trade_config_con1 check ( active in ( 1,0) ) ,	
    -- 
    constraint mts_import_trade_config_fk1 foreign key ( broker_id) references mts_broker(id),
    --
    constraint mts_import_trade_config_unq1 unique ( broker_id,target_column) ,
    --    
    constraint mts_import_trade_config_pk primary key ( id ) 
);
/



--table =>   mts_import_trade_log
create table mts_import_trade_log 
(	id                      number(38,0) default mts_import_trade_log_seq.nextval not null,
    user_id                 varchar2(50) default coalesce(sys_context('apex$session','app_user'),user) not null,
    portfolio_id            number(38,0) not null,
    broker_id               number(38,0),  
    import_type             varchar2(10)  default 'FILE' not null,        
    load_date               timestamp (6), 
    start_time              timestamp (6), 
    end_time                timestamp (6), 
    record_count            number(10,0) default 0, 
    success_count           number(10,0), 
    failed_count            number(10,0), 
    load_status             char(1 char)  default upper('Y'), 
    log_msg                 varchar2(4000 char) ,
    active                  number(1,0) default 1 not null ,
    created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
    create_date             timestamp (6) default current_timestamp, 
    updated_by              varchar2(100) , 
    update_date             timestamp (6), 
    --
	constraint mts_import_trade_log_con1 check ( active in ( 1,0) ) ,
    -- 
    constraint mts_import_trade_log_fk1 foreign key ( portfolio_id) references mts_portfolio(id),
    constraint mts_import_trade_log_fk2 foreign key ( broker_id) references mts_broker(id),
    --
    constraint mts_import_trade_log_pk primary key ( id)
)  ;
/

--table =>   mts_import_trade_data
create table mts_import_trade_data 
(	    import_trade_log_id     number(38,0) not null,     
        line_number             number(38) not null,
        col_1                   varchar2(1000),
        col_2                   varchar2(1000),
        col_3                   varchar2(1000),
        col_4                   varchar2(1000),
        col_5                   varchar2(1000),
        col_6                   varchar2(1000),
        col_7                   varchar2(1000),
        col_8                   varchar2(1000),
        col_9                   varchar2(1000),
        col_10                  varchar2(1000),
        col_11                  varchar2(1000),
        col_12                  varchar2(1000),
        col_13                  varchar2(1000),
        col_14                  varchar2(1000),
        col_15                  varchar2(1000),
        col_16                  varchar2(1000),
        col_17                  varchar2(1000),
        col_18                  varchar2(1000),
        col_19                  varchar2(1000),
        col_20                  varchar2(1000),
        col_21                  varchar2(1000),
        col_22                  varchar2(1000),
        col_23                  varchar2(1000),
        col_24                  varchar2(1000),
        col_25                  varchar2(1000),
        load_status             char(1) default 'N' not null,
        log_msg                 varchar2(4000),
        active                  number(1,0) default 1 not null ,
        created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
        create_date             timestamp (6) default current_timestamp, 
        updated_by              varchar2(100) , 
        update_date             timestamp (6), 
        --
	    constraint mts_import_trade_data_con1 check ( active in ( 1,0) ) ,
        -- 
        constraint mts_import_trade_data_fk1 foreign key ( import_trade_log_id ) references  mts_import_trade_log (id),
        --
        constraint mts_import_trade_data_pk primary key ( import_trade_log_id, line_number)
     
);
/