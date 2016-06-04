function visualize_world(virtual_world,snake_location,r,c,sleep,trial)
    colored_image(:,:,1) = double(virtual_world < 0.5);
    colored_image(:,:,2) = double(virtual_world < 0.5);
    colored_image(:,:,3) = double(virtual_world < 0.5);
    colored_image(r,c,2) = 0.5;
    colored_image(snake_location(1,1),snake_location(1,2),1) = 0.6;
    colored_image(snake_location(end,1),snake_location(end,2),1) = 1;
    colored_image(snake_location(end,1),snake_location(end,2),2) = 1;
    imshow(colored_image, 'InitialMagnification', 'fit');
    handler = findobj(gcf,'type','image');
    handler = findobj(gcf,'type','image');
    x_data = get(handler,'XData');
    y_data = get(handler,'YData');
    m = size(get(handler,'CData'),1);
    n = size(get(handler,'CData'),2);
    pix_h = 1;
    pix_w = 1;
    y_top = y_data(1) - (pix_h/2);
    y_bottom = y_data(2) + (pix_h/2);
    y = linspace(y_top, y_bottom, m+1);
    x_left = x_data(1) - (pix_w/2);
    x_right = x_data(2) + (pix_w/2);
    x = linspace(x_left, x_right, n+1);
    x_v = zeros(1, 2*numel(x));
    x_v(1:2:end) = x;
    x_v(2:2:end) = x;
    
    y_v = repmat([y(1) ; y(end)], 1, numel(x));
    y_v(:,2:2:end) = flipud(y_v(:,2:2:end));
    
    x_v = x_v(:);
    y_v = y_v(:);
      
    y_h = zeros(1, 2*numel(y));
    y_h(1:2:end) = y;
    y_h(2:2:end) = y;
    
    x_h = repmat([x(1) ; x(end)], 1, numel(y));
    x_h(:,2:2:end) = flipud(x_h(:,2:2:end));
    
    x_h = x_h(:);
    y_h = y_h(:);
    
    ax = ancestor(handler, 'axes');
    line('Parent', ax, 'XData', x_h, 'YData', y_h, ...
        'Color', 'b', 'LineWidth', 1, 'Clipping', 'off');
    line('Parent', ax, 'XData', x_v, 'YData', y_v, ...
        'Color', 'b', 'LineWidth', 1, 'Clipping', 'off');
    title(strcat('Iteration Number:  ',int2str(trial)));
    pause(sleep)
end
