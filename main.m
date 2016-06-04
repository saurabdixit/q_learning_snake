% This is the main function for the snake game
clc
clear

%% Inputs for the game
grid_size = 5;
initial_snake_length = 3;
sleep = 0.05;
reward_for_fruit = 100;
reward_for_moving = -3;
reward_for_hitting = -200;
learning_rate = 0.1;
discount_factor = 0.9;
explore_exploit_threshold = 0.2

%% code starts here
world = zeros(grid_size,grid_size);
snake_location = [(grid_size-initial_snake_length)+[1:initial_snake_length]',ones(initial_snake_length,1),ones(initial_snake_length,1)];
for j=1:size(snake_location,1)
    world(snake_location(j,1),snake_location(j,2)) = 1;
end
[fruit_r, fruit_c] = spawn_fruit(world);
visualize_world(world,snake_location,fruit_r, fruit_c, sleep, 0);
previous_action = 0;
Q_matrix_fruit = zeros(grid_size * grid_size, 7);
Global_Q_matrix = zeros(grid_size * grid_size, 4);

[Q_matrix_fruit(:,1), Q_matrix_fruit(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) - ceil(grid_size/2);
Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) - ceil(grid_size/2);
Q_matrix_fruit(:,3) = 1:(grid_size*grid_size);
[Q_matrix_fruit] = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);

Q_matrix_snake = zeros(grid_size * grid_size, 7);
[Q_matrix_snake(:,1), Q_matrix_snake(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_snake(:,1) = Q_matrix_snake(:,1) - ceil(grid_size/2);
Q_matrix_snake(:,2) = Q_matrix_snake(:,2) - ceil(grid_size/2);
Q_matrix_snake(:,3) = 1:(grid_size*grid_size);

while 1
    fruit_eaten = 0;
    %action = input('Enter a action from 1-4: ');%randsample([1,2,3,4]);
    snake_length = size(snake_location,1);
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
    previous_snake_element_location = snake_location(end,:);
    [world,snake_location] = update_world(world,snake_location,[fruit_r,fruit_c]);
    % world will have value 1.5 if the fruit is eaten
    % sum(sum(world == 1.5))
    ind_previous = sub2ind(size(world),previous_snake_mouth_location(1),previous_snake_mouth_location(2));
    ind_current = sub2ind(size(world),snake_location(1,1),snake_location(1,2));
    ind_in_fruit_previous = find(Q_matrix_fruit(:,3) == ind_previous);
    ind_in_fruit_current = find(Q_matrix_fruit(:,3) == ind_current);
    [ind_in_fruit_current, ind_in_fruit_previous, action];
    %Q_matrix_fruit(ind_in_fruit_previous,3+action)
    if sum(sum(world==1.5)) == 1
        fruit_eaten = 1;
        Q_matrix_fruit(ind_in_fruit_previous,3+action) = Q_matrix_fruit(ind_in_fruit_previous,3+action) + learning_rate * (reward_for_fruit - Q_matrix_fruit(ind_in_fruit_previous,3+action));
        world = zeros(grid_size,grid_size);
        snake_location = append_snake(snake_location,previous_snake_element_location);
        for j=1:size(snake_location,1)
            world(snake_location(j,1),snake_location(j,2)) = 1;
        end
        [fruit_r,fruit_c] = spawn_fruit(world);
        world(fruit_r,fruit_c) = 0.5;
        Q_matrix_fruit = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);
    end
    if ~fruit_eaten
        Q_matrix_fruit(ind_in_fruit_previous,3+action) = Q_matrix_fruit(ind_in_fruit_previous,3+action) + learning_rate * (reward_for_moving + discount_factor * max(Q_matrix_fruit(ind_in_fruit_current,4:end)) - Q_matrix_fruit(ind_in_fruit_previous,3+action));
    end
    Global_Q_matrix(Q_matrix_fruit(:,3)',:) = Q_matrix_fruit(:,4:end);
    ind_in_snake_previous = find(Q_matrix_snake(:,3) == ind_previous);
    ind_in_snake_current = find(Q_matrix_snake(:,3) == ind_current);
    if sum(sum(world==2)) == 1
        world = zeros(grid_size,grid_size);
        for n=1:size(snake_location,1)
           [idx,~] = find(snake_location(1,1) == snake_location(2:end,1) & snake_location(1,2) == snake_location(2:end,2))
           if ~isempty(idx)
               snake_r = snake_location(idx+1,1);
               snake_c = snake_location(idx+1,2);
               Q_matrix_snake = update_q_snake(Q_matrix_snake,grid_size,snake_r,snake_c);
               Q_matrix_snake(ind_in_snake_previous,3+action) = Q_matrix_snake(ind_in_snake_previous,3+action) + learning_rate * (reward_for_hitting - Q_matrix_snake(ind_in_snake_previous,3+action));
               Global_Q_matrix(Q_matrix_snake(:,3)',:) = Global_Q_matrix(Q_matrix_snake(:,3)',:) + Q_matrix_snake(:,4:end);
           end
        end
        world = zeros(grid_size,grid_size);
        snake_location = [(grid_size-initial_snake_length)+[1:initial_snake_length]',ones(initial_snake_length,1),ones(initial_snake_length,1)];

        for j=1:size(snake_location,1)
            world(snake_location(j,1),snake_location(j,2)) = 1;
        end
        [fruit_r, fruit_c] = spawn_fruit(world);
        world(fruit_r,fruit_c) = 0.5;
        Q_matrix_fruit = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);
    end
    for m=1:size(snake_location,1)
        if m>4
            snake_r = snake_location(m,1);
            snake_c = snake_location(m,2);
            Q_matrix_snake = update_q_snake(Q_matrix_snake,grid_size,snake_r,snake_c);
            ind_in_snake_previous = find(Q_matrix_snake(:,3) == ind_previous);
            ind_in_snake_current = find(Q_matrix_snake(:,3) == ind_current);
            Q_matrix_snake(ind_in_snake_previous,3+action) = Q_matrix_snake(ind_in_snake_previous,3+action) + learning_rate * (discount_factor * max(Q_matrix_snake(ind_in_snake_current,4:end)) - Q_matrix_snake(ind_in_snake_previous,3+action));
            Global_Q_matrix(Q_matrix_snake(:,3)',:) = Global_Q_matrix(Q_matrix_snake(:,3)',:) + Q_matrix_snake(:,4:end);
        end
    end
    visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
    ind_current
    [[1:(grid_size*grid_size)]',Global_Q_matrix]
end
