function events = parseGameEvents(x)

start_index = find(x.timeseries(:,8) == 1000)+1;
end_index = find(x.timeseries(:,8) == -1000)-1;

event_labels = {'x_pos', 'y_pos', ...
    'surround_contrast', 'surround_freq', ...
    'center_contrast', 'center_freq', ...
    'is_active', 'is_stationary'};

for i = 1:length(start_index)
    
    event_index = start_index(i):end_index(i);
    events(i).timestamp = x.timestamp(event_index);
    
    for ii = 1:length(event_labels)
        events(i).(event_labels{ii}) = x.timeseries(event_index, ii);
        if find(ii == [3 4 5 6 7 8])
            events(i).(event_labels{ii}) = events(i).(event_labels{ii})(1);
        end

    end
    
    events(i).game_type = 0;
    if events(i).is_active(1) && events(i).is_stationary(1)
        events(i).game_type = 1;
    elseif events(i).is_active(1) && ~events(i).is_stationary(1)
        events(i).game_type = 2;
    elseif ~events(i).is_active(1) && ~events(i).is_stationary(1)
        events(i).game_type = 3;
    end

    events(i).flicker_type = 0;
    if events(i).surround_freq ~= events(i).center_freq
        events(i).flicker_type = 1;
    else
        events(i).flicker_type = 2;
    end
    

end


