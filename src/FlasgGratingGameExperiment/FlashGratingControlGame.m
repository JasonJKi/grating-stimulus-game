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
        
        pos_step = 10;
        min_distance = 100;
        monitor
        
        visual_angle_surround = 21.5;
        visual_angle_center = 6.1;
        
        is_keyboard_controlled;
        is_obj_disabled = false;
        is_eyeshadow_disabled = true;
        is_disable_control_with_eyetracker = true;
        is_quit = false;
        
        x_pos = 0
        y_pos = 0
        
        lsl;
        trial_info
        
        event_code;
        start_code = 1000;
        end_code = -1000;
        
        attention_circle
        
        game_type;
        num_items = 10;
        target_size = 50;
        
        grating_size = 350;
        fovea_size = 100;
        boundary_size = 300
    end
    
    methods
        
        function this = FlashGratingControlGame(distance, width)
            setMonitor(this, distance, width)
            setGame(this)
        end
        
        function setGame(this)
            setCenterSurroundGrating(this, this.grating_size, this.fovea_size);
            
            setController(this, this.monitor.px_width, this.monitor.px_height)
            
            % this.game_objects = targetsLeftRight(GameObjects(this.target_size));
            % this.game_state = moveLeftRight(GameState(this.monitor.px_width, this.monitor.px_height), 700);
            this.game_objects = randomObjectsAndTargets(GameObjects(this.target_size),this.target_size, this.num_items);
            this.game_state = GameState(this.monitor.px_width, this.monitor.px_height, this.boundary_size);
            
            this.attention_circle = CenterAttentionCircle(100);
        end
        
        function setMonitor(this, distance, width, pixel_dims)
            if nargin < 4
                pixel_dims = get(0,'ScreenSize');
                this.monitor.px_width = pixel_dims(3);
                this.monitor.px_height = pixel_dims(4);
            end
            this.monitor.distance = distance;
            this.monitor.width = width;
            this.monitor.px_per_unit = this.pixelsPerUnit(this.monitor.px_width, width);
        end
        
        function setEyelinkController(this, eyelink)
            this.eyelink = eyelink;
        end
        
        function setCenterSurroundGrating(this, surround_size, center_size)
            % visual angle Center 6.1� 563 pixels surround  21.5� 946pixels
            % surround_size = 946/2;
            % center_size = 266/2;
            
            orientation = 90; contrast = 1; flicker_freq = 5; flip_time = 1;
            spatial_freq = .05;
            %             surround_size = this.pxSizeVisualAngle(visual_angle_surround, monitor_distance, px_per_unit);
            %             center_size = this.pxSizeVisualAngle(visual_angle_center, monitor_distance, px_per_unit);
            
            this.flicker_grating = CenterSurroundGrating();
            this.flicker_grating.setSurround(surround_size, spatial_freq, contrast, orientation, flicker_freq, flip_time)
            % this.flicker_grating.setCenter(400/2, spatial_freq, contrast, orientation, flicker_freq, flip_time);
            this.flicker_grating.setBoundaryPoints([0 0 50 50], center_size);
        end
        
        function makeWindow(this, screen)
            if this.is_quit
                return
            end
            if nargin < 2
                screen = 0;
            end
            
            try
                info = Screen('GetWindowInfo', this.window);
                warning('screen already opened.')
            catch
                disp('No Screen found, creating a new Screen')
                [this.window, scrn_width, scrn_height] = create_screen(screen); % generate window
                this.monitor.px_width = scrn_width;
                this.monitor.px_height = scrn_height;
                setGame(this)
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
%             this.mouse_controller = MouseController(x_center, y_center, px_width, px_height);
        end        

        function createLSLStream(this)
            this.lsl.labels = {'x_pos', 'y_pos', 'surround contrast', 'surround freq', 'center contrast', 'center freq' , 'keyboard controlled', 'game_type', 'correct answer', 'response'};
            this.lsl.outlet = createLSLStream('GameEvents', 'Trigger', 8, 100,'cf_float32','22222123');
            this.lsl.default_event = ones(1, length(this.lsl.labels));
        end
        
        function run(this, duration)
            current_time = Screen('Flip', this.window);
            ifi = Screen('GetFlipInterval', this.window);
            i=0;
            
            eye = this.eyelink;
            end_time = current_time + duration;
            
%             this.attention_circle.setParam(end_time, duration);
            this.keyboard.setBoundary(this.game_state.x_lim, this.game_state.y_lim);
           
            % mark the start event code for lsl stream
            sendLSLTriggerStream(this, this.start_code)           
            intv_time = 0;
            while this.keyboard.update() && (current_time < end_time)
                
                % Run eyelink recording and on screen tracking shadow.
                if ~isempty(eye) &&  ~eye.is_dummy_mode
                    if eye.checkRecording()
                        eye.getEvent()
                        eye.sendMessage(num2str(i));
                        eye.sendLSLStream()
                        
                        if this.is_disable_control_with_eyetracker
                            this.keyboard.disableWithEyeTracker(eye.x_pos, eye.y_pos, this.target_size + 75);
                            this.ai_controller.disableWithEyeTracker(eye.x_pos, eye.y_pos, this.target_size + 75);
                        end
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

                % set objects in random positions.this.target.is_hit
                if i == 0 || this.game_state.is_new_trial
                    this.game_state.generateRandomPosition(this.x_pos, this.y_pos, this.game_objects.num_items, this.min_distance);
                % scrn_obj_pos = this.game_state.generateRandomXPosition(this.x_pos, 300);
                % scrn_obj_pos = this.game_state.pickRandomFixedPosition();
