close all
flicker_data_dir
metadata = readtable([data_dir '/metadata.xlsx']);

n_file = height(metadata);

experiment_type = { 'variable contrast', 'static'; ...
                    'variable frequency', 'static'; ...
                    'variable contrast', 'active control';...
                    'variable contrast','passive pursuit'; ...
                    'variable frequency' 'active control'; ...
                    'variable frequency', 'passive pursuit'};

start_code = 1000;
end_code = -1000;

fs = 500;
[b7, a7] = butter(5, [6 8]/(fs/2),'bandpass'); % drift removal
[b15, a15] = butter(5, [14 16]/(fs/2),'bandpass'); % drift removal
[b25, a25] = butter(5, [24 25]/(fs/2),'bandpass'); % drift removal
[b_alpha, a_alpha] = butter(5, [8 13]/(fs/2),'bandpass'); % drift removal

game_type_dict= {{1, 'static'}; {2, 'active'}; {3, 'passive'}};
flicker_type_dict = {{1, 'variable contrast'}; {2, 'variable_flicker'}}; 

for i_file = 1:n_file
    
    file_name = metadata.filename{i_file};
        
    load([processed_dir.game_events '/' file_name '_game_events']);

    eeg_raw = load([raw_mat_dir.eeg '/' file_name '_eeg']    );
    
    eeg = epochTrials(eeg_raw, game_events);

    for i = 1:length(eeg)

        eeg(i).fft = fft(double(eeg(i).timeseries));     
        
        for ii = 1:96
            eeg(i).power_7hz(ii) = mean(filter(b7,a7,double(eeg(i).timeseries(:,ii))).^2);
            eeg(i).power_15hz(ii) = mean(filter(b15,a15, double(eeg(i).timeseries(:,ii))).^2);
            eeg(i).power_25hz(ii) = mean(filter(b25, a25, double(eeg(i).timeseries(:,ii))).^2);
            eeg(i).power_alpha(ii) = mean(filter(b_alpha, a_alpha, double(eeg(i).timeseries(:,ii))).^2);
            eeg(i).power_broadband(ii) = mean(double(eeg(i).timeseries(:,ii)).^2);

        end
    end
    
    game_type_index = cat(1,game_events.game_type);
    flicker_type_index = cat(1,game_events.flicker_type);
    
    center_contrast_index = cat(1,game_events.center_contrast);
    surround_contrast_index = cat(1,game_events.surround_contrast);
    center_frequency_index = cat(1,game_events.center_freq);
    surround_frequency_index = cat(1,game_events.surround_freq);

    % center surround comparison with background active vs passive 15 hz
    static_index = (game_type_index == 1);    
    active_index = (game_type_index == 2);
    passive_index = (game_type_index == 3);
    
    freq = [7,15];
    plot_color = {'b', 'r'};
    figure(1);clf; hold on
    plot_line = {'--', '*-', '.-'};
    for i_f = 1:2
        center_frequency = (center_frequency_index == freq(i_f));
        surround_frequency = (surround_frequency_index == freq(i_f));
        
        group_1 = (active_index & center_frequency & surround_frequency);
        group_2 = (passive_index & center_frequency & surround_frequency);
        group_3 = (static_index & center_frequency & surround_frequency);

        eeg_power_15 = cat(1,eeg.power_15hz);
        eeg(i).power_alpha(ii)
        contrasts =  [0 0.5000 1.0000];
        active_power = [];  passive_power = []; alpha_power =[]

        eeg_power_15 = cat(1,eeg.power_15hz);
        eeg_power_7 = cat(1,eeg.power_7hz);
        eeg_alpha = cat(1,eeg.power_alpha);

        for ii = 1:3
            if i_f == 1
                eeg_power = eeg_power_7;
            else
                eeg_power = eeg_power_15;
            end
            index_1 = (group_1 & (surround_contrast_index==contrasts(ii)));
            index_2 = (group_2 & (surround_contrast_index==contrasts(ii)));
            index_3 = (group_3 & (surround_contrast_index==contrasts(ii)));
            index_4 = (surround_contrast_index==contrasts(ii));
            active_power(ii,:) = mean(eeg_power(index_1,:),2);
            passive_power(ii,:) = mean(eeg_power(index_2,:),2);
            static_power(ii,:) = mean(eeg_power(index_3,:),2);
