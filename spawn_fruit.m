% This is the function for the spawning of the fruit at random location

function [fruit_r, fruit_c] = spawn_fruit(world)
    [r,c] = find(world==0);
    index_vector = 1:size(r,1);
    ind = randsample(index_vector,1);
    fruit_r = r(ind);
    fruit_c = c(ind);
end
