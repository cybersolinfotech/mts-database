/*****************************************************************************************************************
 PACAKAGE SPEC :
 *******************************************************************************************************************/
create or replace package pkg_mts_util as 
    function get_num_class(p_input number) return varchar2; 
    function get_dte(p_exp_date timestamp) return number;
    
    function get_profit_loss(   p_open_qty      number, 
                                p_open_price    number, 
                                p_close_qty     number, 
                                p_close_price number) return number;
    function get_profit_loss_percent(   p_open_qty      number, 
                                        p_open_price    number, 
                                        p_close_qty     number, 
                                        p_close_price number) return number;
    function get_unit_price(    p_qty      number, 
                                p_price    number) return number;

    function get_trade_code( 
                             p_symbol   mts_trade_tran.symbol%type,
                             p_exp_date   mts_trade_tran.exp_date%type,
                             p_order_type   mts_trade_tran.order_type%type,
                             p_strike   mts_trade_tran.strike%type

                            ) return varchar2;

    procedure print_clob_to_output(p_clob clob);

end pkg_mts_util; 
/

/*****************************************************************************************************************
 PACAKAGE BODY :
 *******************************************************************************************************************/
create or replace package body pkg_mts_util as 
 
    procedure print_clob_to_output(p_clob clob)
    is
        l_offset        int := 1;
        clob_size       int := 30000;
    begin
        dbms_output.put_line('LOB print stary Length = ' || dbms_lob.getlength(p_clob));
        loop
            exit when l_offset > dbms_lob.getlength(p_clob);
            dbms_output.put_line(dbms_lob.substr(p_clob,clob_size,l_offset));
            l_offset := l_offset + clob_size;

        end loop;
        dbms_output.put_line('LOB print End.' );
    end print_clob_to_output;


    function get_num_class(p_input number) return varchar2 
    as 
        pl_return   varchar2(100); 
    begin 
        case when p_input > 0 then  
                pl_return := 'u-success-text'; 
             when p_input < 0 then  
                pl_return :='u-danger-text'; 
             else 
                pl_return :='u-normal-text'; 
        end case; 
        return pl_return; 
    end get_num_class; 

    function get_dte(p_exp_date timestamp) return number
    as
        pl_return   number; 
    begin

        if (p_exp_date is not null ) then
            pl_return := round(CAST( p_exp_date AS DATE ) - CAST( current_timestamp AS date ),0);        
        else
            pl_return := null;
        end if;
        return pl_return;
    end get_dte;     
     


    function get_profit_loss(   p_open_qty      number, 
                                p_open_price    number, 
                                p_close_qty     number, 
                                p_close_price number) return number
    as
        pl_return   number;
    begin
        dbms_output.put_line('p_open_qty =' || p_open_qty);
        dbms_output.put_line('p_open_price =' || p_open_price);
        dbms_output.put_line('p_close_qty =' || p_close_qty);
        dbms_output.put_line('p_close_price =' || p_close_price);
        if ( abs(nvl(p_open_qty,0)) != abs(nvl(p_close_qty,0)) ) then
            pl_return := null;
        else
            pl_return := nvl(p_open_price,0) + nvl(p_close_price,0);
        end if;
        
        return pl_return;

    end get_profit_loss;

    function get_profit_loss_percent(   p_open_qty      number, 
                                        p_open_price    number, 
                                        p_close_qty     number, 
                                        p_close_price number) return number
    as
        pl_return       number;
        pl_profit_loss  number;
        pl_open_price   number;
    begin
        if ( abs(nvl(p_open_qty,0)) != abs(nvl(p_close_qty,0)) ) then
            pl_return := null;
        
        else
            pl_profit_loss  :=  nvl(p_open_price,0) + nvl(p_close_price,0);
            pl_return := pl_profit_loss/nvl(p_open_price,1) * 100;

        end if;
        
        return pl_return;

    end get_profit_loss_percent;

    function get_unit_price(    p_qty      number, 
                            p_price    number) return number
    as
        pl_return       number;
    begin  
        if ( nvl(p_qty,0) = 0 ) THEN
            pl_return := 0;  
        else   
            pl_return := round(p_price /p_qty,4);    
        end if;
        return pl_return;
    end get_unit_price;

    function get_trade_code( 
                             p_symbol   mts_trade_tran.symbol%type,
                             p_exp_date   mts_trade_tran.exp_date%type,
                             p_order_type   mts_trade_tran.order_type%type,
                             p_strike   mts_trade_tran.strike%type

                            ) return varchar2

    as
    begin
        return trim(p_symbol) || '-' || nvl(to_char(p_exp_date,'YYYYMMDD'),'99991231')|| '-'|| nvl(p_order_type,'E') || '-' || to_char(NVL(p_strike,'999999'));
    end ;
end pkg_mts_util; 
/