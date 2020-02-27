clear all
close all
flicker_data_dir
metadata = readtable([data_dir '/metadata.xlsx']);

n_file = height(metadata);

for i_file = 1:n_file
    
    file_name = metadata.filename{i_file};
    
    lsl = loadMyLabstreams([xdf_dir '/' file_name '.xdf']);
    
    field_names = fieldnames(lsl);
    n_fields = length(field_names);
    for ii = 1:n_fields
        stream_name = field_names{ii};
        stream = lsl.(stream_name);
        if strcmp(stream_name, 'eeg')
            fs = stream.fs;
            desired_fs = 500;
            factor = desired_fs/fs;
            stream.timeseries = single(resample(double(stream.timeseries), desired_fs, fs));
            stream.timestamp = resample(stream.timestamp, desired_fs, fs);
            stream.fs = desired_fs;
        end
        steam_dir = [raw_mat_dir.path '/' stream_name];
    
        mkdir(steam_dir);
        save([steam_dir '/' file_name '_' stream_name],'-struct','stream','-v7.3')
    end
end