function valid_action = check_valid_action(action,previous_action)
	
	if action == 1
		if previous_action == 2
			valid_action = 0;
		else
			valid_action =1;
		end			
	elseif action == 2
		if previous_action == 1 
			valid_action = 0;
		else
			valid_action =1;
		end			
	elseif action == 3
		if previous_action == 4
			valid_action = 0;
		else
			valid_action =1;
		end			
	elseif action == 4
		if previous_action == 3
			valid_action = 0;
		else
			valid_action =1;
		end			
	end

end
