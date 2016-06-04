function [Global_Q_matrix,Q_matrix_snake] = update_global_q_snake(Q_matrix_snake, Global_Q_matrix,grid_size,snake_r,snake_c)
    Q_matrix_snake(:,1) = Q_matrix_snake(:,1) + snake_r;
    Q_matrix_snake(:,2) = Q_matrix_snake(:,2) + snake_c;
    [r_greater,~] = find(Q_matrix_snake(:,1) > grid_size);
    [r_lesser,~] = find(Q_matrix_snake(:,1) < 1);
    [c_greater,~] = find(Q_matrix_snake(:,2) > grid_size);
    [c_lesser,~] = find(Q_matrix_snake(:,2) < 1);

    Q_matrix_snake(r_greater',1) = Q_matrix_snake(r_greater',1) - grid_size;
    Q_matrix_snake(r_lesser',1) = grid_size  - abs(Q_matrix_snake(r_lesser',1));
    Q_matrix_snake(c_greater',2) = Q_matrix_snake(c_greater',2) - grid_size;
    Q_matrix_snake(c_lesser',2) = grid_size  - abs(Q_matrix_snake(c_lesser',2));
    
    for l=1:size(Q_matrix_snake,1)
        ind = sub2ind([grid_size,grid_size],Q_matrix_snake(l,1),Q_matrix_snake(l,2));
        Q_matrix_snake(l,3) = ind;
        Global_Q_matrix(ind,:) = Global_Q_matrix(ind,:) + Q_matrix_snake(l,4:end);
    end

    [Q_matrix_snake(:,1), Q_matrix_snake(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
    Q_matrix_snake(:,1) = Q_matrix_snake(:,1) - ceil(grid_size/2);
    Q_matrix_snake(:,2) = Q_matrix_snake(:,2) - ceil(grid_size/2);


end
