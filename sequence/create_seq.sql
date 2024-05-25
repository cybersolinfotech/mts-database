-- app
create sequence mts_app_cntrl_seq minvalue 1 cache 20;
create sequence mts_app_cntrl_value_seq minvalue 1 cache 20;
create sequence mts_mbr_type_seq minvalue 1 cache 20;
create sequence mts_alert_type_seq minvalue 1 cache 20;

-- plan
create sequence mts_product_seq  minvalue 1 cache 20;
create sequence mts_plan_seq  minvalue 1 cache 20;
create sequence mts_shopping_cart_seq  minvalue 1 cache 20;
create sequence mts_pay_request_seq  minvalue 1 cache 20;

-- trade
create sequence mts_broker_seq  minvalue 1 cache 20;
create sequence mts_portfolio_seq  minvalue 1 cache 20;
create sequence mts_portfolio_tran_seq  minvalue 1 cache 20;
create sequence mts_strategy_seq  minvalue 1 cache 20;
create sequence mts_strategy_template_seq  minvalue 1 cache 20;
create sequence mts_trade_group_seq  minvalue 1 cache 20;
create sequence mts_trade_seq  minvalue 1 cache 20;
create sequence mts_trade_tran_seq  minvalue 1 cache 20;
create sequence mts_trade_vue_seq  minvalue 1 cache 20;



--import trade
create sequence mts_broker_trade_import_map_seq  minvalue 1 cache 20;
create sequence mts_import_trade_config_seq  minvalue 1 cache 20;
create sequence mts_import_trade_log_seq  minvalue 1 cache 20;