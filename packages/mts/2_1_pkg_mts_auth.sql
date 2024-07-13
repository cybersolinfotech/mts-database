create or replace package pkg_mts_auth 
as

    function login(  p_login_id      mts_user.login_id%type,
                     p_password      mts_user.password%type,
                     p_connection    mts_user.connection%type
    ) return boolean;

    procedure create_user(
            p_login_id          mts_user.login_id%type,
            p_connection        mts_user.connection%type,
            p_password          mts_user.password%type,
            p_first_name        mts_user.first_name%type default null,
            p_last_name         mts_user.last_name%type  default null,
            p_email             mts_user.email%type  default null,
            p_email_verified    mts_user.email_verified%type default 0,
            p_phone             mts_user.phone%type  default null,
            p_phone_verified    mts_user.phone_verified%type default 0,
            p_response          out clob
    );


end pkg_mts_auth;
/
create or replace package pkg_mts_auth 
as

    function login(  p_login_id      mts_user.login_id%type,
                     p_password      mts_user.password%type,
                     p_connection    mts_user.connection%type
    ) return boolean;

    procedure create_user(
            p_login_id          mts_user.login_id%type,
            p_connection        mts_user.connection%type,
            p_password          mts_user.password%type,
            p_first_name        mts_user.first_name%type default null,
            p_last_name         mts_user.last_name%type  default null,
            p_email             mts_user.email%type  default null,
            p_email_verified    mts_user.email_verified%type default 0,
            p_phone             mts_user.phone%type  default null,
            p_phone_verified    mts_user.phone_verified%type default 0,
            p_response          out clob
    );


end pkg_mts_auth;
/