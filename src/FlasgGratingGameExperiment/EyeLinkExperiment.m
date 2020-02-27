classdef EyeLinkExperiment < handle

    properties
        el
        status = 0;
        eye_used
                
        event
        x_pos
        y_pos
        
        eye_shadow
        lsl
    end
    
    methods 
        
        function this = EyeLinkExperiment()
            init(this)
            setEyeShadow(this, [25 0 0], [0 0 50 50]);
%             this.getEvent();
        end
        
        function init(this)
            WaitSecs(0.1);
            if EyelinkInit()== 1; this.status = 1; end
        end
        
        function is_calibrated = calibrate(this, win_num)
            [window]= create_screen(win_num); % generate window 

            this.el = EyelinkInitDefaults(window);
            is_calibrated = EyelinkDoTrackerSetup(this.el);
%             is_calibrated = EyelinkDoDriftCorrection(this.el);
            sca; 
            WaitSecs(0.1);
        end
        
        function startRecord(this, filename)
            Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
            checkLeftRightEye(this)
            if this.status == 1
                Eyelink('OpenFile', [filename '.edf']);
                Eyelink('StartRecording');
            end
        end
       
        
        function status  = checkRecording(this)
            status = ~Eyelink('CheckRecording');
        end
       
        
        function getEvent(this)
            
            this.status = 0;
            this.x_pos = -1000;
            this.y_pos = -1000;
            
            if Eyelink( 'NewFloatSampleAvailable') > 0
                eye_used = this.eye_used;
                % get the sample in the form of an event structure
                this.event = Eyelink( 'NewestFloatSample');
                if this.eye_used ~= -1 % do we know which eye to use yet?
                    x = this.event.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = this.event.gy(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x ~= this.el.MISSING_DATA && y~= this.el.MISSING_DATA && this.event.pa(eye_used+1)>0
                        this.status = 1;
                        this.x_pos = x;
                        this.y_pos = y;
                        if isempty(this.x_pos)
                            this.status = 0;
                            this.x_pos = -1000;
                            this.y_pos = -1000;
                        end
                    end
                end
            end
          
        end
            
        function setEyeShadow(this, color, size)
            this.eye_shadow = ScreenObject(color, size);
        end
            
        function checkLeftRightEye(this)
            this.eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            if this.eye_used == this.el.BINOCULAR % if both eyes are tracked
                this.eye_used = this.el.LEFT_EYE; % use
            end
        end
        
        function drawEyeShadowTexture(this, window, shape)
             this.eye_shadow.setPosition(this.x_pos, this.y_pos);
             this.eye_shadow.drawTexture(window, shape)
        end
        
        function createLSLStream(this)
             [this.lsl.outlet, this.lsl.info] = createLSLStream('Eyelink', 'Gaze' ,17 , 100, 'cf_float32', '111111');
             this.lsl.labels = {'time', 'px', 'py', 'hx','hy', 'pa', 'gx', 'gy', 'rx', 'ry'};             
        end
        
        function sendLSLStream(this)
            data = [];
            for i = 1:length(this.lsl.labels)
               data = [data this.event.(this.lsl.labels{i})];
            end
            this.lsl.outlet.push_sample(data');
        end
%         time: [1232] px: [-32768 -32768] py: [-32768 -32768] hx: [-32768 -32768] hy: [-32768 -32768] pa: [0 32768] gx: [-32768 -32768] gy: [-32768 -32768] rx: 42.3000 ry: 36.9000
        
    end
    
    methods (Static)
        
        function sendMessage(str)
            Eyelink('Message', str);
        end
        
        function status = receiveFile()
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            status = Eyelink('receivefile');
        end
        
        
    end
    
end