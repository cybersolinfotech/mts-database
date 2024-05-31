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
    PROCEDURE SETUP_MBR_TYPE
    AS
    BEGIN
        

        insert into mts_mbr_type ( mbr_type) values ('DEMO');
        insert into mts_mbr_type ( mbr_type) values ('TRADER');
        insert into mts_mbr_type ( mbr_type) values ('PRO-TRADER');

        COMMIT;

    END;

    PROCEDURE SETUP_TRADE_ACTION
    AS
    BEGIN
        insert into mts_trade_action ( code,name ) values ('BTO','BUY TO OPEN');
        insert into mts_trade_action ( code,name ) values ('STO','SELL TO OPEN');
        insert into mts_trade_action ( code,name ) values ('BTC','BUY TO CLOSE');
        insert into mts_trade_action ( code,name ) values ('STC','SELL TO CLOSE');
        insert into mts_trade_action ( code,name ) values ('BUY','BUY');
        insert into mts_trade_action ( code,name ) values ('SELL','SELL');
        insert into mts_trade_action ( code,name ) values ('REMO','REMOVAL OF OPTION');
        COMMIT;
    END;

    PROCEDURE SETUP_ORDER_TYPE
    AS
    BEGIN
        insert into mts_order_type (code, name, display_seq) values ('CALL','CALL',10);
        insert into mts_order_type (code, name, display_seq) values ('PUT','PUT',20);
        insert into mts_order_type (code, name, display_seq) values ('EQUITY','EQUITY',30);
        insert into mts_order_type (code, name, display_seq) values ('FUTURE','FUTURE',40);
        insert into mts_order_type (code, name, display_seq) values ('CRYPTO','CRYPTO',50);
        COMMIT;
    END;

    PROCEDURE SETUP_STRATEGY
    AS
    BEGIN
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','VERTICAL','VERTICAL');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','STRANGLE','STRANGLE');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','STRADDLE','STRADDLE');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','OPTION','OPTION');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','IRON CONDOR','IRON CONDOR');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','COVERED','COVEREDR');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','BUTTERFLY','BUTTERFLY');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','IRON BUTTERFLY','IRON BUTTERFLY');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','JADE LIZARD','JADE LIZARD');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','CALENDAR','CALENDAR');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','RATIO SPREAD','RATIO SPREAD');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','FUTURES','FUTURES');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','STOCK','STOCK');
        insert into mts_strategy (  user_id,name, description) values ('ADMIN','CRYPTO','CRYPTO');
        COMMIT;
    END;

    PROCEDURE SETUP_ROLE
    AS
    BEGIN
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
                                    p_role_id  => 'DEMO-USER',
                                    p_role_name => 'Demo Trader',
                                    pl_hierarchy => 700
        );

        pkg_mts_user.register_user(
        p_user_id => 'nishishukla@yahoo,com',
        p_email => 'nishishukla@yahoo,com',
        p_theme => 'dark',
        p_role_id => 'SUPER-ADMIN'
    );
        COMMIT;
    END;

    PROCEDURE SETUP_APP_CONTROL
    AS
        pl_app_cntrl_id     number(30);
        pl_app_cntrl_value_id number(30);
    BEGIN
        ------------------- Setup MTS_APP config data ------------------------
        pkg_mts_app_setup.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'MTS_APP_CONFIG' ,
            p_description  => 'My Trade Stat Application Config' ,
            p_active => 1
        );

        pkg_mts_app_setup.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_setup.get_app_cntrl_id(p_name => 'MTS_APP_CONFIG'),
                    p_key  => 'TIMEZONE',
                    p_str_value  => 'TIMEZONE',
                    p_active => 1);
        
        pkg_mts_app_setup.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_setup.get_app_cntrl_id(p_name => 'MTS_APP_CONFIG'),
                    p_key  => 'CURRENCY',
                    p_str_value  => 'USD',
                    p_active => 1);

        pkg_mts_app_setup.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_setup.get_app_cntrl_id(p_name => 'MTS_APP_CONFIG'),
                    p_key  => 'LOG_LEVEL',
                    p_str_number  => 9999,
                    p_active => 1);

        ------------------- Setup TASTYTRADE_API config data ------------------------
        pkg_mts_app_setup.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'TASTYTRADE_API' ,
            p_description  => 'Tasty Trade API setup' ,
            p_active => 1
        );

        pkg_mts_app_setup.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_setup.get_app_cntrl_id(p_name => 'TASTYTRADE_API'),
                    p_key  => 'BASE_URL',
                    p_str_value  => 'https://api.tastyworks.com/',
                    p_active => 1);

        ------------------- Setup STRIPE config data ------------------------
        pkg_mts_app_setup.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'STRIPE_API' ,
            p_description  => 'Stripe API setup for payment' ,
            p_active => 1
        );

        pkg_mts_app_setup.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_setup.get_app_cntrl_id(p_name => 'STRIPE_API'),
                    p_key  => 'PRIVATE_KEY',
                    p_str_value  => 'XXXXXXX',
                    p_active => 1);

        ------------------- Setup TASTYTRADE config data ------------------------
        pkg_mts_app_setup.set_app_cntrl(
            p_app_cntrl_id => pl_app_cntrl_id,
            p_name  => 'TASTYTRADE_API' ,
            p_description  => 'TastyTrade API setup for broker' ,
            p_active => 1
        );

        pkg_mts_app_setup.set_app_cntrl_value(
                    p_app_cntrl_value_id => pl_app_cntrl_value_id,
                    p_app_cntrl_id => pkg_mts_app_setup.get_app_cntrl_id(p_name => 'TASTYTRADE_API'),
                    p_key  => 'BASE_URL',
                    p_str_value  => 'https://api.tastyworks.com/',
                    p_active => 1);

        ------------------- SETUP API VENDOR ------------------------
        pkg_mts_app_setup.set_api_vendor(
            p_vendor_code  => 'TASTYTRADE' ,
            p_vendor_name  => 'Tasty Trade API' ,
            p_token_interval => 1200,
            p_active => 1
        );
        COMMIT;
    END;

    PROCEDURE SETUP_BROKER
    AS
    BEGIN
        insert into mts_broker (BROKER_NAME) values ('TASTYTRADE');
        insert into mts_broker (BROKER_NAME) values ('WEBULL');
        insert into mts_broker (BROKER_NAME) values ('E-TRADE');
        insert into mts_broker (BROKER_NAME) values ('FIDELITY');
        insert into mts_broker (BROKER_NAME) values ('ALPACA');
        COMMIT;
    END;


    PROCEDURE SETUP_MTS_DATA
    AS
    BEGIN
        SETUP_MBR_TYPE ;
        SETUP_TRADE_ACTION;   
        SETUP_ORDER_TYPE;
        SETUP_STRATEGY;
        SETUP_ROLE;
        SETUP_APP_CONTROL;
        SETUP_BROKER;
    END;
END PKG_MTS_DATA_SETUP;
/