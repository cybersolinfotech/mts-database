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

--table =>   mts_user ---
create table mts_user 
   (	user_id                 varchar2(30 char) not null , 
		first_name              varchar2(60 char), 
		last_name               varchar2(60 char), 
		email                   varchar2(60 char), 
		phone                   varchar2(20), 		
		profile_picture         blob, 
		mbr_type_id             number(1,0) default 1, 
		theme                   varchar2(20) default lower('dark'), 
		dflt_portfolio_id       number(38,0), 
		plan_id         		number, 
		plan_enroll_date     	timestamp (6),
      	pay_customer_id         varchar2(64) ,
		role_id					varchar2(20) not null,
      	active                  number(1,0) default 1 not null ,	    
		created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
        create_date      		timestamp (6) default current_timestamp, 
        updated_by       		varchar2(100) , 
        update_date      		timestamp (6), 
		--		
		constraint mts_user_active_con check ( active in ( 1,0) ) ,
		--
		constraint mts_user_fk1 foreign key (mbr_type_id)  references mts_mbr_type(id) , 
		constraint mts_user_fk2 foreign key (role_id)  references mts_role(role_id) , 
		--
	   	constraint mts_user_pk  primary key (user_id) using index  
   ) ;
/



--table =>   mts_pro_trader
create table mts_pro_trader
	(
		pro_trader_id 	        varchar2(30 char) not null, 
	    amt_to_start       		number(30,2) default 0 not null ,
		expected_return			number(10,2) ,
		about_me                varchar2(4000), 
		strategy                varchar2(1000),
		offer_alert				number(1,0) default 0 not null,
		offer_plan				number(1,0) default 0 not null,
		active                  number(1,0) default 1 not null ,	
	   	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
        create_date      		timestamp (6) default current_timestamp, 
        updated_by       		varchar2(100) , 
        update_date      		timestamp (6),
		--
		constraint mts_pro_trader_con1 check ( active in ( 1,0) ) ,
		constraint pro_pro_trader_con2 check ( offer_alert in ( 1,0) ) ,
		constraint pro_pro_trader_con3 check ( offer_plan in ( 1,0) ) ,
	   	--  
      	constraint pro_pro_trader_fk1 foreign key (pro_trader_id) references mts_user (user_id),
		--
      	constraint mts_pro_trader_pk primary key (pro_trader_id) 
	);
/

--table =>   mts_pro_trader_member
create table mts_pro_trader_member 
   (	pro_trader_id 	           	varchar2(30 char) not null , 
	    member_id 					varchar2(30 char) not null ,
		alert_type_id 				number(1,0) default 0 not null ,
      	active                      number(1,0) default 1 not null ,	 
	   	created_by       			varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
        create_date     			timestamp (6) default current_timestamp, 
        updated_by       			varchar2(100) , 
        update_date      			timestamp (6), 
		--
		constraint mts_pro_trader_member_con1 check ( active in ( 1,0) ) ,
	   	-- 
      	constraint mts_pro_trader_member_fk1 foreign key (pro_trader_id)references mts_pro_trader (pro_trader_id) ,
      	constraint mts_pro_trader_member_fk2 foreign key (member_id) references mts_user (user_id) ,
		constraint mts_pro_trader_member_fk3 foreign key (alert_type_id) references mts_alert_type (id) ,
		--
      	constraint mts_pro_trader_member_pk primary key (pro_trader_id, member_id) 
   ) ;
/



--table =>   mts_api_vendor_token
create table mts_api_vendor_token(
	user_id					varchar2(60) not null,
	vendor_code				varchar2(20) not null,
	token					varchar2(128),
	issued_at 				timestamp default current_timestamp not null ,
	expire_at				timestamp default current_timestamp not null ,
	active                  number(1,0) default 1 not null ,
	created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
	create_date      		timestamp (6) default current_timestamp, 
	updated_by       		varchar2(100) , 
	update_date      		timestamp (6),
	--					
	constraint mts_api_vendor_token_con1 check ( active in ( 1,0) ) ,
	--
	constraint mts_api_vendor_token_fk1	foreign key ( user_id)	 references mts_user(user_id),
	constraint mts_api_vendor_token_fk2	foreign key ( vendor_code)	 references mts_api_vendor(vendor_code),
	--	
	constraint mts_api_vendor_token_pk  primary key (user_id,vendor_code) using index   	

);



