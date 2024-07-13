
--table =>   mts_user ---
create table mts_user 
   (	user_id					VARCHAR2(32 char) DEFAULT sys_guid() not null,
   		login_id                varchar2(60 char) not null, 
		connection				varchar2(60 char) ,
		password				varchar2(250 char),
		first_name              varchar2(60 char), 
		last_name               varchar2(60 char), 		
		email                   varchar2(60 char), 
		phone                   varchar2(20), 		
		profile_picture         blob, 
		mbr_type_id             VARCHAR2(32), 
		theme                   varchar2(20) default lower('dark'), 
		dflt_portfolio_id       VARCHAR2(32), 
		plan_id         		VARCHAR2(32), 
		plan_enroll_date     	timestamp (6),
      	pay_customer_id         varchar2(64) ,
		role_id					varchar2(20) not null,
		failed_login_attempt	number(1,0) default 0 not null,		 
		email_verified			number(1,0) default 0 not null ,
		phone_verified			number(1,0) default 0 not null ,
		pwd_reset_code			varchar2(60) ,
		pwd_reset_expired_at	timestamp(6) ,
		account_locked			number(1,0) default 0 not null ,
      	active                  number(1,0) default 1 not null ,	    
		created_by       		varchar2(100) default coalesce(sys_context('apex$session','app_user'),user) not null,            
        create_date      		timestamp (6) default current_timestamp, 
        updated_by       		varchar2(100) , 
        update_date      		timestamp (6), 
		--		
		constraint mts_user_active_con check ( active in ( 1,0) ) ,
		constraint mts_user_email_verified_con check ( email_verified in ( 1,0) ) ,
		constraint mts_user_phone_verified_con check ( phone_verified in ( 1,0) ) ,
		constraint mts_user_account_locked_con check ( account_locked in ( 1,0) ) ,
		--
		constraint mts_user_fk1 foreign key (mbr_type_id)  references mts_mbr_type(id) , 
		constraint mts_user_fk2 foreign key (role_id)  references mts_role(role_id) , 
		--
		constraint mts_user_unq1 unique (login_id, connection)  , 
		--
	   	constraint mts_user_pk  primary key (user_id) using index  
   ) ;
/



--table =>   mts_pro_trader
create table mts_pro_trader
	(
		pro_trader_id 	        VARCHAR2(32)  not null, 
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
   (	pro_trader_id 	           	VARCHAR(32) not null , 
	    member_id 					VARCHAR(32) not null ,
		alert_type_id 				VARCHAR(32) not null ,
		youtube_url					varchar2(200),
		discord_channel				varchar2(200),
		fb_channel					varchar2(200),
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




