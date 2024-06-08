create or replace package pkg_mts_load_data
as
    procedure create_import_log (
        p_import_log_id         out mts_import_trade_log.id%type,
        p_user_id               mts_import_trade_log.user_id%type,
        p_broker_id             mts_import_trade_log.broker_id%type,        
        p_portfolio_id          mts_import_trade_log.portfolio_id%type,
        p_load_date             mts_import_trade_log.load_date%type default current_timestamp
    );  

    procedure tastytrade_sync_trade (    
        p_login         varchar2,
        p_password      varchar2,
        p_user_id       mts_user.user_id%type,
        p_portfolio_id  mts_portfolio.id%type,
        p_broker_id     mts_broker.id%type,
        p_import_log_id out mts_import_trade_log.id%type
    )  ;

end pkg_mts_load_data;
/

create or replace package body pkg_mts_load_data
as
    --------------------------------------------------------------------------------------
    --    PROCEDURE : create_import_log
    --------------------------------------------------------------------------------------
    procedure create_import_log (
        p_import_log_id         out mts_import_trade_log.id%type,
        p_user_id               mts_import_trade_log.user_id%type,
        p_broker_id             mts_import_trade_log.broker_id%type,        
        p_portfolio_id          mts_import_trade_log.portfolio_id%type,
        p_load_date             mts_import_trade_log.load_date%type default current_timestamp
    )
    as
       
    begin
        insert into mts_import_trade_log (user_id,portfolio_id,broker_id,load_date)
        values (p_user_id,p_portfolio_id,p_broker_id,p_load_date) returning id into p_import_log_id;
    exception
        when others then   
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_mts_load_trade',
                P_PROCESS_NAME => 'create_import_log',
                P_MSG_STR => SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250)
            );
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250), true);            
    end create_import_log;

    --------------------------------------------------------------------------------------
    --    PROCEDURE : tastytrade_sync_trade
    --------------------------------------------------------------------------------------
    procedure tastytrade_sync_trade (    
        p_login         varchar2,
        p_password      varchar2,
        p_user_id       mts_user.user_id%type,
        p_portfolio_id  mts_portfolio.id%type,
        p_broker_id     mts_broker.id%type,
        p_import_log_id out mts_import_trade_log.id%type
    )     
    as 
        pl_import_log_id mts_import_trade_log.id%type;
    begin 

        pkg_tastytrade_load.sync_transaction(
            p_login  => p_login,
            p_password => p_password,
            p_user_id => p_user_id,
            p_broker_id => p_broker_id,
            p_portfolio_id => p_portfolio_id,
            p_import_log_id =>  pl_import_log_id   
        );

        p_import_log_id := pl_import_log_id;
    exception
        when others then   
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_mts_load_trade',
                P_PROCESS_NAME => 'tastytrade_sync_trade',
                P_MSG_STR => SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250)
            );
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250), true);     
    end tastytrade_sync_trade;


end pkg_mts_load_data;
/