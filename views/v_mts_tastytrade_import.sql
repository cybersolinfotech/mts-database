create or replace view v_mts_tastytrade_import_log
AS
select id, user_id, portfolio_id, broker_id, import_type, load_date, start_time, end_time, record_count, success_count, failed_count, load_status, log_msg, active, created_by, create_date, updated_by, update_date
from mts_import_trade_log 
where broker_id in ( select id from mts_broker where lower(broker_name) = 'tastytrade' ) ;


create or replace view v_mts_tastytrade_import_data
as
select  import_trade_log_id,
        line_number,
        col_1 account_number,
        col_2 symbol,
        col_3 instrument_type,
        col_4 underlying_symbol,
        col_5 transaction_type,
        col_6 transaction_sub_type,
        col_7 description,
        col_8 action,
        col_9 quantity,
        col_10 price,
        col_11 executed_at,
        col_12 value,
        col_13 value_effect,
        col_14 regulatory_fees,
        col_15 clearing_fees,
        col_16 net_value,
        col_17 commission,
        col_18 order_id,
        col_19 currency,
        load_status,
        log_msg
from mts_import_trade_data a
join v_mts_tastytrade_import_log b on b.id = a.import_trade_log_id;
