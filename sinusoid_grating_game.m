% close all; clear all;
% 
[window, scrn_width, scrn_height, glsl]= create_screen(); % generate window 
[x_center, y_center] = RectCenter([0 0 scrn_width, scrn_height]); % screen center

% Perform initial Flip to sync us to the VBL and for getting an initial. VBL-Timestamp for our "WaitBlanking" emulation:
ifi = Screen('GetFlipInterval', window);
vbl = Screen('Flip', window);

% create flashing center-surround gratings
size = 600;
f=0.05;
contrast = 0;
orientation = 90;
flicker_freq = 3;
flip_time = ifi;
surround_grating = FlashingGrating(size, f, contrast, orientation, flicker_freq, flip_time);
surround_grating.makeTexture(window);

size = 300;
f=0.05;
contrast = .5;
orientation = 0;
flicker_freq = 3;
flip_time = ifi;
center_grating = FlashingGrating(size, f, contrast, orientation, flicker_freq, flip_time);
center_grating.makeTexture(window);

% create boxes appearing on the screen.
min_distance = 200-50;
game_state = GameState(scrn_width, scrn_height);
vehicle_box = ScreenObject([200 200 200], [0 0 200 200]);
target_box = ScreenObject([255 255 255], [0 0 200 200]);
obstacle_box_1 = ScreenObject([100 100 100], [0 0 200 200]);
obstacle_box_2 = ScreenObject([100 100 100], [0 0 200 200]);
obstacle_box_3 = ScreenObject([100 100 100], [0 0 200 200]);

eye_tracker = ScreenObject([25 0 0], [0 0 50 50]);

KbName('UnifyKeyNames');
cntrller = KeyboardGUIController(20, x_center, y_center, scrn_width, scrn_height);
% cntrller.test()

%% Setup eyelink
% make sure that we get gaze data from the Eyelink
% open file to record data to
el=EyelinkInitDefaults(window);
WaitSecs(0.1);
if EyelinkInit()~= 1; return; end

Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
Eyelink('OpenFile', 'demo.edf');
Eyelink('Message', 'SYNCTIME');

result1 = EyelinkDoTrackerSetup(el); % result2 = EyelinkDoDriftCorrect(eyelink);
WaitSecs(0.1);
Eyelink('StartRecording');
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR; % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end
Screen('Flip', window); % Screen('closeAll')

i=0;
while cntrller.update()
    
    
    error=Eyelink('CheckRecording');
    if(error~=0)
        break;
    end
    
    if Eyelink( 'NewFloatSampleAvailable') > 0
        % get the sample in the form of an event structure
        evt = Eyelink( 'NewestFloatSample');
        if eye_used ~= -1 % do we know which eye to use yet?
            % if we do, get current gaze position from sample
            x_eye = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
            y_eye = evt.gy(eye_used+1);
            mx = 0;
            my = 0;
            % do we have valid data and is the pupil visible?
            if x_eye~=el.MISSING_DATA && y_eye~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                mx=x_eye;
                my=y_eye;
                disp(mx)
            end
        end
    end
        
    x_pos = cntrller.x_pos;
    y_pos = cntrller.y_pos;

    vehicle_box.setPosition(x_pos, y_pos)

    % place box randomly
    if i == 0 || game_state.is_new_trial
        new_pos = game_state.generateRandomPosition(x_pos, y_pos, 5, 200);
        
        target_box.setPosition(new_pos(2,1), new_pos(2,2));
        obstacle_box_1.setPosition(new_pos(3,1), new_pos(3,2));        
        obstacle_box_2.setPosition(new_pos(4,1), new_pos(4,2));        
        obstacle_box_3.setPosition(new_pos(5,1), new_pos(5,2));
        
        target_box.is_hit = false;
        obstacle_box_1.is_hit = false;
        obstacle_box_2.is_hit = false;
        obstacle_box_3.is_hit = false;
        
        game_state.is_new_trial = false;
    end
    
    % check that position of keyboard and the target box are close to each
    % other.
    game_state.checkBoxStatus(target_box.isHit(x_pos, y_pos, min_distance))
    game_state.checkBoxStatus(obstacle_box_1.isHit(x_pos, y_pos, min_distance))
    game_state.checkBoxStatus(obstacle_box_2.isHit(x_pos, y_pos, min_distance))
    game_state.checkBoxStatus(obstacle_box_3.isHit(x_pos, y_pos, min_distance))

    % draw textures
    %1) flashing grating
    surround_grating.drawTexture( x_pos, y_pos, window, i);
    center_grating.drawTexture( x_pos, y_pos, window, i);
    
    % 2) game objects
    vehicle_box.drawTexture(window, 'FrameOval')
    target_box.drawTexture(window, 'FillRect')
    obstacle_box_1.drawTexture(window, 'FillRect')
    obstacle_box_2.drawTexture(window, 'FillRect')
    obstacle_box_3.drawTexture(window, 'FillRect')
    
    % eye tracker
    eye_tracker.setPosition(mx, my);
    eye_tracker.drawTexture(window, 'FillOval')

    Eyelink('Message', num2str(i))
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (1 - 0.5) * ifi);
    i=i+1;
end

Eyelink('StopRecording');
Eyelink('CloseFile');
Eyelink('receivefile');

% The same commands wich close onscreen and offscreen windows also close textures.
sca;

