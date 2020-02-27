function data = epochTrials(data_raw, event_stamps)

for i = 1:length(event_stamps)
    start_end_time = event_stamps(i).timestamp([1 end]);
    start_end_index = epochTimestamp(data_raw.timestamp, start_end_time);
    
    data(i).timeseries = data_raw.timeseries(start_end_index,:);
    data(i).timestamp = data_raw.timestamp(start_end_index,:);
    data(i).fs = data_raw.fs;
end
   