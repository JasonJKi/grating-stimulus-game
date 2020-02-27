data_dir = '../data';
raw_dir = [data_dir '/raw'];
xdf_dir = [raw_dir '/xdf'];

processed_dir.path = [data_dir '/processed'];
processed_dir.game_events = [processed_dir.path '/game_events'];
processed_dir.eeg = [processed_dir.path '/eeg'];
processed_dir.eyelink = [processed_dir.path '/eyelink'];

raw_mat_dir.path = [raw_dir '/mat']; mkdir(raw_mat_dir.path)
raw_mat_dir.game_events = [raw_mat_dir.path '/game_events'];
raw_mat_dir.eeg = [raw_mat_dir.path '/eeg'];
raw_mat_dir.eyelink = [raw_mat_dir.path '/eyelink'];