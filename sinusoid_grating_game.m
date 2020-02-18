% close all; clear all;
%% Create Screen
[window, scrn_width, scrn_height, glsl, ifi, vbl]= create_screen(); % generate window 

%% Screen Objects 
% flashing center-surround gratings
flicker = CenterSurroundFlicker(window);

% create boxes appearing on the screen.
game_objects = GameObjects(4);

%% Game Control
KbName('UnifyKeyNames');
[x_center, y_center] = RectCenter([0 0 scrn_width, scrn_height]); % initial position screen center.
game_controller = KeyboardGUIController(20, x_center, y_center, scrn_width, scrn_height);
% game_controller.test()

%% Game Logic
game_state = GameState(scrn_width, scrn_height);

%% Setup eyelink
eyelink = EyeLinkExperiment(window);
eyelink.calibrate();
eyelink.startRecord('111')
eyelink.sendMessage('Start');
eyelink.setEyeShadow([25 0 0], [0 0 50 50]);

i=0;
while game_controller.update()
    
    % Run eyelink recording and on screen tracking shadow. 
    if eyelink.checkRecording()
        eyelink.getEvent()
        eyelink.sendMessage(num2str(i));
        eyelink.drawEyeShadowTexture(window, 'FillOval')
    end
    
    % get keyoboard position.
    x_pos = game_controller.x_pos;
    y_pos = game_controller.y_pos;
    
    % set objects in random positions.
    if i == 0 || game_state.is_new_trial
        new_pos = game_state.generateRandomPosition(x_pos, y_pos, game_objects.num_items, 200);
        game_objects.setPosition(new_pos)
        game_state.is_new_trial = false;
    end
    
    % check that position of keyboard and the target box are close to each
    % other.
    game_objects.checkItemStatus(game_state, x_pos, y_pos);
    
    % draw textures
    %1) flashing grating
    flicker.drawTexture(x_pos, y_pos, window, i);
    
    % 2) game objects
    game_objects.drawTexture(window, 'FillRect')
    
    
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (1 - 0.5) * ifi);
    i=i+1;
end

eyelink.receiveFile();
sca;

