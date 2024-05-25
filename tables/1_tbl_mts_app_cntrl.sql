--table =>   mts_api_vendor
create table mts_api_vendor
(
	vendor_code						varchar2(20) not null,
	vendor_name						varchar2(100) not null,
	token_interval					number(10) default 0 not null ,
	active                  		number(1,0) default 1 not null ,
	created_by       				varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      				timestamp (6) default current_timestamp, 
	updated_by       				varchar2(100) , 
	update_date      				timestamp (6),
	--					
	constraint mts_api_vendor_con1 check ( active in ( 1,0) ) ,
	--	
	constraint mts_api_vendor_pk  primary key (vendor_code) using index   

);


--table =>   mts_mbr_type
create table mts_mbr_type (
	id				number(38,0) default mts_mbr_type_seq.nextval not null,
	mbr_type				varchar2(60) not null,
	active                  number(1,0) default 1 not null ,
	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      		timestamp (6) default current_timestamp, 
	updated_by       		varchar2(100) , 
	update_date      		timestamp (6), 	
	--					
	constraint mts_mbr_type_con1 check ( active in ( 1,0) ) ,	
	--
	constraint mts_mbr_type  primary key (id) using index  
);


--table =>   mts_alert_type
create table mts_alert_type (
	id						number(38,0) default mts_alert_type_seq.nextval not null,
	alert_type				varchar2(60) not null,
	active                  number(1,0) default 1 not null ,
	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      		timestamp (6) default current_timestamp, 
	updated_by       		varchar2(100) , 
	update_date      		timestamp (6), 	
	--					
	constraint mts_alert_type_con1 check ( active in ( 1,0) ) ,
	--
	constraint mts_alert_type  primary key (id) using index  
);





--table =>   mts_app_cntrl
create table mts_app_cntrl 
(	id               number(38,0) default mts_app_cntrl_seq.nextval not null , 
	name             varchar2(30 ) not null , 
	description      varchar2(200), 
	active                  number(1,0) default 1 not null ,
	created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      timestamp (6) default current_timestamp, 
	updated_by       varchar2(100) , 
	update_date      timestamp (6), 
	constraint mts_app_cntrl_con  check ( active in ( 1,0) ) , 
	constraint mts_app_cntrl_pk   primary key (id) using index  
) ;

create unique index mts_app_cntrl_unq on  mts_app_cntrl (name );

--table =>   mts_app_cntrl_value
create table mts_app_cntrl_value 
(	id               number(38,0) default mts_app_cntrl_value_seq.nextval not null , 
	app_cntrl_id     number(38,0) not null,
	key              varchar2(30 ) not null , 
	str_value        varchar2(200),
	timestamp_value       timestamp,
	number_value   number, 
	active                  number(1,0) default 1 not null ,
	created_by       varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      timestamp (6) default current_timestamp, 
	updated_by       varchar2(100) , 
	update_date      timestamp (6), 
	constraint mts_app_cntrl_value_con  check ( active in ( 1,0) ) ,
	constraint mts_app_cntrl_value_fk1	foreign key ( app_cntrl_id)	 references mts_app_cntrl(id),
	constraint mts_app_cntrl_value_pk   primary key (id) using index  
);

create unique index mts_app_cntrl_value_unq on  mts_app_cntrl_value (app_cntrl_id,key );



