% This is the main function for the snake game
clc
clear

grid_size = 8;
snake_length = 3;
sleep = 0.1;

world = zeros(grid_size,grid_size);
snake_location = [(grid_size-3)+[1:snake_length]',ones(snake_length,1),ones(snake_length,1)];
for j=1:size(snake_location,1)
    world(snake_location(j,1),snake_location(j,2)) = 1;
end
[fruit_r, fruit_c] = spawn_fruit(world);
visualize_world(world,fruit_r, fruit_c, sleep, 0)
while 1
    fruit_eaten = 0;
    previous_snake_element_location = snake_location(end,:);
    action = input('Enter a action from 1-4: ');%randsample([1,2,3,4]);
    %action = randsample([1,2,3,4],1);
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
    visualize_world(world,fruit_r,fruit_c,0.1,inf);
end
