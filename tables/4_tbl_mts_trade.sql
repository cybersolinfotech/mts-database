
--table =>   mts_symbol
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

--table =>   mts_trade_action
create table mts_trade_action 
   (	code                       varchar2(20 char) not null , 
      name                       varchar2(50 char) not null , 
      active                     number(1,0) default 1 not null ,
      created_by                 varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date                timestamp (6) default current_timestamp, 
      updated_by                 varchar2(100) , 
      update_date                timestamp (6), 
      --
		constraint mts_trade_action_con1 check ( active in ( 1,0) ) ,	   
      --
      constraint mts_trade_action_pk primary key (code) using index  
   ) ;


--table =>   mts_broker
create table mts_broker 
   (	
      id                         number(30,0) default mts_broker_seq.nextval not null, 
      broker_name                varchar2(100 char) collate using_nls_comp, 
      api_available              number(1,0) default 0, 
      import_available           number(1,0) default 0,
      add_header_row		         char(1) default upper('y') not null,
      field_enclosed_by	         char(1) ,
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



--table =>   mts_order_type
create table mts_order_type 
  (	code                    varchar2(10 char) not null , 
      name                    varchar2(50 char) not null , 
      display_seq             number default 0 not null,
      active                  number(1,0) default 1 not null ,
      created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date             timestamp (6) default current_timestamp, 
      updated_by              varchar2(100) , 
      update_date             timestamp (6), 
      --
		constraint mts_order_type_con1 check ( active in ( 1,0) ) ,	 
      -- 
      constraint mts_order_type_pk primary key (code) 
  ) ;


--table =>   mts_portfolio
create table mts_portfolio 
   (	  
      id                       number(30,0)  default mts_portfolio_seq.nextval not null , 
      user_id                  varchar2(30 char) default coalesce(sys_context('apex$session','app_user'),user) not null , 
      broker_id                number(30,0) ,
      portfolio_name           varchar2(50 char) not null , 
      account_num              varchar2(20 char) not null , 
      balance                  number(18,2) default 0 not null , 
      investment_balance       number(18,2) default 0 not null , 
      auto_sync                number(1,0) default 0 not null ,
      broker_login             varchar2(100),
      broker_password          varchar2(100),
      last_import_trade_at     timestamp,
      active                   number(1,0) default 1 not null ,
      created_by               varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date              timestamp (6) default current_timestamp, 
      updated_by               varchar2(100) , 
      update_date              timestamp (6), 
      --
		constraint mts_portfolio_con1 check ( active in ( 1,0) ) ,
      constraint mts_portfolio_con2 check ( auto_sync in ( 1,0) ) ,	
      -- 
      constraint mts_portfolio_fk foreign key (broker_id) references mts_broker (id) ,
      --
      constraint mts_portfolio_pk primary key (id) 
      ) ;



--table =>   mts_portfolio_tran
create table mts_portfolio_tran 
   (	   id                      number(38,0) default mts_portfolio_tran_seq.nextval not null , 
         user_id                 varchar2(30) default coalesce(sys_context('apex$session','app_user'),user) not null , 
         portfolio_id            number(38,0) not null , 
         tran_date               timestamp (6) default current_timestamp not null , 
         tran_type               varchar2(10 char) not null , 
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
         constraint mts_portfolio_tran_con2 check ( upper(tran_type) in ( upper('DEPOSIT'),upper('WITHDRAW') ,upper('TRANSFER') ) ) ,
         -- 
         constraint mts_portfolio_tran_fk foreign key (portfolio_id) references mts_portfolio (id) ,
         --
         constraint mts_portfolio_tran_pk primary key (id) using index  enable
   ) ;



--table =>   mts_order_type
create table mts_strategy 
   (	  
         id 			      number(38,0)  default mts_strategy_seq.nextval not null , 
         user_id 	         varchar2(30 char) default coalesce(sys_context('apex$session','app_user'),user) not null , 
         name 		         varchar2(30 char) not null , 
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
         constraint mts_strategy_pk primary key (id) using index  
   ) ;


--table =>   mts_strategy_template
create table mts_strategy_template 
    (	id               number(38,0) default mts_strategy_template_seq.nextval not null, 
      strategy_id      number(38,0), 
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
      constraint mts_strategy_template_fk foreign key (strategy_id) references mts_strategy (id) ,
      --
      constraint mts_strategy_template_pk primary key ( id )
    ) ;

--table =>   mts_trade_tran
create table mts_trade_tran 
   (	
      id                      number(38,0) default mts_trade_tran_seq.nextval not null, 
      user_id                 varchar2(30 byte) default coalesce(sys_context('apex$session','app_user'),user) not null, 
      portfolio_id            number(38,0) not null, 
      tran_date               timestamp (6) default current_timestamp, 
      symbol                  varchar2(30 byte) , 
      exp_date                timestamp (6) default trunc(current_timestamp), 
      order_type              varchar2(10 char) , 
      strike                  number(20,5),  
      trade_code              varchar2(60 byte) ,       
      action_code             varchar2(20 char) , 
      qty                     number(10,2) , 
      price                   number(10,2), 
      commission              number(10,2),
      fees                    number(10,2),         
      source_order_id         varchar2(100 byte) ,
      group_name              varchar2(100),
      notes                   varchar2(4000),
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
      --
      constraint mts_trade_tran_unq1 unique ( user_id,portfolio_id,tran_date,symbol,trade_code,action_code),    
      --
      constraint mts_trade_tran_pk primary key ( id)
        
   )  ;


   --table =>   mts_trade_vue
create table mts_trade_vue 
   (	
      id                      number(38,0) default mts_trade_vue_seq.nextval not null, 
      user_id                 varchar2(30 ) default coalesce(sys_context('apex$session','app_user'),user) not null, 
      portfolio_id            number(38,0) not null,       
      symbol                  varchar2(30) , 
      exp_date                timestamp (6) default trunc(current_timestamp), 
      order_type              varchar2(10) , 
      strike                  number(20,5), 
      trade_code              varchar2(30) ,
      open_action_code             varchar2(20) , 
      open_date               timestamp (6),
      open_qty                number(10,2) , 
      open_price              number(10,2), 
      open_commission         number(10,2),
      open_fees               number(10,2), 
      close_action_code             varchar2(20) , 
      close_date               timestamp (6),
      close_qty                number(10,2) , 
      close_price              number(10,2), 
      close_commission         number(10,2),
      close_fees               number(10,2),                 
      group_name              varchar2(100),
      notes                   varchar2(4000),
      active                  number(1,0) default 1 not null , 
      created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date             timestamp (6) default current_timestamp, 
      updated_by              varchar2(100) , 
      update_date             timestamp (6),  
      --
      constraint mts_trade_vue_con1 check ( active in ( 1,0) ) ,
      --
      constraint mts_trade_vue_fk1 foreign key (user_id) references mts_user (user_id) ,
      constraint mts_trade_vue_fk2 foreign key (portfolio_id) references mts_portfolio (id) ,
      --
      constraint mts_trade_vue_pk primary key ( id)
        
   )  ;


   create table mts_ws_trade 
   (	seq_no                  number(38,0) not null enable, 
	   user_id                 varchar2(30) default coalesce(sys_context('apex$session','app_user'),user) not null enable, 
      portfolio_id            number(38,0) not null enable, 
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
/