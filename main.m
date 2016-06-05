% This is the main function for the snake game
clc
clear

%% Inputs for the game
grid_size = 5;
initial_snake_length = 5;
sleep = 0.00;
reward_for_fruit = 100;
reward_for_moving = -3;
reward_for_hitting = -100;
learning_rate = 0.1;
discount_factor = 0.9;
explore_exploit_threshold = 0.3;

%% code starts here
world = zeros(grid_size,grid_size);
snake_location = [(grid_size-initial_snake_length)+[1:initial_snake_length]',ones(initial_snake_length,1),ones(initial_snake_length,1)];
for j=1:size(snake_location,1)
    world(snake_location(j,1),snake_location(j,2)) = 1;
end
[fruit_r, fruit_c] = spawn_fruit(world);
%visualize_world(world,snake_location,fruit_r, fruit_c, sleep, 0);
previous_action = 0;
Q_matrix_fruit = zeros(grid_size * grid_size, 7);
Global_Q_matrix = zeros(grid_size * grid_size, 4);

[Q_matrix_fruit(:,1), Q_matrix_fruit(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) - ceil(grid_size/2);
Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) - ceil(grid_size/2);
Q_matrix_fruit(:,3) = 1:(grid_size*grid_size);
[Q_matrix_fruit] = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);
action=100;
previous_action_taken = -100;

Q_matrix_snake = zeros(grid_size * grid_size, 7);
[Q_matrix_snake(:,1), Q_matrix_snake(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_snake(:,1) = Q_matrix_snake(:,1) - ceil(grid_size/2);
Q_matrix_snake(:,2) = Q_matrix_snake(:,2) - ceil(grid_size/2);
Q_matrix_snake(:,3) = 1:(grid_size*grid_size);
for s=1:(grid_size * grid_size)
    Q_struct{s} = Q_matrix_snake;
end
iterator = 1;
while 1
    fruit_eaten = 0;
    %action = input('Enter a action from 1-4: ');%randsample([1,2,3,4]);
    snake_length = size(snake_location,1);
    valid_action  = 0;

    while ~valid_action
        if (rand > explore_exploit_threshold || rem(iterator, 1000) == 0)
            previous_action = action;
            ind_1 = sub2ind(size(world),snake_location(1,1),snake_location(1,2));
            [~,action] = max(Global_Q_matrix(ind_1,:));
            if action == previous_action
                vec_action = [1,2,3,4];
                vec_action = vec_action(find(vec_action ~= action));
                [~,action] = max(Global_Q_matrix(ind_1,vec_action));
            end
            if rem(iterator,1000) ==0
                fprintf('Action taken: %d \n',action);
            end
        else
            action = randsample([1,2,3,4],1);
        end
	valid_action = check_valid_action(action,previous_action_taken);
    end

    %if action == 1
    %    disp('UP')
    %elseif action ==2
    %    disp('Down')
    %elseif action ==3
    %    disp('Left')
    %elseif action == 4
    %    disp('Right')
    %end        
    previous_action_taken = action;

    snake_location(1,3) = action;
    previous_snake_mouth_location = snake_location(1,1:2);
    previous_snake_element_location = snake_location(end,:);
    [world,snake_location] = update_world(world,snake_location,[fruit_r,fruit_c]);
    ind_previous = sub2ind(size(world),previous_snake_mouth_location(1),previous_snake_mouth_location(2));
    ind_current = sub2ind(size(world),snake_location(1,1),snake_location(1,2));
    ind_in_fruit_previous = find(Q_matrix_fruit(:,3) == ind_previous);
    ind_in_fruit_current = find(Q_matrix_fruit(:,3) == ind_current);
    [ind_in_fruit_current, ind_in_fruit_previous, action];
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
    if sum(sum(world==2)) == 1
        iterator = iterator +1;
        fprintf('No of iteration %d: \n',iterator);
        world = zeros(grid_size,grid_size);
        [idx,~] = find(snake_location(1,1) == snake_location(2:end,1) & snake_location(1,2) == snake_location(2:end,2));
        if ~isempty(idx)
            snake_r = snake_location(idx+1,1);
            snake_c = snake_location(idx+1,2);
            Q_struct{idx} = update_q_snake(Q_struct{idx},grid_size,snake_r,snake_c);
            ind_in_snake_previous = find(Q_struct{idx}(:,3) == ind_previous);
            ind_in_snake_current = find(Q_struct{idx}(:,3) == ind_current);
            Q_struct{idx}(ind_in_snake_previous,3+action) = Q_struct{idx}(ind_in_snake_previous,3+action) + learning_rate * (reward_for_hitting - Q_struct{idx}(ind_in_snake_previous,3+action));
           % Q_struct{idx}
            
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
       snake_r = snake_location(m,1);
       snake_c = snake_location(m,2);
       Q_struct{m} = update_q_snake(Q_struct{m},grid_size,snake_r,snake_c);
       ind_in_snake_previous = find(Q_struct{m}(:,3) == ind_previous);
       ind_in_snake_current = find(Q_struct{m}(:,3) == ind_current);
       Q_struct{m}(ind_in_snake_previous,3+action) = Q_struct{m}(ind_in_snake_previous,3+action) + learning_rate * (discount_factor * min(Q_struct{m}(ind_in_snake_current,4:end)) - Q_struct{m}(ind_in_snake_previous,3+action));
       [m, Q_struct{m}(ind_in_snake_previous,3), Q_struct{m}(ind_in_snake_current,3)];
       Q_struct{m};
       Global_Q_matrix(Q_struct{m}(:,3)',:) = Global_Q_matrix(Q_struct{m}(:,3)',:) + Q_struct{m}(:,4:end);
    end
    %visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
    [[1:(grid_size*grid_size)]',Global_Q_matrix];
    if rem(iterator,1000) ==0
        visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
    end
end
