--table =>   mts_symbol
create table mts_tastytrade_tran_stg 
   (
        portfolio_id                VARCHAR2(32) not null,	
        line_number                 number not null,
        account_number              varchar2(100),   
        symbol                      varchar2(100),
        instrument_type             varchar2(100),
        underlying_symbol           varchar2(100),
        transaction_type            varchar2(100),
        transaction_sub_type        varchar2(100),
        description                 varchar2(100),
        action                      varchar2(100),
        quantity                    varchar2(100),
        price                       varchar2(100),
        executed_at                 varchar2(100),
        value                       varchar2(100),
        value_effect                varchar2(100),
        regulatory_fees             varchar2(100),
        clearing_fees               varchar2(100),
        net_value                   varchar2(100),
        commission                  varchar2(100),
        order_id                    varchar2(100),
        currency                    varchar2(100) ,
        --
	   	constraint mts_tastytrade_tran_stg_pk  primary key (portfolio_id,line_number) using index     
   ) ;

create table mts_tastytrade_acct_balance_stg 
   (
        portfolio_id                VARCHAR2(32) not null,
        snapshot_date               varchar2(100),
        account_number              varchar2(100), 
        futures_margin_requirement  varchar2(100), 
        total_settle_balance        varchar2(100), 
        cash_settle_balance         varchar2(100),       
        maintenance_requirement     varchar2(100),
        pending_cash                varchar2(100),
        bond_margin_requirement     varchar2(100),
        long_bond_value             varchar2(100),
        day_trade_excess            varchar2(100),
        cash_available_to_withdraw  varchar2(100),
        
        --
	   	constraint mts_tastytrade_acct_balance_pk  primary key (portfolio_id,snapshot_date) using index     
   ) ;
