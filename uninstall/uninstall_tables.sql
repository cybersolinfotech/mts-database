-- vendor objects
drop table  mts_tastytrade_tran_stg;

-- import trade objects
drop table mts_broker_trade_import_map;
drop table mts_import_trade_data ;
drop table mts_import_trade_log ;
drop table mts_import_trade_config ;


--trade objects
drop table mts_ws_trade;
drop table mts_trade_tran_tag;
drop table mts_trade_tran;
drop table mts_trade_group_tag;
drop table mts_trade_group;
drop table mts_trade_tag;
drop table mts_strategy_template;
drop table mts_strategy;
drop table mts_portfolio_tran;
drop table mts_portfolio;

drop table mts_broker;
drop table mts_symbol;

-- plan objects
drop table mts_pay_request;
drop table mts_shopping_cart_item;
drop table mts_shopping_cart;
drop table mts_plan;
drop table mts_product;


-- user objects
drop table mts_pro_trader_member;
drop table mts_pro_trader;
drop table mts_user_api_token;
drop table mts_user;
drop table mts_role;

-- user app control objects

drop table mts_app_cntrl_value;
drop table mts_app_cntrl;
drop table mts_api_vendor;
DROP TABLE MTS_APP_PROCESS_LOG;

-- Lookup tables.
drop table mts_trade_action;
drop table mts_order_type;
drop table mts_alert_type;
drop table mts_mbr_type;
drop table mts_tran_type;