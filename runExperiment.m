close all; clear all;
setup install
KbName('UnifyKeyNames')

%% setup eyelink,
subject_name = 'demo'; 
screen_num = 1;
eyelink =[];
eyelink = EyeLinkExperiment();
eyelink.calibrate(screen_num);
eyelink.startRecord(subject_name);
eyelink.createLSLStream()

%% Set up game.
monitor.distance = 27; monitor.width = 20.8;
flash_grating_game = FlashGratingControlGame(monitor.distance, monitor.width);
flash_grating_game.setEyelink(eyelink);
flash_grating_game.createLSLStream();

%% Make sure that the lab recorder is on.
pauseToSetRecorder('is lab recorder set?')

%% assign game sequence.
% flicker_types = { 'variable contrast', 'variable frequency', ...
%                 'variable contrast', 'variable contrast', ...
%                 'variable frequency', 'variable frequency'};
%             
% game_types = { 'static', 'static', ...
%             'active control', 'passive pursuit', ...
%             'active control', 'passive pursuit'};
flicker_types = {'constant', 'constant'};
game_types = {'mine sweeper', 'mine sweeper watching'};
% , 'static', 'left and right control','left and right passive pursuit', 'mine sweeper'};
%% Exp 1; variable contrast (static)
trial_duration = 10; 
pause_duration = 1;
num_exp = length(flicker_types);
indx = 1:num_exp;
% indx = randperm(num_exp); 
num_repeats = 20;

for i = 1:num_exp
    
    r = indx(i);
    
    flicker_type = flicker_types{r};
    game_type = game_types{r};
    if strcmp(flicker_type,'calibrate')
        eyelink.calibrate(screen_num);
        eyelink.startRecord(subject_name);
        return
    end
    flicker_param = flickerParam(flicker_type,num_repeats);
    game_param = gameParam(game_type, trial_duration, pause_duration);
    exp_param = setstructfields(flicker_param, game_param);
    
    makeWindow(flash_grating_game, screen_num);
%     showGameInstructions(flash_grating_game, game_type);
    runTrials(flash_grating_game, exp_param);
%     sca
    
%     ii = ii + 1;
end
sca
    
    


% 