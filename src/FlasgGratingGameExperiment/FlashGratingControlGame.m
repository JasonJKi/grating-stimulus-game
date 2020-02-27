classdef FlashGratingControlGame < handle

    properties
        window
       
        
        flicker_grating
        
        % controllers
        keyboard
        eyelink

        ai_controller
        
        game_objects
        game_state
        
        pos_step = 15;

        monitor
        
        visual_angle_surround =21.5;
        visual_angle_center = 6.1;
        
        is_keyboard_controlled;
        is_obj_disabled = false;
        is_eyeshadow_disabled = true;
        is_disable_control_with_eyetracker = true;
        
        target_size
        
        x_pos = 0
        y_pos = 0
        lsl;
        trial_info
        
        event_code;
        start_code = 1000;
        end_code = -1000;; 
    end
    
    methods
        
        function this = FlashGratingControlGame(distance, width)
            setMonitor(this, distance, width)
            setCenterSurroundGrating(this, this.monitor.distance, this.monitor.px_unit, ...
                this.visual_angle_surround, this.visual_angle_center);
            setController(this, this.monitor.px_width, this.monitor.px_height)
            
            this.target_size = this.flicker_grating.center_grating.size/2;

            this.game_objects = GameObjects(0, this.target_size);
            this.game_state = GameState(this.monitor.px_width, this.monitor.px_height);            
        end
        
        function setMonitor(this, distance, width)
            scrn_size = get(0,'ScreenSize');
            this.monitor.px_width = scrn_size(3);
            this.monitor.px_height = scrn_size(4);
            this.monitor.distance = distance;
            this.monitor.width = width;
            this.monitor.px_unit = this.pixelsPerUnit(scrn_size(3), width);           
        end
        
        function setEyelinkController(this, eyelink)
            this.eyelink = eyelink;
        end
        
        
        function setCenterSurroundGrating(this, monitor_distance, px_unit, visual_angle_surround, visual_angle_center)
            %visual angle Center 6.1� 563 pixels surround  21.5� 946pixels
