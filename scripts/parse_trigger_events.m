clear all
close all
flicker_data_dir
metadata = readtable([data_dir '/metadata.xlsx']);

n_file = height(metadata);

start_code = 1000;
end_code = -1000;

for i_file = 1:n_file
    
    file_name = metadata.filename{i_file};
    
    game_events_path = [raw_mat_dir.game_events '/' file_name '_game_events'];
    
    x = load(game_events_path);
    x.labels = {'x_pos', 'y_pos', 'surround contrast', 'surround freq', 'center contrast', 'center freq' , 'grating pos', 'stationary'};
    
    game_events = parseGameEvents(x);
    
    mkdir(processed_dir.game_events)
    save([processed_dir.game_events '/' file_name '_game_events'], 'game_events', 'game_events')
end