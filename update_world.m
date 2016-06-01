function [world,snake_location] = update_world(world,snake_location,fruit_location)
    grid_height = size(world,1);
    grid_width = size(world,2);
    length_of_snake = size(snake_location,1);
    world = zeros(size(world));
    for i=1:length_of_snake
        action = snake_location(i, 3);
        snake_element_r = snake_location(i,1);
        snake_element_c = snake_location(i,2);
        if action == 1
            if snake_element_r - 1 > 0
                snake_element_r = snake_element_r -1;
            else
                snake_element_r = grid_height;
            end

        elseif action == 2
            if snake_element_r + 1 <= grid_height
                snake_element_r = snake_element_r + 1;
            else
                snake_element_r = 1;
            end

        elseif action == 3
            if snake_element_c - 1 > 0
                snake_element_c = snake_element_c -1;
            else
                snake_element_c = grid_width;
            end

        else
            if snake_element_c + 1 <= grid_width
                snake_element_c = snake_element_c + 1;
            else
                snake_element_c = 1;
            end
            
        end

        snake_location(i,1) = snake_element_r;
        snake_location(i,2) = snake_element_c;


        world(snake_element_r, snake_element_c) = world(snake_element_r,snake_element_c) + 1;
    end
    world(fruit_location(1),fruit_location(2)) = world(fruit_location(1),fruit_location(2)) + 0.5;
    for j=1:length_of_snake
        if j~=length_of_snake
            snake_location(length_of_snake-j+1,3) = snake_location(length_of_snake-j,3);
        end
    end

end
