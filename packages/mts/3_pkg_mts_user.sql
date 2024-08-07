/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_user as

    /***************************************************************************
         API:  USER
     ***************************************************************************/

    function login(  p_username         mts_user.login_id%type,
                     p_password         mts_user.password%type
    ) 
    return boolean;

    function change_password(p_username         mts_user.login_id%type,
                             p_old_password     mts_user.password%type,
                             p_new_password     mts_user.password%type )
    return boolean;


    function is_user_exists(p_user_id       mts_user.user_id%type) return number;
    function is_user_active(p_user_id       mts_user.user_id%type) return number;
    function is_in_role(p_user_id           mts_user.user_id%type, 
                        p_role_id           mts_user.role_id%type
                       ) return number;
    function get_user_id(p_email mts_user.email%type) return mts_user.user_id%type;
    function get_user_role(p_user_id        mts_user.user_id%type ) return mts_user.role_id%type;
    function get_dflt_portfolio_id(p_user_id        mts_user.user_id%type ) return mts_user.dflt_portfolio_id%type;

    function get_user_theme(p_user_id               mts_user.user_id%type ) return varchar2;
    function get_mbr_type_id(p_user_id               mts_user.user_id%type ) return mts_user.mbr_type_id%type;
    function get_mbr_type(p_user_id               mts_user.user_id%type ) return    mts_mbr_type.mbr_type%type;

    procedure set_user_theme(   p_app_id        number,
                                p_user_id       mts_user.user_id%type,
                                p_theme         mts_user.theme%type default 'mts-dark');

    procedure register_user( p_user_id      in out mts_user.user_id%type,
                             p_login_id     mts_user.login_id%type,
                             p_connection   mts_user.connection%type default null,
                             p_password     mts_user.password%type default null,                             
                             p_theme        mts_user.theme%type default 'mts-dark',
                             p_role_id      mts_user.role_id%type default 'BASIC-USER')   ;

    procedure activate_user(p_user_id   mts_user.user_id%type);

    procedure deactivate_user(  p_user_id   mts_user.user_id%type);


    procedure update_user   (   p_user_id                  mts_user.user_id%type,
                                p_first_name                mts_user.first_name%type        default null,
                                p_last_name                 mts_user.last_name%type         default null,
                                p_email                     mts_user.email%type             default null,
                                p_email_verified            mts_user.email_verified%type    default null,
                                p_phone                     mts_user.phone%type             default null,
                                p_phone_verified            mts_user.phone_verified%type    default null,
                                p_profile_pic               mts_user.profile_picture%type   default null,
                                p_mbr_type_id               mts_user.mbr_type_id%type       default null,
                                p_theme                     mts_user.theme%type             default null,
                                p_dflt_portfolio_id         mts_user.dflt_portfolio_id%type default null,
                                p_plan_id                   mts_user.plan_id%type           default null,
                                p_plan_enroll_date          mts_user.plan_enroll_date%type  default null,
                                p_pay_customer_id           mts_user.pay_customer_id%type   default null,
                                p_active                    mts_user.active%type            default null
                            )  ;


    /***************************************************************************
        API:  PRO_TRADER
     ***************************************************************************/
    procedure register_pro_trader ( p_pro_trader_id          mts_pro_trader.pro_trader_id%type);
    procedure activate_pro_trader ( p_pro_trader_id          mts_pro_trader.pro_trader_id%type);

    procedure deactivate_pro_trader(  p_pro_trader_id       mts_pro_trader.pro_trader_id%type);

    procedure update_pro_trader(    p_pro_trader_id         mts_pro_trader.pro_trader_id%type,
                                    p_amt_to_start          mts_pro_trader.amt_to_start%type    default null,
                                    p_expected_return       mts_pro_trader.expected_return%type default null,                                                                        
                                    p_about_me              mts_pro_trader.about_me%type        default null,
                                    p_strategy              mts_pro_trader.strategy%type        default null,
                                    p_offer_alert           mts_pro_trader.offer_alert%type     default null,
                                    p_offer_plan            mts_pro_trader.offer_plan%type      default null,
                                    p_active                mts_pro_trader.active%type            default null
                            )  ; 

    procedure register_pro_trader_member (  p_pro_trader_id     mts_pro_trader_member.pro_trader_id%type,
                                            p_member_id         mts_pro_trader_member.member_id%type);


    procedure activate_pro_trader_member(   p_pro_trader_id     mts_pro_trader_member.pro_trader_id%type,
                                            p_member_id         mts_pro_trader_member.member_id%type);

    procedure deactivate_pro_trader_member( p_pro_trader_id     mts_pro_trader_member.pro_trader_id%type,
                                            p_member_id         mts_pro_trader_member.member_id%type);                            

    /***************************************************************************
        API:  ROLE
     ***************************************************************************/
    procedure merge_role (  p_role_id       mts_role.role_id%type,
                            p_role_name     mts_role.role_name%type         default null,
                            pl_hierarchy    mts_role.hierarchy%type         default null,
                            p_active        mts_role.active%type            default 1);



