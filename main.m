% This is the main function for the snake game
clc
clear

%% Inputs for the game
grid_size = 8;
snake_length = 3;
sleep = 0.0;


%% code starts here
world = zeros(grid_size,grid_size);
snake_location = [(grid_size-3)+[1:snake_length]',ones(snake_length,1),ones(snake_length,1)];
for j=1:size(snake_location,1)
    world(snake_location(j,1),snake_location(j,2)) = 1;
end
[fruit_r, fruit_c] = spawn_fruit(world);
visualize_world(world,fruit_r, fruit_c, sleep, 0);
previous_action = 0;
Q_matrix_snake = zeros(size(snake_location,1),4);
Q_matrix_fruit = zeros(grid_size * grid_size, 6);
Global_Q_matrix = zeros(grid_size * grid_size, 4);

[Q_matrix_fruit(:,1), Q_matrix_fruit(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) - grid_size/2;
Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) - grid_size/2;

while 1
    fruit_eaten = 0;
    previous_snake_element_location = snake_location(end,:);
    %action = input('Enter a action from 1-4: ');%randsample([1,2,3,4]);
    valid_action  = 0;
    while ~valid_action
    	action = randsample([1,2,3,4],1);
		valid_action = check_valid_action(action,previous_action);
	end

	%fruit_state = sub2ind(size(world),fruit_r,fruit_c)
	%get
	
	previous_action = action;
    snake_location(1,3) = action;
    [world,snake_location] = update_world(world,snake_location,[fruit_r,fruit_c]);
    % world will have value 1.5 if the fruit is eaten
    % sum(sum(world == 1.5))
    if sum(sum(world==1.5)) == 1
        fruit_eaten = 1;
        world(fruit_r,fruit_c) = 1;
        snake_location = append_snake(snake_location,previous_snake_element_location);
        [fruit_r,fruit_c] = spawn_fruit(world);
    end

    if sum(sum(world==2)) == 1
        world = zeros(grid_size,grid_size);
        snake_location = [(grid_size-3)+[1:snake_length]',ones(snake_length,1),ones(snake_length,1)];
        for j=1:size(snake_location,1)
            world(snake_location(j,1),snake_location(j,2)) = 1;
        end
        [fruit_r, fruit_c] = spawn_fruit(world);
    end
    visualize_world(world,fruit_r,fruit_c,sleep,inf);
end