%             alpha_power(ii,:) = mean(eeg_alpha(index_4,:),2);

        end
        
        std_active = std(active_power,[],2)/sqrt(length(active_power));
        std_passive = std(passive_power,[],2)/sqrt(length(passive_power));
        std_static = std(static_power,[],2)/sqrt(length(static_power));
        std_alpha = std(static_power,[],2)/sqrt(length(static_power));

        errorbar([0 .5 1], mean(active_power,2), std_active, ['r' plot_line{i_f}])
        errorbar([0 .5 1], mean(passive_power,2), std_passive, ['g' plot_line{i_f}])
        errorbar([0 .5 1], mean(static_power,2), std_static, ['b' plot_line{i_f}])
%         errorbar([0 .5 1], mean(alpha_power, 2), std_static, ['k' plot_line{i_f}])
    end

    title('ssvep')
    legend({'active 7hz', 'passive 7hz', 'static 7hz', 'active 15hz', 'passive 15hz', 'static 15hz'})
    xlabel('surround contrast (%)')
    ylabel('\muV^{2}')


    freq = [7,15];
    plot_color = {'b', 'r'};
    figure(2);clf; hold on
    plot_line = {'--', '*-', '.-'};
    for i_f = 1:2
        center_frequency = (center_frequency_index == freq(i_f));
        surround_frequency = (surround_frequency_index == freq(i_f));
        
        group_1 = (active_index & center_frequency & surround_frequency);
        group_2 = (passive_index & center_frequency & surround_frequency);
        group_3 = (static_index & center_frequency & surround_frequency);
        
        eeg_power_15 = cat(1,eeg.power_15hz);
        eeg(i).power_alpha(ii)
        contrasts =  [0 0.5000 1.0000];
        active_power = [];  passive_power = []; alpha_power =[]
        
        eeg_power_15 = cat(1,eeg.power_15hz);
        eeg_power_7 = cat(1,eeg.power_7hz);
        eeg_alpha = cat(1,eeg.power_alpha);
        
        for ii = 1:3
            if i_f == 1
                eeg_power = eeg_power_7;
            else
                eeg_power = eeg_power_15;
            end
            index_1 = (group_1 & (surround_contrast_index==contrasts(ii)));
            index_2 = (group_2 & (surround_contrast_index==contrasts(ii)));
            index_3 = (group_3 & (surround_contrast_index==contrasts(ii)));
            index_4 = (surround_contrast_index==contrasts(ii));
            active_power(ii,:) = mean(eeg_alpha(index_1,:),2);
            passive_power(ii,:) = mean(eeg_alpha(index_2,:),2);
            static_power(ii,:) = mean(eeg_alpha(index_3,:),2);
            %             alpha_power(ii,:) = mean(eeg_alpha(index_4,:),2);
            
        end
        
        std_active = std(active_power,[],2)/sqrt(length(active_power));
        std_passive = std(passive_power,[],2)/sqrt(length(passive_power));
        std_static = std(static_power,[],2)/sqrt(length(static_power));
        std_alpha = std(static_power,[],2)/sqrt(length(static_power));
        
        errorbar([0 .5 1], mean(active_power,2), std_active, ['r' plot_line{i_f}])
        errorbar([0 .5 1], mean(passive_power,2), std_passive, ['g' plot_line{i_f}])
        errorbar([0 .5 1], mean(static_power,2), std_static, ['b' plot_line{i_f}])
        %         errorbar([0 .5 1], mean(alpha_power, 2), std_static, ['k' plot_line{i_f}])
    end

    title('alpha')
    legend({'active 7hz', 'passive 7hz', 'static 7hz', 'active 15hz', 'passive 15hz', 'static 15hz'})
    xlabel('surround contrast (%)')
    ylabel('alpha power (\muV^{2})')


    freq = [7,15];
    plot_color = {'b', 'r'};
    figure(3);clf; hold on
    plot_line = {'--', '*-', '.-'};
    for i_f = 1:2
        center_frequency = (center_frequency_index == freq(i_f));
        surround_frequency = (surround_frequency_index == freq(i_f));
        
        group_1 = (active_index & center_frequency & surround_frequency);
        group_2 = (passive_index & center_frequency & surround_frequency);
        group_3 = (static_index & center_frequency & surround_frequency);
        
        eeg_power_15 = cat(1,eeg.power_15hz);
        eeg(i).power_alpha(ii)
        contrasts =  [0 0.5000 1.0000];
        active_power = [];  passive_power = []; alpha_power =[]
        
        eeg_power_15 = cat(1,eeg.power_15hz);
        eeg_power_7 = cat(1,eeg.power_7hz);
        eeg_alpha = cat(1,eeg.power_alpha);
        eeg_broadband = cat(1,eeg.power_broadband);
        for ii = 1:3
            if i_f == 1
                eeg_power = eeg_power_7;
            else
                eeg_power = eeg_power_15;
            end
            index_1 = (group_1 & (surround_contrast_index==contrasts(ii)));
            index_2 = (group_2 & (surround_contrast_index==contrasts(ii)));
            index_3 = (group_3 & (surround_contrast_index==contrasts(ii)));
            index_4 = (surround_contrast_index==contrasts(ii));
            active_power(ii,:) = mean(eeg_alpha(index_1,:),2);
            passive_power(ii,:) = mean(eeg_alpha(index_2,:),2);
            static_power(ii,:) = mean(eeg_alpha(index_3,:),2);
            %             alpha_power(ii,:) = mean(eeg_alpha(index_4,:),2);
            
        end
        
        std_active = std(active_power,[],2)/sqrt(length(active_power));
        std_passive = std(passive_power,[],2)/sqrt(length(passive_power));
        std_static = std(static_power,[],2)/sqrt(length(static_power));
        std_alpha = std(static_power,[],2)/sqrt(length(static_power));
        
        errorbar([0 .5 1], mean(active_power,2), std_active, ['r' plot_line{i_f}])
        errorbar([0 .5 1], mean(passive_power,2), std_passive, ['g' plot_line{i_f}])
        errorbar([0 .5 1], mean(static_power,2), std_static, ['b' plot_line{i_f}])
        %         errorbar([0 .5 1], mean(alpha_power, 2), std_static, ['k' plot_line{i_f}])
    end

    title('broadband')
    legend({'active 7hz', 'passive 7hz', 'static 7hz', 'active 15hz', 'passive 15hz', 'static 15hz'})
    xlabel('surround contrast (%)')
    ylabel('broadband power (\muV^{2})')
