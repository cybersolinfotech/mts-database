create table mts_symbol 
   (	symbol                     varchar2(20 char) not null , 
      name                       varchar2(100 char) not null , 
      price                      number(10,2) default 0 not null , 
      option_lot_unit            number(10,0) default 100 not null ,
      active                     number(1,0) default 1 not null ,
      created_by                 varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date                timestamp (6) default current_timestamp, 
      updated_by                 varchar2(100) , 
      update_date                timestamp (6), 
      --
		constraint mts_symbol_con1 check ( active in ( 1,0) ) ,	   	 
      --
      constraint mts_symbol_pk   primary key (symbol) using index  
   ) ;



--table =>   mts_broker
create table mts_broker 
   (	
      id                         VARCHAR(32) default sys_guid() not null, 
      broker_name                varchar2(100 char) collate using_nls_comp, 
      api_available              number(1,0) default 0, 
      import_available           number(1,0) default 0,
      add_header_row		         char(1) default upper('y') not null,
      field_enclosed_by	         char(1) ,
      api_instruction            clob,
      import_instruction         clob,
      active                     number(1,0) default 1 not null ,
      created_by                 varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date                timestamp (6) default current_timestamp not null, 
      updated_by                 varchar2(100) , 
      update_date                timestamp (6), 
      --
		constraint mts_broker_con1 check ( active in ( 1,0) ) ,	  
      --
      constraint mts_broker_pk primary key ( id)
   ) ;






--table =>   mts_portfolio
create table mts_portfolio 
   (	  
      id                       VARCHAR2(32) default sys_guid() not null , 
      user_id                  VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null , 
      broker_id                VARCHAR2(32) not null ,
      portfolio_name           varchar2(50 char) not null , 
      account_num              varchar2(20 char) not null , 
      balance                  number(18,2) default 0 not null , 
      investment_balance       number(18,2) default 0 not null , 
      auto_sync                number(1,0) default 0 not null ,
      broker_login             varchar2(100),
      broker_password          varchar2(100),
      last_import_trade_at     timestamp,
      last_account_snapshot_at timestamp,
      active                   number(1,0) default 1 not null ,
      created_by               varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date              timestamp (6) default current_timestamp, 
      updated_by               varchar2(100) , 
      update_date              timestamp (6), 
      --
	  constraint mts_portfolio_con1 check ( active in ( 1,0) ) ,
      constraint mts_portfolio_con2 check ( auto_sync in ( 1,0) ) ,	
      -- 
      constraint mts_portfolio_fk1 foreign key (user_id) references mts_user (user_id) ,
      constraint mts_portfolio_fk2 foreign key (broker_id) references mts_broker (id) ,
      --
      constraint mts_portfolio_pk primary key (id) 
      ) ;



--table =>   mts_portfolio_tran
create table mts_portfolio_tran 
   (	   id                    VARCHAR2(32) default sys_guid() not null , 
         user_id                 VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null , 
         portfolio_id            VARCHAR2(32) not null , 
         tran_date               timestamp (6) default current_timestamp not null , 
         tran_type               varchar2(20 char) not null , 
         tran_source             varchar2(60 char) not null,
         amount                  number(10,2) not null , 
         remarks                 varchar2(1000), 
         active                  number(1,0) default 1 not null ,
         created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
         create_date             timestamp (6) default current_timestamp, 
         updated_by              varchar2(100) , 
         update_date             timestamp (6),
         --
		   constraint mts_portfolio_tran_con1 check ( active in ( 1,0) ) ,	 
         -- 
         constraint mts_portfolio_tran_fk1 foreign key (user_id) references mts_user (user_id) ,
         constraint mts_portfolio_tran_fk2 foreign key (portfolio_id) references mts_portfolio (id) ,
         constraint mts_portfolio_tran_fk3 foreign key (tran_type) references mts_tran_type (code) ,
         --
         constraint mts_portfolio_tran_pk primary key (id) using index  enable
   ) ;



--table =>   mts_order_type
create table mts_strategy 
   (	  
         id 			   VARCHAR2(32) default sys_guid()  not null , 
         user_id 	       VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null , 
         name 		       varchar2(30 char) not null , 
         description       varchar2(100 char) not null , 
         notes             varchar2(4000 char), 
         active            number(1,0) default 1 not null ,
         created_by        varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
         create_date       timestamp (6) default current_timestamp, 
         updated_by        varchar2(100) , 
         update_date       timestamp (6), 
         --
		   constraint mts_strategy_con1 check ( active in ( 1,0) ) ,	 
         --
         constraint mts_strategy_fk1 foreign key (user_id) references mts_user (user_id) ,
         --
         constraint mts_strategy_un11 unique ( user_id,name) ,	 
         --
         constraint mts_strategy_pk primary key (id) using index  
   ) ;


