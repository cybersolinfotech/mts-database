create or replace package pkg_mts_load_data
as
    procedure create_import_log (
        p_import_log_id         out mts_import_trade_log.id%type,
        p_user_id               mts_import_trade_log.user_id%type,
        p_broker_id             mts_import_trade_log.broker_id%type,        
        p_portfolio_id          mts_import_trade_log.portfolio_id%type,
        p_load_date             mts_import_trade_log.load_date%type default current_timestamp
    ); 

    

    procedure sync_trade(
        p_portfolio_id  mts_portfolio.id%type,
        p_login         varchar2,
        p_password      varchar2,
        p_user_id       mts_user.user_id%type,
        p_import_log_id out mts_import_trade_log.id%type
    );

    

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
                P_PROCESS_NAME => 'sync_transaction',
                P_MSG_STR => SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250)
            );
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250), true);     
    end tastytrade_sync_trade;

    --------------------------------------------------------------------------------------
    --    PROCEDURE : sync_trade
    --------------------------------------------------------------------------------------
    procedure sync_trade(
        p_portfolio_id  mts_portfolio.id%type,
        p_login         varchar2,
        p_password      varchar2,
        p_user_id       mts_user.user_id%type,
        p_import_log_id out mts_import_trade_log.id%type
    )
    AS
        pl_log_id       mts_import_trade_log.id%type := null;
        pl_broker_id    mts_broker.id%type;
        pl_broker_name  mts_broker.broker_name%type;
    BEGIN

        BEGIN
            SELECT ID, LOWER(BROKER_NAME) INTO pl_broker_id, pl_broker_name
            FROM   MTS_BROKER
            WHERE   ID IN ( SELECT BROKER_ID FROM MTS_PORTFOLIO WHERE ID = p_portfolio_id) 
            AND     API_AVAILABLE = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                raise_application_error(-20000, '[sync_trade] - Sorry, this broker does not support trade sync.', true);    
        END;

        IF pl_broker_name = 'tastytrade' THEN
            tastytrade_sync_trade (    
                    p_login  => p_login,
                    p_password  => p_password,
                    p_user_id   => p_user_id,
                    p_portfolio_id  => p_portfolio_id,
                    p_broker_id   => pl_broker_id,
                    p_import_log_id  => pl_log_id);

            
            IF ( pl_log_id is not null ) THEN
                PKG_MTS_WS_TRADE.FINALIZE_TRADE(p_user_id => p_user_id);
                p_import_log_id := pl_log_id;
            END IF;

        ELSE
            raise_application_error(-20000, '[sync_trade] - Sorry, this broker does not support trade sync.', true);     
        END IF;

    EXCEPTION
        when others then   
            PKG_MTS_APP_UTIL.LOG_MESSAGE(
                P_PACKAGE_NAME => 'pkg_mts_load_trade',
                P_PROCESS_NAME => 'sync_trade',
                P_MSG_STR => SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250)
            );
            raise_application_error(-20000, SQLCODE || ' - ' || SUBSTR(SQLERRM,1,250), true); 
         
    END sync_trade;

end pkg_mts_load_data;
/