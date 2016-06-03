function [Global_Q_matrix,Q_matrix_fruit] = update_global_q_fruit(Q_matrix_fruit, Global_Q_matrix,grid_size,fruit_r,fruit_c)
    Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) + fruit_r;
    Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) + fruit_c;
    [r_greater,~] = find(Q_matrix_fruit(:,1) > grid_size);
    [r_lesser,~] = find(Q_matrix_fruit(:,1) < 1);
    [c_greater,~] = find(Q_matrix_fruit(:,2) > grid_size);
    [c_lesser,~] = find(Q_matrix_fruit(:,2) < 1);

    Q_matrix_fruit(r_greater',1) = Q_matrix_fruit(r_greater',1) - grid_size;
    Q_matrix_fruit(r_lesser',1) = grid_size  - abs(Q_matrix_fruit(r_lesser',1));
    Q_matrix_fruit(c_greater',2) = Q_matrix_fruit(c_greater',2) - grid_size;
    Q_matrix_fruit(c_lesser',2) = grid_size  - abs(Q_matrix_fruit(c_lesser',2));
    
    for l=1:size(Q_matrix_fruit,1)
        ind = sub2ind([grid_size,grid_size],Q_matrix_fruit(l,1),Q_matrix_fruit(l,2));
        Q_matrix_fruit(l,3) = ind;
        Global_Q_matrix(ind,:) = Global_Q_matrix(ind,:) + Q_matrix_fruit(l,4:end);
    end

    [Q_matrix_fruit(:,1), Q_matrix_fruit(:,2)] = ind2sub([grid_size,grid_size],1:(grid_size*grid_size));
    Q_matrix_fruit(:,1) = Q_matrix_fruit(:,1) - ceil(grid_size/2);
    Q_matrix_fruit(:,2) = Q_matrix_fruit(:,2) - ceil(grid_size/2);


end
