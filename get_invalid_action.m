function inv_action = get_invalid_action(snake_location,grid_size)
    r_1 = snake_location(1,1);
    c_1 = snake_location(1,2);
    r_2 = snake_location(2,1);
    c_2 = snake_location(2,2);
    diff_r = r_1 - r_2;
    diff_c = c_1 - c_2;


    if [diff_r,diff_c] == [1,0]
        inv_action = 1;
    elseif [diff_r,diff_c] == [0,1]
        inv_action = 3;
    elseif [diff_r,diff_c] == [-1,0]
        inv_action = 2;
    elseif [diff_r,diff_c] == [0,-1]
        inv_action = 4;
    else
        if abs(diff_r)>1;
            if r_1 == grid_size;
                inv_action = 2;
            elseif r_2 == grid_size
                inv_action = 1;
            else
                disp('Something wrong in row side')
                exit;
            end
        end

        if abs(diff_c)>1;
            if c_1 == grid_size;
                inv_action = 4;
            elseif c_2 == grid_size
                inv_action = 3;
            else
                disp('Something wrong in column side')
                exit;
            end
        end
    end

end
