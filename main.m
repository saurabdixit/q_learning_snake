% This is the main function for the snake game
clc
clear

%% Inputs for the game
grid_size = 5;
snake_length = 3;
sleep = 0.05;
reward_for_fruit = 100;
learning_rate = 0.1;
discount_factor = 0.9;
reward_for_moving = -10;
explore_exploit_threshold = 1

%% code starts here
world = zeros(grid_size,grid_size);
snake_location = [(grid_size-3)+[1:snake_length]',ones(snake_length,1),ones(snake_length,1)];
for j=1:size(snake_location,1)
    world(snake_location(j,1),snake_location(j,2)) = 1;
end
[fruit_r, fruit_c] = spawn_fruit(world);
visualize_world(world,fruit_r, fruit_c, sleep, 0);
previous_action = 0;
Q_matrix_fruit = zeros(grid_size * grid_size, 7);
Global_Q_matrix = zeros(grid_size * grid_size, 4);

[Q_matrix_fruit(:,1), Q_matrix_fruit(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) - ceil(grid_size/2);
Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) - ceil(grid_size/2);
Q_matrix_fruit(:,3) = 1:(grid_size*grid_size);
[Global_Q_matrix,Q_matrix_fruit] = update_global_q_fruit(Q_matrix_fruit, Global_Q_matrix, grid_size, fruit_r, fruit_c);

Q_matrix_snake = zeros(grid_size * grid_size, 7);
[Q_matrix_snake(:,1), Q_matrix_snake(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_snake(:,1) = Q_matrix_snake(:,1) - ceil(grid_size/2);
Q_matrix_snake(:,2) = Q_matrix_snake(:,2) - ceil(grid_size/2);
Q_matrix_snake(:,3) = 1:(grid_size*grid_size);
for s=1:(grid_size*grid_size)
    Q_snake_structure{s} = Q_matrix_snake;
end


while 1
    fruit_eaten = 0;
    previous_snake_element_location = snake_location(end,:);
    %action = input('Enter a action from 1-4: ');%randsample([1,2,3,4]);
    valid_action  = 0;
    while ~valid_action
        if rand > explore_exploit_threshold
            ind_1 = sub2ind(size(world),snake_location(1,1),snake_location(1,2));
            [~,action] = max(Global_Q_matrix(ind_1,:));
        else
            action = randsample([1,2,3,4],1);
        end
	valid_action = check_valid_action(action,previous_action);
    end

    %fruit_state = sub2ind(size(world),fruit_r,fruit_c)
    %get
	
    previous_action = action;
    snake_location(1,3) = action;
    previous_snake_mouth_location = snake_location(1,1:2);
    [world,snake_location] = update_world(world,snake_location,[fruit_r,fruit_c]);
    % world will have value 1.5 if the fruit is eaten
    % sum(sum(world == 1.5))
    ind_previous = sub2ind(size(world),previous_snake_mouth_location(1),previous_snake_mouth_location(2));
    ind_current = sub2ind(size(world),snake_location(1,1),snake_location(1,2));
    ind_in_fruit_previous = find(Q_matrix_fruit(:,3) == ind_previous);
    ind_in_fruit_current = find(Q_matrix_fruit(:,3) == ind_current);
    [ind_in_fruit_current, ind_in_fruit_previous, action];
    %Q_matrix_fruit(ind_in_fruit_previous,3+action)
    visualize_world(world,fruit_r,fruit_c,sleep,inf);
    if sum(sum(world==1.5)) == 1
        fruit_eaten = 1;
        Q_matrix_fruit(ind_in_fruit_previous,3+action) = Q_matrix_fruit(ind_in_fruit_previous,3+action) + learning_rate * (reward_for_fruit - Q_matrix_fruit(ind_in_fruit_previous,3+action));

        snake_location = append_snake(snake_location,previous_snake_element_location);
        [fruit_r,fruit_c] = spawn_fruit(world);
        [Global_Q_matrix,Q_matrix_fruit] = update_global_q_fruit(Q_matrix_fruit, Global_Q_matrix, grid_size, fruit_r, fruit_c);
    end

    if ~fruit_eaten
        %disp('Executing not fruit eaten')
        Q_matrix_fruit(ind_in_fruit_previous,3+action) = Q_matrix_fruit(ind_in_fruit_previous,3+action) + learning_rate * (reward_for_moving + discount_factor * max(Q_matrix_fruit(ind_in_fruit_current,4:end)) - Q_matrix_fruit(ind_in_fruit_previous,3+action));
    end
    Global_Q_matrix(Q_matrix_fruit(:,3)',:) = Q_matrix_fruit(:,4:end);
    ind_current
    Global_Q_matrix
    pause
    if sum(sum(world==2)) == 1
        world = zeros(grid_size,grid_size);
        idx = find(snake_location(1,1) == snake_location(2:end,1) & snake_location(1,2) == snake_location(2:end,2));
        snake_location = [(grid_size-3)+[1:snake_length]',ones(snake_length,1),ones(snake_length,1)];
        for j=1:size(snake_location,1)
            world(snake_location(j,1),snake_location(j,2)) = 1;
        end
        [fruit_r, fruit_c] = spawn_fruit(world);
    end
end
