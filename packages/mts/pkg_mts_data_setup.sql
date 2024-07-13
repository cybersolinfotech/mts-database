/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
CREATE OR REPLACE PACKAGE PKG_MTS_DATA_SETUP
AS
    PROCEDURE SETUP_MTS_DATA;
END PKG_MTS_DATA_SETUP;
/ 


 /*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
CREATE OR REPLACE PACKAGE BODY PKG_MTS_DATA_SETUP    
AS
    


    PROCEDURE SETUP_MTS_DATA
    AS
        pl_app_cntrl_id         mts_app_cntrl.id%type;
        pl_app_cntrl_value_id   mts_app_cntrl_value.id%type;
        pl_user_id              mts_user.user_id%type;
    BEGIN
        
        pkg_mts_sys_util.deploy_mts_sys_trigger;

        --SETUP_ALERT_TYPE;
        insert into mts_alert_type ( alert_type) values ('None');
        insert into mts_alert_type ( alert_type) values ('SMS');
        insert into mts_alert_type ( alert_type) values ('Email');

        --SETUP_MBR_TYPE ;
        insert into mts_mbr_type ( mbr_type) values ('BASIC');
        insert into mts_mbr_type ( mbr_type) values ('TRADER');
        insert into mts_mbr_type ( mbr_type) values ('PRO-TRADER');            
            
        --SETUP_TRADE_ACTION; 
        insert into mts_trade_action ( code,name ) values ('BTO','BUY TO OPEN');
        insert into mts_trade_action ( code,name ) values ('STO','SELL TO OPEN');
        insert into mts_trade_action ( code,name ) values ('BTC','BUY TO CLOSE');
        insert into mts_trade_action ( code,name ) values ('STC','SELL TO CLOSE');
        insert into mts_trade_action ( code,name ) values ('BUY','BUY');
        insert into mts_trade_action ( code,name ) values ('SELL','SELL');
        insert into mts_trade_action ( code,name ) values ('REMO','REMOVAL OF OPTION');

             --SETUP_TRAN_TYPE; 
        insert into mts_tran_type ( code,name ) values ('DEPOSIT','Deposit');
        insert into mts_tran_type ( code,name ) values ('WITHDRAW','Withdraw');
        insert into mts_tran_type ( code,name ) values ('DIVIDEND','Dividend');
        insert into mts_tran_type ( code,name ) values ('CREDIT_INTEREST','Credit Interest');
        insert into mts_tran_type ( code,name ) values ('DEBIT_INTEREST','Debit Interest');

        

        --SETUP_ORDER_TYPE;
        insert into mts_order_type (code, name, display_seq) values ('CALL','CALL',10);
        insert into mts_order_type (code, name, display_seq) values ('PUT','PUT',20);
        insert into mts_order_type (code, name, display_seq) values ('EQUITY','EQUITY',30);
        insert into mts_order_type (code, name, display_seq) values ('FUTURE','FUTURE',40);
        insert into mts_order_type (code, name, display_seq) values ('CRYPTO','CRYPTO',50);

        --SETUP_APP_CONTROL;
        ------------------- Setup MTS_APP config data ------------------------
        pl_app_cntrl_id  := null;
        pkg_mts_app_util.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'MTS_APP_CONFIG' ,
            p_description  => 'My Trade Stat Application Config' ,
            p_active => 1
        );
        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'MTS_APP_CONFIG'),
                    p_key  => 'TIMEZONE',
                    p_str_value  => 'TIMEZONE',
                    p_active => 1);
   
        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'MTS_APP_CONFIG'),
                    p_key  => 'CURRENCY',
                    p_str_value  => 'USD',
                    p_active => 1);
       
        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'MTS_APP_CONFIG'),
                    p_key  => 'LOG_MSG',
                    p_str_value  => 'N',
                    p_active => 1);
 
        ------------------- Setup TASTYTRADE_API config data ------------------------
        pl_app_cntrl_id  := null;
        pkg_mts_app_util.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'TASTYTRADE_API' ,
            p_description  => 'Tasty Trade API setup' ,
            p_active => 1
        );

        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'TASTYTRADE_API'),
                    p_key  => 'BASE_URL',
                    p_str_value  => 'https://api.tastyworks.com/',
                    p_active => 1);

        ------------------- Setup STRIPE config data ------------------------
        pl_app_cntrl_id  := null;
        pkg_mts_app_util.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'STRIPE_API' ,
            p_description  => 'Stripe API setup for payment' ,
            p_active => 1
        );
        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'STRIPE_API'),
                    p_key  => 'PRIVATE_KEY',
                    p_str_value  => 'XXXXXXX',
                    p_active => 1);

        ------------------- Setup FIREBASE_API config data ------------------------
        pl_app_cntrl_id  := null;
        pkg_mts_app_util.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'FIREBASE_API' ,
            p_description  => 'Firebase API setup for authentication' ,
            p_active => 1
        );
        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'FIREBASE_API'),
                    p_key  => 'BASE_URL',
                    p_str_value  => 'https://identitytoolkit.googleapis.com/v1/',
                    p_active => 1);

        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'FIREBASE_API'),
                    p_key  => 'KEY',
                    p_str_value  => 'AIzaSyDyro0ovfeb4eofeLAYJr_ahK4xz3xz18Y',
                    p_active => 1);

        ------------------- Setup AUTH0 config data ------------------------
        pl_app_cntrl_id  := null;
        pkg_mts_app_util.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'AUTH0_API' ,
            p_description  => 'AUTH0 API setup for authentication' ,
            p_active => 1
        );
        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'AUTH0_API'),
                    p_key  => 'BASE_URL',
                    p_str_value  => 'https://dev-yw01mtc1gezxej0n.us.auth0.com/api/v2/',
                    p_active => 1);

        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'AUTH0_API'),
                    p_key  => 'CLIENT_ID',
                    p_str_value  => 'adudqZGOCG0BZ0kdu1MigcmjXB3oGyMy',
                    p_active => 1); 

        pl_app_cntrl_value_id  := null;
        pkg_mts_app_util.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_util.get_app_cntrl_id(p_name => 'AUTH0_API'),
                    p_key  => 'CLIENT_SECRET',
                    p_str_value  => '8QCzJNq_fBDa3nPZLhY9CpKTifu4c_26Xh47iXl91mQTPCx9QgNLbMRw0t1uo5T8',
                    p_active => 1);            
                   
        
        ------------------- SETUP API VENDOR ------------------------
        pkg_mts_api_vendor.set_api_vendor(
            p_vendor_code  => 'TASTYTRADE' ,
            p_vendor_name  => 'Tasty Trade API' ,
            p_token_interval => 1200,
            p_active => 1
        );



        --SETUP_BROKER;
        insert into mts_broker (BROKER_NAME) values ('TASTYTRADE');
        insert into mts_broker (BROKER_NAME) values ('WEBULL');
        insert into mts_broker (BROKER_NAME) values ('E-TRADE');
        insert into mts_broker (BROKER_NAME) values ('FIDELITY');
        insert into mts_broker (BROKER_NAME) values ('ALPACA');

        --SETUP_ROLE;
        pkg_mts_user.merge_role(
                                p_role_id  => 'SUPER-ADMIN',
                                p_role_name => 'Administrator',
                                pl_hierarchy => 100
        );

        pkg_mts_user.merge_role(
                                    p_role_id  => 'ADMIN',
                                    p_role_name => 'Administrator',
                                    pl_hierarchy => 200
        );

        pkg_mts_user.merge_role(
                                    p_role_id  => 'MANAGER',
                                    p_role_name => 'Manager',
                                    pl_hierarchy => 300
        );

        pkg_mts_user.merge_role(
                                    p_role_id  => 'PRO-TRADER',
                                    p_role_name => 'Professional Trader',
                                    pl_hierarchy => 500
        );

        pkg_mts_user.merge_role(
                                    p_role_id  => 'TRADER',
                                    p_role_name => 'Trader',
                                    pl_hierarchy => 600
        );

        pkg_mts_user.merge_role(
                                    p_role_id  => 'BASIC-USER',
                                    p_role_name => 'Basic',
                                    pl_hierarchy => 700
        );

        --SETUP_USER;
        pl_user_id := null;
        pkg_mts_user.register_user(
        p_user_id => pl_user_id,
        p_login_id => 'admin@mytradestat.com',
        p_connection => 'mts',
        p_password => 'Akanksha$801',
        p_theme => 'mts-dark',
        p_role_id => 'SUPER-ADMIN');

        pl_user_id := null;
        pkg_mts_user.register_user(
        p_user_id => pl_user_id,
        p_login_id => 'nishishukla@yahoo.com',
        p_connection => 'mts',
        p_password => 'Anku$801',
        p_theme => 'mts-dark',
        p_role_id => 'SUPER-ADMIN');

        --SETUP_STRATEGY;        
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'VERTICAL','VERTICAL');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'STRANGLE','STRANGLE');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'STRADDLE','STRADDLE');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'SINGLE','SINGLE LEG');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'IRON_CONDOR','IRON CONDOR');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'COVERED','COVEREDR');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'BUTTERFLY','BUTTERFLY');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'IRON_BUTTERFLY','IRON BUTTERFLY');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'JADE_LIZARD','JADE LIZARD');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'CALENDAR','CALENDAR');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'RATIO_SPREAD','RATIO SPREAD');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'FUTURES','FUTURES');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'STOCK','STOCK');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'CRYPTO','CRYPTO');
        insert into mts_strategy (  user_id,name, description) values (PKG_MTS_USER.GET_USER_ID('admin@mytradestat.com'),'CUSTOM','CUSTOM');


        COMMIT;
    EXCEPTION   
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;

        
END PKG_MTS_DATA_SETUP;
/