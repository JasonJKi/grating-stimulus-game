function lsl = loadMyLabstreams(xdf_filepath)
% Load in EEG and photodiode triggers from LSL.
% Load xdf file to streams
disp(['Loading labstream from: ' xdf_filepath])
[streams, file_header] = load_xdf(xdf_filepath);
nStreams = length(streams);

% Sort and assign streams
disp('Following streams found:')
for i = 1:nStreams
    stream = streams{i};
    streamName = stream.info.name;
    timeseries = stream.time_series';
    timestamp = stream.time_stamps';
    fs = str2num(stream.info.nominal_srate);
    disp(['    ' streamName])
    switch streamName
        case 'OBS Studio'
            lsl.obs.timeseries = single(timeseries);
            lsl.obs.timestamp = timestamp;
            lsl.obs.fs = fs;
        case 'BrainAmpSeries'
            lsl.eeg.timeseries = single(timeseries);
            lsl.eeg.timestamp = timestamp;
            lsl.eeg.fs = fs;
        case 'BrainAmpSeries-Markers'
            lsl.photodiode.timeseries = str2num(cell2mat(timeseries));
            lsl.photodiode.timestamp = timestamp;
            lsl.photodiode.fs = round(length(timestamp)/(timestamp(end)-timestamp(1)));
        case 'Keyboard'
            lsl.keyboard.timeseries = timeseries;
            lsl.keyboard.timestamp = timestamp;
            lsl.keyboard.fs = fs;
        case 'EyeLink'
            lsl.eyelink.timeseries = timeseries;
            lsl.eyelink.timestamp = timestamp;
            lsl.eyelink.fs = stream.info.effective_srate;
        case 'GameEvents'
            lsl.game_events.timeseries = timeseries;
            lsl.game_events.timestamp = timestamp;
            lsl.game_events.fs = stream.info.effective_srate;
        case 'Eyelink'
            lsl.eyelink.timeseries = timeseries;
            lsl.eyelink.timestamp = timestamp;
            lsl.eyelink.fs = stream.info.effective_srate;
        otherwise
            continue
    end
end
disp('labstream loading complete')
return