end pkg_mts_user;
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_user as


    /***************************************************************************
         API:  USER
     ***************************************************************************/

    
    function login(  p_username      mts_user.login_id%type,
                     p_password      mts_user.password%type
    ) 
    return boolean
    as
        pl_connection         mts_user.connection%type := 'mts';
        pl_user_rec           mts_user%rowtype;
        
    begin
        begin
            select  *
            into    pl_user_rec
            from    mts_user
            where   lower(login_id) = lower(p_username)
            and     lower(connection) = pl_connection
            and     password = pkg_mts_util.encrypt(p_password); 

            if ( pl_user_rec.account_locked = 1 ) then
                raise_application_error(-20001,'Account is locked.',true);
            end if;

            return true;
        exception
            when no_data_found then
                return false;
        end;
    
    end login;

    function change_password(p_username         mts_user.login_id%type,
                             p_old_password     mts_user.password%type,
                             p_new_password     mts_user.password%type )
    return boolean
    as
        pl_connection         mts_user.connection%type := 'mts';
        pl_user_rec           mts_user%rowtype;
    begin
        begin
            select  *
            into    pl_user_rec
            from    mts_user
            where   lower(login_id) = lower(p_username)
            and     lower(connection) = pl_connection; 

            if ( pl_user_rec.password != pkg_mts_util.encrypt(p_old_password) ) then
                raise_application_error(-20001,'Old password does not match with existing password.',true);
            end if;

            update  mts_user
            set     password = pkg_mts_util.encrypt(p_new_password)
            where   user_id = pl_user_rec.user_id;

            commit;

            return true;
        exception
            when no_data_found then
                raise_application_error(-20001,'User account not found.',true);
        end;

    end change_password;


    function get_user_id(p_email mts_user.email%type) return mts_user.user_id%type
    is
        pl_return   mts_user.user_id%type;
    begin
        begin
            select  user_id
            into    pl_return
            from    mts_user
            where   lower(email) = lower(p_email) or lower(login_id) = lower(p_email) ;           
        exception
            when no_data_found then
               pl_return := null; 
        end;   
        return pl_return;
    end get_user_id; 

    -- function => is_user_exists
    function is_user_exists(p_user_id       mts_user.user_id%type) return number
    is
        pl_return   number;
    begin
        begin
            select  1
            into    pl_return
            from    mts_user
            where   user_id = p_user_id;
           
        exception
            when no_data_found then
               pl_return := 0; 
        end;   
        return pl_return;
    end;

    -- function => is_user_active
    function is_user_active(p_user_id       mts_user.user_id%type) return number
    is
        pl_return   number;
    begin
        begin
            select  1
            into    pl_return
            from    mts_user
            where   user_id = p_user_id
            and     active = 1;

            
        exception
            when no_data_found then
               pl_return := 0; 
        end; 

        return pl_return;
    end;

    -- function => is_in_role
    function is_in_role (
                        p_user_id           mts_user.user_id%type, 
                        p_role_id           mts_user.role_id%type
                        ) 
    return number
    is
        pl_role_count           number;
        pl_role_hierarchy       number;
        pl_user_role_hierarchy  number;
        
    begin
        
        begin
            begin
                select  hierarchy
                into    pl_role_hierarchy
                from    mts_role
                where   role_id = p_role_id
                and     active = 1;
            exception
                when no_data_found then
                    pl_role_hierarchy := 9999999999;    
            end;

            begin
                select  r.hierarchy
                into    pl_user_role_hierarchy
                from    mts_user u 
                join    mts_role r on r.role_id = u.role_id 
                where   u.user_id = p_user_id
                and     u.active = 1;   
            exception
                when no_data_found then
                    pl_user_role_hierarchy := 999999999;    
            end;

            if pl_user_role_hierarchy <= pl_role_hierarchy then
                return 1;
            else
                return 0;
            end if;
        end;
        
    exception
        when others then
            return 0;
    end is_in_role;

    
    -- function => get_user_role
    function get_user_role(p_user_id        mts_user.user_id%type ) return mts_user.role_id%type
    is
        pl_return mts_user.role_id%type;
    begin
        begin
            select  role_id
            into    pl_return
            from    mts_user
            where   user_id = p_user_id;
        exception
            when no_data_found then
               pl_return := 'DEMO-USER'; 
        end;

        return pl_return;
    end get_user_role; 

    -- function => get_dflt_portfolio_id
    function get_dflt_portfolio_id(p_user_id        mts_user.user_id%type ) return mts_user.dflt_portfolio_id%type
    is
        pl_return mts_user.dflt_portfolio_id%type;
    begin
        begin
            select  dflt_portfolio_id
            into    pl_return
            from    mts_user
            where   user_id = p_user_id;
        exception
            when no_data_found then
               pl_return := null; 
        end;

        return pl_return;
    end get_dflt_portfolio_id; 
    
    -- function => get_user_theme
    function get_user_theme(p_user_id               mts_user.user_id%type ) return varchar2
    is
        pl_return varchar2(20);
    begin
        begin
            select  theme
            into    pl_return
            from    mts_user
            where   user_id = p_user_id;

        exception
            when no_data_found then
               pl_return := 'dark'; 
        end;

        return pl_return;
    end get_user_theme;

    function get_mbr_type_id(p_user_id               mts_user.user_id%type ) return mts_user.mbr_type_id%type
    as
        pl_return mts_user.mbr_type_id%type;
    begin 
        begin
            select  mbr_type_id
            into    pl_return
            from    mts_user
            where   user_id = p_user_id;

        exception
            when no_data_found then
               pl_return := null; 
        end; 
        return pl_return;
    end;

    function get_mbr_type(p_user_id               mts_user.user_id%type ) return    mts_mbr_type.mbr_type%type
    as
        pl_return mts_mbr_type.mbr_type%type;
    begin 
        begin
            select  mbr_type
            into    pl_return
            from    mts_user u
            join    mts_mbr_type m on m.id = u.mbr_type_id
            where   user_id = p_user_id;

        exception
            when no_data_found then
               pl_return := 1; 
        end; 
        return pl_return;
    end;

    -- procedure => set user theme
    procedure set_user_theme(   p_app_id        number,
                                p_user_id       mts_user.user_id%type,
                                p_theme         mts_user.theme%type default 'mts-dark')
    as
            pl_theme_style_id   number;
            pl_theme_number	  number;

    begin
            SELECT s.theme_style_id, t.theme_number
            INTO   pl_theme_style_id,pl_theme_number 
            FROM   apex_application_theme_styles s, apex_application_themes t
            WHERE  s.application_id = t.application_id 
            AND    s.theme_number = t.theme_number 
            AND    s.application_id = p_app_id
            AND    lower(s.name) = lower(p_theme);  


            apex_theme.set_user_style(p_application_id => p_app_id, 
                                        p_user =>  p_user_id, 
                                        p_theme_number => pl_theme_number, 
                                        p_id => pl_theme_style_id   );

    end set_user_theme;

    
    -- procedure => register_user
    procedure register_user( p_user_id      in out mts_user.user_id%type,
                             p_login_id     mts_user.login_id%type,
                             p_connection   mts_user.connection%type default null,
                             p_password     mts_user.password%type default null,                             
                             p_theme        mts_user.theme%type default 'mts-dark',
                             p_role_id      mts_user.role_id%type default 'BASIC-USER')  
    as
        pl_rec        mts_user%rowtype;
    begin 
        
        begin        
            select  *
            into    pl_rec
            from    mts_user 
            where   lower(login_id) = lower(p_login_id)
            and     lower(connection) = lower(p_connection);

            raise_application_error(-20001,'EMAIL ALREADY REGISTERED.',true);
        exception
            when no_data_found  then   
                begin 
                    insert into mts_user ( login_id, connection, password, email,theme,role_id)
                    values (p_login_id,p_connection, pkg_mts_util.encrypt(p_password), p_login_id, p_theme,p_role_id) returning user_id into p_user_id;
                end; 
            when others then
                raise;
        end;  
       

    end register_user;

    -- procedure => activate_user
    procedure activate_user(p_user_id   mts_user.user_id%type)
    as
    begin 

        begin
            update  mts_user
            set     active = 1
            where   user_id = p_user_id ;
        end;

    end activate_user;

    -- procedure => deactivate_user                         
    procedure deactivate_user(  p_user_id   mts_user.user_id%type)
    as
    begin 

        begin
            update  mts_user
            set     active = 0
            where   user_id = p_user_id ;
        end;

    end deactivate_user;

    

    -- procedure => update_user 
    procedure update_user   (   p_user_id                  mts_user.user_id%type,
                                p_first_name                mts_user.first_name%type        default null,
                                p_last_name                 mts_user.last_name%type         default null,
                                p_email                     mts_user.email%type             default null,
                                p_email_verified            mts_user.email_verified%type    default null,
                                p_phone                     mts_user.phone%type             default null,
                                p_phone_verified            mts_user.phone_verified%type    default null,
                                p_profile_pic               mts_user.profile_picture%type   default null,
                                p_mbr_type_id               mts_user.mbr_type_id%type       default null,
                                p_theme                     mts_user.theme%type             default null,
                                p_dflt_portfolio_id         mts_user.dflt_portfolio_id%type default null,
                                p_plan_id                   mts_user.plan_id%type           default null,
                                p_plan_enroll_date          mts_user.plan_enroll_date%type  default null,
                                p_pay_customer_id           mts_user.pay_customer_id%type   default null,
                                p_active                    mts_user.active%type            default null
                            ) 
    as
    begin 
        update  mts_user
        set     first_name          = nvl(p_first_name,first_name),
                last_name           = nvl(p_last_name,last_name),
                email               = nvl(p_email,email),
                email_verified      = nvl(p_email_verified,email_verified), 
                phone               = nvl(p_phone,phone),
                phone_verified      = nvl(p_phone_verified,phone_verified),
                profile_picture     = nvl(p_profile_pic,profile_picture),
                mbr_type_id         = nvl(p_mbr_type_id,mbr_type_id),
                theme               = nvl(p_theme,theme),
                dflt_portfolio_id   = nvl(p_dflt_portfolio_id,dflt_portfolio_id), 
                plan_id             = nvl(p_plan_id,plan_id),
                plan_enroll_date    = nvl(p_plan_enroll_date,plan_enroll_date),
                pay_customer_id     = nvl(p_pay_customer_id,pay_customer_id),
                active              = nvl(p_active,active)
        where   user_id = p_user_id ;
    end update_user;                         
                            
    /***************************************************************************
        API:  PRO_TRADER
     ***************************************************************************/
    -- procedure => register_pro_trader
    procedure register_pro_trader (  p_pro_trader_id     mts_pro_trader.pro_trader_id%type)
    as
        pl_rec_count number;
    begin         
        select  count(*)
        into    pl_rec_count
        from    mts_pro_trader 
        where   pro_trader_id = p_pro_trader_id;

        if ( pl_rec_count = 0 ) then 
            begin 
                insert into mts_pro_trader ( pro_trader_id)
                values (p_pro_trader_id) ;
            end;
        end if;

    end register_pro_trader;
    

    -- procedure => activate_pro_trader
    procedure activate_pro_trader(p_pro_trader_id   mts_pro_trader.pro_trader_id%type)
    as
    begin 

        begin
            update  mts_pro_trader
            set     active = 1
            where   pro_trader_id = p_pro_trader_id ;
        end;

    end activate_pro_trader;

    -- procedure => deactivate_deactivate_protrader                      
    procedure deactivate_pro_trader(  p_pro_trader_id   mts_pro_trader.pro_trader_id%type)
    as
    begin 

        begin
            update  mts_pro_trader
            set     active = 0
            where   pro_trader_id = p_pro_trader_id ;
        end;

    end deactivate_pro_trader;

    -- procedure => update_pro_trader   
    procedure update_pro_trader(    p_pro_trader_id         mts_pro_trader.pro_trader_id%type,
                                    p_amt_to_start          mts_pro_trader.amt_to_start%type    default null,
                                    p_expected_return       mts_pro_trader.expected_return%type default null,                                                                        
                                    p_about_me              mts_pro_trader.about_me%type        default null,
                                    p_strategy              mts_pro_trader.strategy%type        default null,
                                    p_offer_alert           mts_pro_trader.offer_alert%type     default null,
                                    p_offer_plan            mts_pro_trader.offer_plan%type      default null,
                                    p_active                mts_pro_trader.active%type            default null
                            )  
    as
    begin 
        update  mts_pro_trader
        set     amt_to_start        = nvl(p_amt_to_start,amt_to_start),
                expected_return     = nvl(p_expected_return,expected_return),
                about_me            = nvl(p_about_me,about_me),
                strategy            = nvl(p_strategy,strategy),
                offer_alert         = nvl(p_offer_alert,offer_alert),
                offer_plan          = nvl(p_offer_plan,offer_plan),
                active              = nvl(p_active,active)
        where   pro_trader_id = p_pro_trader_id ;

    end update_pro_trader; 

    -- procedure => register_pro_trader_member   
    procedure register_pro_trader_member (  p_pro_trader_id     mts_pro_trader_member.pro_trader_id%type,
                                            p_member_id         mts_pro_trader_member.member_id%type)
    as
        pl_rec_count number;
    begin         
        select  count(*)
        into    pl_rec_count
        from    mts_pro_trader_member 
        where   pro_trader_id = p_pro_trader_id
        and     member_id = p_member_id;

        if ( pl_rec_count = 0 ) then 
            begin 
                insert into mts_pro_trader_member ( pro_trader_id,member_id)
                values (p_pro_trader_id,p_member_id) ;
            end;
        end if;

    end register_pro_trader_member;

    -- procedure => activate_pro_trader_member   
    procedure activate_pro_trader_member(   p_pro_trader_id     mts_pro_trader_member.pro_trader_id%type,
                                            p_member_id         mts_pro_trader_member.member_id%type)
    as
    begin
        begin
            update  mts_pro_trader_member
            set     active = 1
            where   pro_trader_id = p_pro_trader_id
            and     member_id = p_member_id;
        end;
    end activate_pro_trader_member;

    -- procedure => deactivate_pro_trader_member                          
    procedure deactivate_pro_trader_member( p_pro_trader_id     mts_pro_trader_member.pro_trader_id%type,
                                            p_member_id         mts_pro_trader_member.member_id%type)
    as
    begin 
        begin
            update  mts_pro_trader_member
            set     active = 0
            where   pro_trader_id = p_pro_trader_id
            and     member_id = p_member_id;
        end;
    end deactivate_pro_trader_member;                          
    

    /***************************************************************************
        API:  ROLE
     ***************************************************************************/

     -- procedure => merge_role     
    procedure merge_role (  p_role_id       mts_role.role_id%type,
                            p_role_name     mts_role.role_name%type         default null,
                            pl_hierarchy    mts_role.hierarchy%type         default null,
                            p_active        mts_role.active%type            default 1)
    as
        pl_rec_count    number;
    begin

        begin
            select  count(*) 
            into    pl_rec_count
            from    mts_role
            where   role_id = p_role_id;

            if (pl_rec_count > 0) then
                update mts_role
                set     role_name = nvl(p_role_name,role_name),
                        hierarchy = pl_hierarchy,
                        active = nvl(p_active,active)
                where   role_id = p_role_id;
            else
                insert into mts_role (role_id,role_name,hierarchy,active)
                values (p_role_id,p_role_name,pl_hierarchy,nvl(p_active,1));
            end if;

        end;
        
    end merge_role;

    
    
end pkg_mts_user;
/