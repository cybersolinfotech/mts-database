create or replace trigger mts_user_biud 
before
insert or update or delete on mts_user
for each row
begin

	
	if inserting then
		pkg_mts_user.set_user_theme(p_app_id => 101,
								p_user_id => :new.user_id,
								p_theme => :new.theme);

	elsif updating then

        if :new.theme != :old.theme then
			pkg_mts_user.set_user_theme(p_app_id => 101,
								p_user_id => :new.user_id,
								p_theme => :new.theme);
		end if;

        
	else
		null;
	end if;
end;
/