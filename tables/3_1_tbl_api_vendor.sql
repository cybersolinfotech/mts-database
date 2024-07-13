--table =>   mts_api_vendor
create table mts_api_vendor
(
	vendor_code						varchar2(20) not null,
	vendor_name						varchar2(100) not null,
	token_interval					number(10) default 0 not null ,
	access_token					varchar2(4000),
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



--table =>   mts_api_vendor_token
create table mts_user_api_token(
	user_id					VARCHAR(32) not null,
	vendor_code				varchar2(20) not null,
	token					varchar2(4000),
	issued_at 				timestamp default current_timestamp not null ,
	expire_at				timestamp default current_timestamp not null ,
	active                  number(1,0) default 1 not null ,
	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      		timestamp (6) default current_timestamp, 
	updated_by       		varchar2(100) , 
	update_date      		timestamp (6),
	--					
	constraint mts_user_api_token_con1 check ( active in ( 1,0) ) ,
	--
	constraint mts_user_api_token_fk1	foreign key ( user_id)	 references mts_user(user_id),
	constraint mts_user_api_token_fk2	foreign key ( vendor_code)	 references mts_api_vendor(vendor_code),
	--	
	constraint mts_user_api_token_pk  primary key (user_id,vendor_code) using index   	

);