%             surround_size = 946/2;
%            center_size = 266/2;

            orientation = 90; contrast = 1; flicker_freq = 5; flip_time = 1;
            spatial_freq = .05;           
            surround_size = this.pxSizeVisualAngle(visual_angle_surround, monitor_distance, px_unit);
            center_size = this.pxSizeVisualAngle(visual_angle_center, monitor_distance, px_unit);

            this.flicker_grating = CenterSurroundGrating();
            this.flicker_grating.setSurround(1000/2, spatial_freq, contrast, orientation, flicker_freq, flip_time)
            this.flicker_grating.setCenter(400/2, spatial_freq, contrast, orientation, flicker_freq, flip_time);
            this.flicker_grating.setBoundaryPoints([0 0 50 50], center_size*2);
        end

        function makeWindow(this, screen)
            if nargin < 2
                screen = 0;
            end
            
            try
                info = Screen('GetWindowInfo', this.window);
                warning('screen already opened.')
            catch
                disp('No Screen found, creating a new Screen')
                [this.window] = create_screen(screen); % generate window
                this.flicker_grating.makeTexture(this.window);
            end
            
            pause(.1)
        end
        
        function setSurround(this, contrast, flicker_grating_freq)
            this.flicker_grating.surround_grating.contrast = contrast;
            this.flicker_grating.surround_grating.flicker_freq = flicker_grating_freq;
        end
        
        function setCenter(this, contrast, flicker_grating_freq)
            this.flicker_grating.center_grating.contrast = contrast;
            this.flicker_grating.center_grating.flicker_freq = flicker_grating_freq;
        end
        
        function setFlickerProperties(this, flicker_params)
            sc = flicker_params(1);
            sf = flicker_params(2);
            cc = flicker_params(3);
            cf = flicker_params(4);
            setSurround(this, sc, sf)
            setCenter(this, cc, cf)
        end
        
        function setController(this, px_width, px_height)
            [x_center, y_center] = RectCenter([0 0 px_width, px_height]); % initial position screen center.
            this.keyboard = KeyboardController(this.pos_step, x_center, y_center, px_width, px_height);
            this.ai_controller = AIController(this.pos_step, x_center, y_center, px_width, px_height);
        end
        

        function createLSLStream(this)
            this.lsl.labels = {'x_pos', 'y_pos', 'surround contrast', 'surround freq', 'center contrast', 'center freq' , 'keyboard controlled', 'stationary'};
            this.lsl.outlet = createLSLStream('GameEvents', 'Trigger', 8, 100,'cf_float32','22222123');
            this.lsl.default_event = ones(1, length(this.lsl.labels));
        end
        
        function run(this, time)
            vbl = Screen('Flip', this.window);
            ifi = Screen('GetFlipInterval', this.window);
            i=0;
            
            eyelink = this.eyelink;
            time = vbl + time;
            
            sendLSLTriggerStream(this, this.start_code)
            while this.keyboard.update() && (vbl < time)

                % Run eyelink recording and on screen tracking shadow.
                    if ~isempty(eyelink) && eyelink.checkRecording() && Eyelink('IsConnected')
                    eyelink.getEvent()
                    eyelink.sendMessage(num2str(i));
                    eyelink.sendLSLStream()
                    
                    if this.is_disable_control_with_eyetracker
                        this.keyboard.disableWithEyeTracker(eyelink.x_pos, eyelink.y_pos, this.target_size + 75);
                        this.ai_controller.disableWithEyeTracker(eyelink.x_pos, eyelink.y_pos, this.target_size + 75);
                    end
                end

                if this.is_keyboard_controlled
                    this.x_pos = this.keyboard.x_pos;
                    this.y_pos = this.keyboard.y_pos;
                else
                    % get keyoboard position.
                    this.x_pos = this.ai_controller.x_pos;
                    this.y_pos = this.ai_controller.y_pos;
                end

                % set objects in random positions.
                if i == 0 || this.game_state.is_new_trial
                % scrn_obj_pos = game_state.generateRandomPosition(x_pos, y_pos, game_objects.num_items, 200);
                    scrn_obj_pos = this.game_state.generateRandomXPosition(this.x_pos, 300);
                    this.game_objects.setPosition(scrn_obj_pos)
                    this.game_state.is_new_trial = false;
                end
    
                % check that position of keyboard and the target box are close to each
                % other.
                this.game_objects.checkItemStatus(this.game_state, this.x_pos, this.y_pos);

                % draw textures
                %1) flashing grating
                this.flicker_grating.drawTexture(this.x_pos, this.y_pos, this.window, i);

                if ~this.is_obj_disabled
                    % 2) game objects
                    this.game_objects.drawTexture(this.window, 'FrameOval')
                end
                
                % 3) eyetracker shadow
                if ~isempty(eyelink) && ~this.is_eyeshadow_disabled
                    this.eyelink.drawEyeShadowTexture(this.window, 'FillOval')
                end
                

                this.ai_controller.followTarget(scrn_obj_pos(1))
                
                sendLSLStream(this);
                
                % Flip 'waitframes' monitor refresh intervals after last redraw.
                vbl = Screen('Flip', this.window, vbl + (1 - 0.5) * ifi);
                i=i+1;
            end
            sendLSLTriggerStream(this, this.end_code)

            this.keyboard.reset();
            this.ai_controller.reset();
            
            Screen('Flip', this.window)
            if this.keyboard.is_escape
                sca;
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                return
            end
            
            if this.keyboard.is_space
                pause(.25)
               this.keyboard.is_space = false;
            end
            
            this.game_state.is_new_trial = true;
        end
        
        function showGameInstructions(this, type, name)
            showGameInstructions(type, this.window)
        end
        
        function setEyelink(this, eyelink)
            this.eyelink = eyelink;
        end
        
        function sendLSLTriggerStream(this, code)
             this.lsl.outlet.push_sample(this.lsl.default_event*code);
        end
        
        function sendLSLStream(this)
            this.event_code = [this.x_pos, this.y_pos, this.trial_info];
            this.lsl.outlet.push_sample(this.event_code');
        end
        
        function setTrialInfo(this, flicker_params, trial_params)
            is_active = trial_params.is_active;
            is_stationary = trial_params.is_obj_disabled;
            this.trial_info = [flicker_params, is_active, is_stationary];
        end
        
        function runTrials(this, trial_params)
            num_trials = length(trial_params.surround_contrast);
            this.is_keyboard_controlled = trial_params.is_active;
            this.is_obj_disabled = trial_params.is_obj_disabled;

            r = randperm(num_trials); 
            for ii = 1:num_trials
                trial = r(ii);
                sc = trial_params.surround_contrast(trial);
                sf = trial_params.surround_flicker(trial);
                cc = trial_params.center_contrast(trial);
                cf = trial_params.center_flicker(trial);
                
                flicker_params = [sc, sf, cc, cf];
                
                setFlickerProperties(this, flicker_params)
                setTrialInfo(this, flicker_params, trial_params)
                run(this, trial_params.trial_duration)
                pause(trial_params.pause_duration)
            end
        end
    end
        
    methods (Static)
        function pixel_size = pxSizeVisualAngle(visual_angle, distance, pixel_per_unit)
            radians = visual_angle/180;
            fov_size = tan(radians)*distance;
            pixel_size = round(fov_size * pixel_per_unit);
        end
        
        function px_unit = pixelsPerUnit(pixels, length)
            px_unit = pixels/length;
        end
        
        function freq = cyclesPerDegree(pixels_per_inch, distance, spatial_freq)
            freq = round(180/pi*distance*pixels_per_inch*spatial_freq);
        end        
    end
end