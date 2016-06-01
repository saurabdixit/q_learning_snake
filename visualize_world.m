function visualize_world(virtual_world,r,c,sleep,trial)
    bw = double(virtual_world < 0.5);
    bw(r,c) = 0.5;
    imshow(bw, 'InitialMagnification', 'fit');
    handler = findobj(gcf,'type','image');
    x_data = get(handler,'XData');
    y_data = get(handler,'YData');
    m = size(get(handler,'CData'),1);
    n = size(get(handler,'CData'),2);
    [m,n] = size(get(handler,'CData'));
    if m>1
        pix_h = diff(y_data)/(m-1);
    else
        pix_h = 1;
    end
    if n>1
        pix_w = diff(x_data)/(n-1);
    else
        pix_w = 1;
    end
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
    
    %handler = imshow(bw, 'InitialMagnification', 'fit');
    ax = ancestor(handler, 'axes');
    line('Parent', ax, 'XData', x_h, 'YData', y_h, ...
        'Color', 'b', 'LineWidth', 1, 'Clipping', 'off');
    line('Parent', ax, 'XData', x_v, 'YData', y_v, ...
        'Color', 'b', 'LineWidth', 1, 'Clipping', 'off');
    title(strcat('Iteration Number:  ',int2str(trial)));
    pause(sleep)
end
