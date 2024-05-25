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
        if ( abs(nvl(p_open_qty,0)) != abs(nvl(p_close_qty,0)) ) then
            pl_return := null;
        else
            if p_open_qty < 0 then
                pl_return := round(abs(nvl(p_open_price,0)) - abs(nvl(p_close_price,0))) ;
            elsif p_open_qty > 0 then
                pl_return := round(abs(nvl(p_close_price,0)) - abs(nvl(p_open_price,0)));
            else
                pl_return := 0;
            end if;

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
            if ( p_open_price = 0) then 
                pl_open_price := 1; 
            else  
                pl_open_price := p_open_price; 
            end if;

            if p_open_qty < 0 then -- short position                
                pl_profit_loss := round(abs(nvl(p_open_price,0)) - abs(nvl(p_close_price,0))) ;
                pl_return := round((pl_profit_loss / abs(nvl(pl_open_price,1))) * 100,2) ;                
            elsif p_open_qty > 0 then -- long position                
                    pl_profit_loss := round(abs(nvl(p_close_price,0)) - abs(nvl(p_open_price,0)));
                    dbms_output.put_line('PL:' || pl_profit_loss);

                    pl_return := round((pl_profit_loss / abs(nvl(pl_open_price,1))) * 100,2) ;                
            else
                pl_return := 0;
            end if;

        end if;
        
        return pl_return;

    end get_profit_loss_percent;
end pkg_mts_util; 
/