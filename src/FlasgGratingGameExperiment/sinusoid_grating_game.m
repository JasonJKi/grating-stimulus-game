% close all; %clear all;
% setup install
%% Create Screen
[window, scrn_width, scrn_height, glsl, ifi, vbl]= create_screen(0); % generate window 
% [window, scrn_width, scrn_height, glsl, ifi, vbl]= create_screen(0); % generate window 

%% Flashing center-surround gratings
is_passive = 0;

flicker = CenterSurroundFlicker();
f = 0.05; orientation = 90;
center_size = 566/2; 
surround_size = 946/2; 

surround_flicker_f = 5; 
surround_contrast = .25;
flicker.setSurround(surround_size, f, surround_contrast, orientation, surround_flicker_f, ifi)

center_flicker_f = 5; 
center_contrast = .5;
flicker.setCenter(center_size, f, center_contrast, orientation, center_flicker_f, ifi);
flicker.setBoundaryPoints([0 0 50 50], center_size*2);

flicker.makeTexture(window);

% create boxes appearing on the screen.
game_objects = GameObjects(0);

%% Game Control
KbName('UnifyKeyNames');
[x_center, y_center] = RectCenter([0 0 scrn_width, scrn_height]); % initial position screen center.
keyboard = KeyboardController(10, x_center, y_center, scrn_width, scrn_height);
ai_controller = AIController(10, x_center, y_center, scrn_width, scrn_height);
% game_controller.test()

%% Game Trigger
[trigger, trigger_info] = createLSLStream('Trigger', 'Trigger',1,1,'cf_int8',1234230420);
%% Game Logic
game_state = GameState(scrn_width, scrn_height);

%% Setup eyelink
eyelink = EyeLinkExperiment();
eyelink.calibrate(window);
eyelink.startRecord('demo'); 
eyelink.sendMessage('Start');
eyelink.setEyeShadow([25 0 0], [0 0 50 50]);
eyelink.createLSLStream()
i=0;

while keyboard.update() 
    
    % Run eyelink recording and on screen tracking shadow. 
    if eyelink.checkRecording()
        eyelink.getEvent()
        eyelink.sendMessage(num2str(i));
        eyelink.outputStream()
    end
    
    keyboard.disableWithEyeTracker(eyelink.x_pos, eyelink.y_pos, center_size+100);
    ai_controller.disableWithEyeTracker(eyelink.x_pos, eyelink.y_pos, center_size+100);

    if is_passive
        % get keyoboard position.
        x_pos = ai_controller.x_pos;
        y_pos = ai_controller.y_pos;
    else
        x_pos = keyboard.x_pos;
        y_pos = keyboard.y_pos;
    end
    
    % set objects in random positions.
    if i == 0 || game_state.is_new_trial
    % scrn_obj_pos = game_state.generateRandomPosition(x_pos, y_pos, game_objects.num_items, 200);
        scrn_obj_pos = game_state.generateRandomPoint(scrn_width, y_pos, 300);
        game_objects.setPosition(scrn_obj_pos)
        game_state.is_new_trial = false;
    end
    
    % check that position of keyboard and the target box are close to each
    % other.
    game_objects.checkItemStatus(game_state, x_pos, y_pos);
    
    % draw textures
    %1) flashing grating
    flicker.drawTexture(x_pos, y_pos, window, i);
    
    % 2) game objects6566666666666666555555555555555555555555555
    game_objects.drawTexture(window, 'FrameOval')
        
    % 3) eyetracker shadow
    eyelink.drawEyeShadowTexture(window, 'FillOval')

    % Flip 'waitframes' monitor refresh intervals after last redraw.

    ai_controller.followTarget(scrn_obj_pos(1))

    vbl = Screen('Flip', window, vbl + (1 - 0.5) * ifi);
    i=i+1;
end

% eyelink.receiveFile();
sca;

