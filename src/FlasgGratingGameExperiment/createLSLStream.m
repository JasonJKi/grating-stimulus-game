function [outlet, info] = createLSLStream(name,type,channelcount,samplingrate,channelformat,sourceid)
addpath(genpath('C:\Users\Jason\STIM2EEG-LAB\MATLAB-lsl'))
% make a new stream outlet
disp('Creating a new stream...');
info = lsl_streaminfo(lsl_loadlib(), name, type, channelcount, samplingrate, channelformat, sourceid);
outlet = lsl_outlet(info);

return 
% % send data into the outlet
% while true
%     outlet.push_chunk(randn(8,50));
%     pause(0.5);
% end