end
    % active vs passive;
% 
%     
%     plot_color = {'b', 'r'};
%     figure(i_file);clf; hold on
%     for i_f = 1:2
%         center_frequency = (center_frequency_index == freq(i_f));
%         surround_frequency = (surround_frequency_index == freq(i_f));
%         
%         group_1 = (active_index & center_frequency & surround_frequency);
%         group_2 = (passive_index & center_frequency & surround_frequency);
%         group_1 = (active_index & center_frequency & surround_frequency);
% 
%         eeg_power_15 = cat(1,eeg.power_15hz);
%         frequencies =  [7 15 25];
%         frequencies =  [];
% 
%         active_power = [];  passive_power = []
%         for ii = 1:3
%             index_1 = (group_1 & (surround_contrast_index==contrasts(ii)));
%             index_2 = (group_2 & (surround_contrast_index==contrasts(ii)));
%             active_power(ii,:) = mean(eeg_power_7(index_1,:),2);
%             passive_power(ii,:) = mean(eeg_power_7(index_2,:),2);
%             active_power(ii,:) = mean(eeg_power_15(index_1,:),2);
%             passive_power(ii,:) = mean(eeg_power_15(index_2,:),2);
%             active_power(ii,:) = mean(eeg_power_25(index_1,:),2);
%             passive_power(ii,:) = mean(eeg_power_25(index_2,:),2);
%         end
%         
%         std_active = std(active_power,[],2)/sqrt(length(active_power));
%         std_passive = std(passive_power,[],2)/sqrt(length(passive_power))
%         
%         errorbar([0 .5 1], mean(active_power,2), std_active, ['.--' plot_color{i_f}])
%         errorbar([0 .5 1], mean(passive_power,2),std_passive, ['*-' plot_color{i_f}])
%     end
%     title('active vs passive (variable surround contrast')
%     legend({'active 7hz', 'passive 7hz', 'active 15hz', 'passive 15hz'})
%     xlabel('surround contrast (%)')
%     % active vs passive;
%     
%     var_contrast_index = flicker_type_index == 1;
%     var_freq_index = flicker_type_index == 2;
% 
%     active_index & var_contrast_index
% 
%     eeg.game_events = game_events;
%     eeg{i_file} = eeg;
% 
%     eeg.