--table =>   mts_strategy_template
create table mts_strategy_template 
    ( id               VARCHAR2(32) default sys_guid() not null, 
      strategy_id      VARCHAR2(32) not null, 
      symbol           varchar2(20), 
      exp_date         timestamp (6), 
      order_type       varchar2(20), 
      strike           number(20,5), 
      action_code      varchar2(20), 
      qty              number(10,2),
      active           number(1,0) default 1 not null , 
      created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date      timestamp (6) default current_timestamp, 
      updated_by       varchar2(100) , 
      update_date      timestamp (6),  
      --
      constraint mts_strategy_template_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_strategy_template_fk1 foreign key (strategy_id) references mts_strategy (id) ,
      --
      constraint mts_strategy_template_pk primary key ( id )
    ) ;

   create table mts_trade_tag
   (
      id               VARCHAR2(32) default sys_guid() not null, 
      user_id          VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null,      
      name             varchar2(100) not null,
      active           number(1,0) default 1 not null , 
      created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date      timestamp (6) default current_timestamp, 
      updated_by       varchar2(100) , 
      update_date      timestamp (6),  
      --
      constraint mts_trade_tag_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_trade_tag_fk1 foreign key (user_id) references mts_user (user_id) ,
      --
      constraint mts_trade_tag_unq1 unique (user_id,name)  ,
      --
      constraint mts_trade_tag_pk primary key ( id )
   );

   create table mts_trade_group
   (
      id               VARCHAR2(32) default sys_guid() not null,
      user_id          VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null, 
      name             varchar2(100) not null,
      trade_tags       varchar2(4000),
      active           number(1,0) default 1 not null , 
      created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date      timestamp (6) default current_timestamp, 
      updated_by       varchar2(100) , 
      update_date      timestamp (6),  
      --
      constraint mts_trade_group_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_trade_group_fk foreign key (user_id) references mts_user (user_id) ,
      --
      constraint mts_trade_group_unq1 unique (user_id,name)  ,
      --
      constraint mts_trade_group_pk primary key ( id )
   );


   create table mts_trade_group_tag
   (
      id               VARCHAR2(32) default sys_guid() not null,
      trage_group_id   VARCHAR2(32) not null,
      trade_tag_id     VARCHAR2(32) not null, 
      active           number(1,0) default 1 not null , 
      created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date      timestamp (6) default current_timestamp, 
      updated_by       varchar2(100) , 
      update_date      timestamp (6),  
      --
      constraint mts_trade_group_tag_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_trade_group_tag_fk1 foreign key (trage_group_id) references mts_trade_group (id) ,
      constraint mts_trade_group_tag_fk2 foreign key (trade_tag_id) references mts_trade_tag (id) ,
      --
      constraint mts_trade_group_tag_unq1 unique (trage_group_id,trade_tag_id)  ,
      --
      constraint mts_trade_group_tag_pk primary key ( id )
   );


--table =>   mts_trade_tran
create table mts_trade_tran 
   (	
      id                      VARCHAR2(32) default sys_guid() not null, 
      user_id                 VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null, 
      portfolio_id            VARCHAR2(32) not null, 
      tran_date               timestamp (6) default current_timestamp, 
      symbol                  varchar2(30) , 
      exp_date                timestamp (6) default trunc(current_timestamp), 
      order_type              varchar2(10 char) , 
      strike                  number(20,5),  
      trade_code              varchar2(60 byte) ,       
      action_code             varchar2(20 char) , 
      qty                     number(10,2) , 
      price                   number(10,2), 
      commission              number(10,2),
      fees                    number(10,2),         
      source_order_id         varchar2(100) ,
      strategy_id             VARCHAR2(32),
      trade_group_id          VARCHAR2(32),
      notes                   varchar2(1000),
      active                  number(1,0) default 1 not null , 
      created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date             timestamp (6) default current_timestamp, 
      updated_by              varchar2(100) , 
      update_date             timestamp (6),  
      --
      constraint mts_trade_tran_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_trade_tran_fk1 foreign key (user_id) references mts_user (user_id) ,
      constraint mts_trade_tran_fk2 foreign key (portfolio_id) references mts_portfolio (id) ,
      constraint mts_trade_tran_fk3 foreign key (trade_group_id) references mts_trade_group (id) ,
      constraint mts_trade_tran_fk4 foreign key (strategy_id) references mts_strategy (id) ,
      --
      --constraint mts_trade_tran_unq1 unique ( user_id,portfolio_id,tran_date,symbol,trade_code,action_code),    
      --
      constraint mts_trade_tran_pk primary key ( id)
        
   )  ;

   create table mts_trade_tran_tag
   (
      id               VARCHAR2(32) default sys_guid() not null,
      trade_tran_id    VARCHAR2(32) not null,
      trade_tag_id     VARCHAR2(32) not null, 
      active           number(1,0) default 1 not null , 
      created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date      timestamp (6) default current_timestamp, 
      updated_by       varchar2(100) , 
      update_date      timestamp (6),  
      --
      constraint mts_trade_tran_tag_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_trade_tran_tag_fk1 foreign key (trade_tran_id) references mts_trade_tran (id) ,
      constraint mts_trade_tran_tag_fk2 foreign key (trade_tag_id) references mts_trade_tag (id) ,
      --
      constraint mts_trade_tran_tag_unq1 unique (trade_tran_id,trade_tag_id)  ,
      --
      constraint mts_trade_tran_tag_pk primary key ( id )
   );
 


   create table mts_ws_trade 
   (  seq_no                  number(38,0) not null , 
	   user_id                  VARCHAR2(32) default coalesce(sys_context('apex$session','app_user'),user) not null , 
      portfolio_id            VARCHAR2(32) not null , 
      tran_date               timestamp (6) default current_timestamp, 
      trade_code              varchar2(60), 
      symbol                  varchar2(30), 
      exp_date                timestamp (6) default trunc(current_timestamp), 
      order_type              varchar2(10 char), 
      strike                  number(20,5), 
      action_code             varchar2(20 char), 
      qty                     number(10,2), 
      price                   number(10,2), 
      commission              number(10,2), 
      fees                    number(10,2), 
      source_order_id         varchar2(100), 
      group_name              varchar2(100),
      notes                   varchar2(4000),
      --
      constraint mts_ws_trade_fk1 foreign key (user_id) references mts_user (user_id),
      constraint mts_ws_trade_fk2 foreign key (portfolio_id) references mts_portfolio (id),
      --
      constraint mts_ws_trade_pk primary key ( seq_no, user_id) 
      
   ) ;

  create index mts_ws_trade_idx on mts_ws_trade (user_id) ;
