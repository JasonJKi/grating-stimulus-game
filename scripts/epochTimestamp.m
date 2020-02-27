function [start_end_index] = epochTimestamp(timestamp, timestamp_ref)


for i = 1:length(timestamp_ref)
    time_ref = timestamp_ref(i);
    [time_src, index] = min(abs(timestamp-time_ref));
%     flash_timestamp(i) = timestamp(index);
    epoch_index(i) = index;
end

start_end_index = epoch_index(1):epoch_index(end);