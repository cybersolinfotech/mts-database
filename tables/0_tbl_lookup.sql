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
      constraint mts_trade_action_unq1 unique ( name) ,	 	   
      --
      constraint mts_trade_action_pk primary key (code) using index  
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
      constraint mts_order_type_unq1 unique ( name) ,	 
      -- 
      constraint mts_order_type_pk primary key (code) 
  ) ;

--table =>   mts_tran_type
create table mts_tran_type 
  (	code                    varchar2(20 char) not null , 
      name                    varchar2(50 char) not null , 
      display_seq             number default 0 not null,
      active                  number(1,0) default 1 not null ,
      created_by              varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
      create_date             timestamp (6) default current_timestamp, 
      updated_by              varchar2(100) , 
      update_date             timestamp (6), 
      --
		constraint mts_tran_type_con1 check ( active in ( 1,0) ) ,	 
      -- 
      constraint mts_tran_type_unq1 unique ( name) ,	 
      --
      constraint mts_tran_type_pk primary key (code) 
  ) ;


  --table =>   mts_mbr_type
create table mts_mbr_type (
	id						VARCHAR2(32) DEFAULT sys_guid() not null,
	mbr_type				varchar2(60) not null,
	active                  number(1,0) default 1 not null ,
	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      		timestamp (6) default current_timestamp, 
	updated_by       		varchar2(100) , 
	update_date      		timestamp (6), 	
	--					
	constraint mts_mbr_type_con1 check ( active in ( 1,0) ) ,	
	--
   constraint mts_mbr_type_unq1 unique (mbr_type )  ,	
	--
	constraint mts_mbr_type  primary key (id) using index  
);


--table =>   mts_alert_type
create table mts_alert_type (
	id						VARCHAR2(32) DEFAULT sys_guid() not null,
	alert_type				varchar2(60) not null,
	active                  number(1,0) default 1 not null ,
	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      		timestamp (6) default current_timestamp, 
	updated_by       		varchar2(100) , 
	update_date      		timestamp (6), 	
	--					
	constraint mts_alert_type_con1 check ( active in ( 1,0) ) ,
   --
   constraint mts_alert_typ_unq1 unique (alert_type )  ,	
	--
	constraint mts_alert_type  primary key (id) using index  
);

--table =>   mts_role ---
create table mts_role 
   (	role_id                 varchar2(20 char) not null , 
	   	role_name               varchar2(60 char) not null , 
	   	hierarchy               number(10,0) default 9999999 not null , 
	   	active                  number(1,0) default 1 not null ,	
		created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
        create_date      		timestamp (6) default current_timestamp, 
        updated_by       		varchar2(100) , 
        update_date      		timestamp (6), 
		-- 
		constraint mts_role_con1 check ( active in ( 1,0) ) , 
		--
	   	constraint mts_role_pk  primary key (role_id) using index  
   ) ;
/
