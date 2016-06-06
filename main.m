% This is the main function for the snake game
clc
clear

%% Inputs for the game
grid_size = 5;
initial_snake_length = 5;
sleep = 0.00;
reward_for_fruit = 500;
reward_for_moving =-10;
reward_for_hitting = -1000;
learning_rate_self = 0.9;
discount_factor_self = 0.1;
learning_rate = 0.2;
discount_factor = 0.8;
explore_exploit_threshold =0.2;

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
collision_matrix = zeros(grid_size * grid_size, 8);
[collision_matrix(:,1), collision_matrix(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
collision_matrix(:,1) = collision_matrix(:,1) - ceil(grid_size/2);
collision_matrix(:,2) = collision_matrix(:,2) - ceil(grid_size/2);
collision_matrix(:,3) = 1:(grid_size*grid_size);
collision_matrix(:,4) = get_manhattan_distance(collision_matrix);

[Q_matrix_fruit(:,1), Q_matrix_fruit(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) - ceil(grid_size/2);
Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) - ceil(grid_size/2);
Q_matrix_fruit(:,3) = 1:(grid_size*grid_size);
[Q_matrix_fruit] = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);
action=100;
previous_action_taken = 1;

iterator = 1;
while 1
    fruit_eaten = 0;
    %action = input('Enter a action from 1-4: ');%randsample([1,2,3,4]);
    snake_length = size(snake_location,1);

    valid_action  = 0;
    testing_phase = rem(iterator,100) ==0;
    vec_action = [1,2,3,4];
    invalid_action = get_invalid_action(snake_location,grid_size);
    vec_action = vec_action(find(vec_action ~= invalid_action));

    if (rand > explore_exploit_threshold || testing_phase)
        ind_1 = sub2ind(size(world),snake_location(1,1),snake_location(1,2));
        [~,action_id] = max(Global_Q_matrix(ind_1,vec_action));
        action = vec_action(action_id);
        if testing_phase
            fprintf('Action taken: %d , invalid: %d \n',action,invalid_action);
        end
    else
        action = randsample(vec_action,1);
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
        %if ~testing_phase
            Q_matrix_fruit(ind_in_fruit_previous,3+action) = Q_matrix_fruit(ind_in_fruit_previous,3+action) + learning_rate * (reward_for_fruit - Q_matrix_fruit(ind_in_fruit_previous,3+action));
        %end
        world = zeros(grid_size,grid_size);
        if sum(sum(world)) < (grid_size * grid_size)-1
            snake_location = append_snake(snake_location,previous_snake_element_location);
        elseif sum(sum(world)) == (grid_size * grid_size)
            disp(' You Won!!!! \n Exiting .... ')
            exit
        end
        for j=1:size(snake_location,1)
            world(snake_location(j,1),snake_location(j,2)) = 1;
        end
        [fruit_r,fruit_c] = spawn_fruit(world);
        world(fruit_r,fruit_c) = 0.5;
        Q_matrix_fruit = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);
    end
    if ~fruit_eaten% && ~testing_phase
        Q_matrix_fruit(ind_in_fruit_previous,3+action) = Q_matrix_fruit(ind_in_fruit_previous,3+action) + learning_rate * (reward_for_moving + discount_factor * max(Q_matrix_fruit(ind_in_fruit_current,4:end)) - Q_matrix_fruit(ind_in_fruit_previous,3+action));
    end
    Global_Q_matrix(Q_matrix_fruit(:,3)',:) = Q_matrix_fruit(:,4:end);
    %Global_Q_matrix = zeros(grid_size * grid_size, 4);
    %visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
    if sum(sum(world==2)) == 1
        fprintf('No of iteration %d: \n',iterator);
        size(snake_location,1)
        if testing_phase
            pause;
        end
        iterator = iterator +1;
        world = zeros(grid_size,grid_size);
        [idx,~] = find(snake_location(1,1) == snake_location(2:end,1) & snake_location(1,2) == snake_location(2:end,2));
        if ~isempty(idx)
            snake_r = snake_location(idx+1,1);
            snake_c = snake_location(idx+1,2);
            collision_matrix = update_q_snake(collision_matrix,grid_size,snake_r,snake_c);
            for k=1:idx-1
                ind_current = sub2ind(size(world),snake_location(k,1),snake_location(k,2));
                ind_previous = sub2ind(size(world),snake_location(k+1,1),snake_location(k+1,2));
                ind_in_snake_previous = find(collision_matrix(:,3) == ind_previous);
                ind_in_snake_current = find(collision_matrix(:,3) == ind_current);
                temp_action = snake_location(k+1,3);
                current_action = snake_location(k,3);
                %if ~testing_phase
                    if k==1
                        collision_matrix(ind_in_snake_previous,4+temp_action) = collision_matrix(ind_in_snake_previous,4+temp_action) + learning_rate_self * (reward_for_hitting + discount_factor_self * (collision_matrix(ind_in_snake_current,4+current_action)) - collision_matrix(ind_in_snake_previous,4+temp_action));
                    else
                        collision_matrix(ind_in_snake_previous,4+temp_action) = collision_matrix(ind_in_snake_previous,4+temp_action) + learning_rate_self * (discount_factor_self * (collision_matrix(ind_in_snake_current,4+current_action)) - collision_matrix(ind_in_snake_previous,4+temp_action));
                    end
                %end
            end
            collision_matrix;
            
        end
        world = zeros(grid_size,grid_size);
        snake_location = [(grid_size-initial_snake_length)+[1:initial_snake_length]',ones(initial_snake_length,1),ones(initial_snake_length,1)];
        previous_action_taken = 1;

        for j=1:size(snake_location,1)
            world(snake_location(j,1),snake_location(j,2)) = 1;
        end
        [fruit_r, fruit_c] = spawn_fruit(world);
        world(fruit_r,fruit_c) = 0.5;
        Q_matrix_fruit = update_q_fruit(Q_matrix_fruit, grid_size, fruit_r, fruit_c);
    end

    %visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
    dist = get_manhattan_distance([fruit_r,fruit_r; snake_location(1,1),snake_location(1,2)]);
    if dist == 1
        extended_length = size(snake_location,1)+1;
    else
        extended_length = size(snake_location,1);
    end
    for m=initial_snake_length:extended_length
        for d = 1:m-1
            step = m-d;
            snake_r = snake_location(d,1);
            snake_c = snake_location(d,2);
            collision_matrix = update_q_snake(collision_matrix,grid_size,snake_r,snake_c);
            idx_merge = find(collision_matrix(:,4) == step);
            Global_Q_matrix(collision_matrix(idx_merge',3)',:) = Global_Q_matrix(collision_matrix(idx_merge',3)',:) + collision_matrix(idx_merge',5:end);
            %[[1:(grid_size * grid_size)]', Global_Q_matrix]
            %pause
        end
    end
    %visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
    %pause

    if testing_phase
        visualize_world(world,snake_location,fruit_r,fruit_c,sleep,inf);
        %[[1:(grid_size * grid_size)]', Global_Q_matrix]
    end
    
end
