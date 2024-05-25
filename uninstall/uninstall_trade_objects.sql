drop sequence mts_broker_seq;
drop sequence mts_import_trade_log_seq;
drop sequence mts_portfolio_seq ;
drop sequence mts_portfolio_tran_seq ;
drop sequence mts_strategy_seq ;
drop sequence mts_strategy_template_seq ;
drop sequence mts_trade_group_seq ;
drop sequence mts_trade_vue_seq ;
drop sequence mts_trade_tran_seq ;

drop trigger mts_trade_biud;
drop trigger mts_portfolio_tran_biud;

drop view v_mts_trade_vue;
drop view v_mts_trade_position;

drop package pkg_mts_ws_trade;
drop package pkg_mts_trade;

drop table mts_trade_vue;
drop table mts_trade_tran;
drop table mts_trade;
drop table mts_strategy_template;
drop table mts_strategy;
drop table mts_portfolio_tran;
drop table mts_portfolio;
drop table mts_order_type;
drop table mts_broker;
drop table mts_trade_action;
drop table mts_symbol;
