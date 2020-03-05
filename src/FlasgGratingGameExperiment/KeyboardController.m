classdef KeyboardController < handle
    %KEYBOARDCONTRLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        key = Key();
        x_pos
        y_pos
        
        x_pos_default
        y_pos_default
        
        x_pos_prev;
        y_pos_prev;
        step;
        current_key;
        
        screen_width
        screen_height
        last_flip = true
        flip = true;
        
        is_escape;
        is_space;
        
        % boundaries
        x_min
        x_max
        y_min
        y_max
    end
    
    methods
        function this = KeyboardController(step,x_pos,y_pos,screen_width,screen_height)
            this.step = step;
            this.x_pos = x_pos;
            this.y_pos = y_pos;
            this.x_pos_default = x_pos;
            this.y_pos_default = y_pos;
            this.screen_width = screen_width;
            this.screen_height = screen_height;
            setBoundary(this, [0 screen_width], [0 screen_height]);
        end
        
        function reset(this)
            this.x_pos = this.x_pos_default;
            this.y_pos = this.y_pos_default;
        end
        
        function status = update(this)
            [keyIsDown,secs, keyCode] = KbCheck;
%             disp(find(keyCode))
            status = true;
            setPosition(this, keyCode);
            check_boundary(this)

            this.is_escape = false;
            if keyCode(this.key.escape)
                this.is_escape = true;
                status = false;
            end
            
            if keyCode(this.key.space)
                this.flip = ~this.flip;
            end
            
            this.is_space = false;
            if keyCode(this.key.space)
                this.is_space = true;
                status = false;
            end
        end
        
        function setBoundary(this, x_lim, y_lim)
            this.x_min = x_lim(1);
            this.x_max = x_lim(2);

            this.y_min = y_lim(1);
            this.y_max = y_lim(2);
        end

        function check_boundary(this)
            if this.x_pos < this.x_min
                this.x_pos = this.x_min;
            elseif this.x_pos > this.x_max
                this.x_pos =  this.x_max;
            end
            
            if this.y_pos < this.y_min
                this.y_pos = this.y_min;
            elseif this.y_pos > this.y_max
                this.y_pos = this.y_max;
            end
        end
            
        function setPosition(this, keyCode)
            this.x_pos_prev = this.x_pos;
            this.y_pos_prev = this.y_pos;

            if keyCode(this.key.left)
                this.x_pos = this.x_pos - this.step;
            end
            if keyCode(this.key.right)
                this.x_pos = this.x_pos + this.step;
            end
            if keyCode(this.key.up)
                this.y_pos = this.y_pos - this.step;
            end
            if keyCode(this.key.down)
                this.y_pos = this.y_pos + this.step;
            end

        end
        
        function is_disabled = disableWithEyeTracker(this, x_eye, y_eye, max_distance)
            eye_distance_from_fixation = sqrt((x_eye - this.x_pos)^2 + (y_eye - this.y_pos)^2); 
            is_disabled = false;
            if eye_distance_from_fixation > max_distance
                this.x_pos = this.x_pos_prev;
                this.y_pos = this.y_pos_prev;
                is_disabled = true;
            end
        end
%         
%         function upDownLeftRight(this, keyCode)
%             if keyCode(this.key.left)
%                 this.x_pos = this.x_pos - this.step;
%             elseif keyCode(this.key.right)
%                 this.x_pos = this.x_pos + this.step;
%             elseif keyCode(this.key.up)
%                 this.y_pos = this.y_pos - this.step;
%             elseif keyCode(this.key.down)
%                 this.y_pos = this.y_pos + this.step;
%             elseif keyCode(this.key.space)
%                 this.flip = ~this.flip;
%             end
%         end
        
        function status = flipped(this)
            status = false;
            if this.last_flip ~= this.flip
                status = true;
                this.last_flip = this.flip;
            end
            
        end
        
        function test(this)
            while this.update()
                disp(['x:' num2str(this.x_pos) 'y:' num2str(this.y_pos)])
            end
        end
        
        function answer = answerRecorder(this, timer)
            answer = [];
            time = 0; tic
            while ~isempty(answer) || time < timer
                [~,~, keyCode] = KbCheck;
                if keyCode(this.key.one)
                    answer = 1;
                elseif keyCode(this.key.two)
                    answer = 2;
                elseif keyCode(this.key.three)
                    answer = 3;
                elseif keyCode(this.key.four)
                    answer = 4;
%                 elseif keyCode(this.key.five)
%                     answer = 5;
                end
                time = toc;
            end
        end
    end
    
    methods (Access = private, Static)
        function [keyCode] = kbCheck()
            [~,~, keyCode] = KbCheck;
        end
    end
        
end