%                     this.game_state.setFixedPosition()
                    this.game_objects.setPosition(this.game_state.target_pos)
                    this.game_state.is_new_trial = false;
                end
    
                % check that position of keyboard and the target box are close to each
                % other.
                [is_hit, is_new] = this.game_objects.checkItemStatus(this.game_state, this.x_pos, this.y_pos);
%                 game_state.checkBoxStatus(is_hit, -1);

                % draw textures
                %1) flashing grating
                this.flicker_grating.drawTexture(this.x_pos, this.y_pos, this.window, i);
%                 this.attention_c1ircle.drawTexture(this.x_pos, this.y_pos, this.window, current_time);
                this.flicker_grating.drawHitRing(this.x_pos, this.y_pos, this.window, is_hit, is_new, intv_time)

                if ~this.is_obj_disabled
                    % 2) game objects
                    this.game_objects.drawTexture(this.window, 'FrameOval')
                end
                
                % 3) eyetracker shadow
                if ~isempty(eye) && ~this.is_eyeshadow_disabled
                    this.eye.drawEyeShadowTexture(this.window, 'FillOval')
                end

                this.ai_controller.followTarget(this.game_objects.target.x_pos)
                sendLSLStream(this);
                
                % Flip 'waitframes' monitor refresh intervals after last redraw.
                intv_time = (1 - 0.5) * ifi;
                current_time = Screen('Flip', this.window, intv_time + current_time);
                i=i+1;
            end
            
            % send event code to mark that the trial ended.
            sendLSLTriggerStream(this, this.end_code)

            % reset the keyboard position to center of the screen.
            this.keyboard.reset();
            this.x_pos = this.keyboard.x_pos;
            this.y_pos = this.keyboard.y_pos;
            
%             [correct_answer, x_lim, y_lim] = this.attention_circle.drawAttentionCircleSurvey(this.x_pos, this.y_pos, this.window);
%             answer = this.keyboard.answerRecorder(5);
%             is_correct = drawOutlineOverTheAnswer(answer, correct_answer, x_lim, y_lim, this.window);
%           1234  this.attention_circle.addScore(is_correct);
            response = echoString(this.window, 'How many mines did you find? \n (Input number with the keypad)',this.keyboard.x_pos,this.keyboard.y_pos,[255 255 255],[0 0 0], 1);
            response = str2num(response);
            answer = this.game_state.score;
            is_correct = echoAnswer(response, answer, this.window);
            sendLSLScore(this, answer, response)
            this.ai_controller.reset();
            Screen('Flip', this.window)
            if this.keyboard.is_escape
                sca;
                this.is_quit = true;
                if this.eyelink.status == 1
                    Eyelink('StopRecording');
                    Eyelink('CloseFile');
                end
                return
            end
            
            if this.keyboard.is_space
                pause(.25)
               this.keyboard.is_space = false;
            end
            
            this.game_state.is_new_trial = true;
        end
        
        function showGameInstructions(this, type)
            showGameInstructions(type, this.window)
        end
        
        function setEyelink(this, eye)
            this.eyelink = eye;
        end
        
        function sendLSLTriggerStream(this, code)
             this.lsl.outlet.push_sample(this.lsl.default_event*code);
        end
        
        function sendLSLStream(this)
            this.event_code = [this.x_pos, this.y_pos, this.trial_info -1 -1];
            this.lsl.outlet.push_sample(this.event_code');
        end
        
        function sendLSLScore(this, answer, response)
            this.event_code = [0, 0, this.trial_info, answer, response];
            this.lsl.outlet.push_sample(this.event_code');
        end
        
        function setTrialInfo(this, flicker_params, trial_params)
            is_active = trial_params.is_active;
%             is_stationary = trial_params.is_obj_disabled;
            game_type = trial_params.game_type;
            this.trial_info = [flicker_params, is_active, game_type];
        end
        
        function runTrials(this, trial_params)
            if this.is_quit
                return
            end
            num_trials = length(trial_params.surround_contrast);
            this.is_keyboard_controlled = trial_params.is_active;
            this.is_obj_disabled = trial_params.is_obj_disabled;
            r = randperm(num_trials); 
            for ii = 1:num_trials
                if this.is_quit
                    break
                end
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
            sendLSLTriggerStream(this, -10000 - this.attention_circle.score)
            this.attention_circle.score = 0;
        end
    end
        
    methods (Static)
        function pixel_size = pxSizeVisualAngle(visual_angle, distance, pixel_per_unit)
            radians = visual_angle/180;
            fov_size = tan(radians)*distance;
            pixel_size = round(fov_size * pixel_per_unit);
        end
        
        function px_per_unit = pixelsPerUnit(pixels, length)
            px_per_unit = pixels/length;
        end
        
        function freq = cyclesPerDegree(pixels_per_inch, distance, spatial_freq)
            freq = round(180/pi*distance*pixels_per_inch*spatial_freq);
        end        
    end
end
