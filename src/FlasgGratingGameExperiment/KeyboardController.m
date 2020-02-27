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
    end
    
    methods
        function this = KeyboardController(step,x_pos,y_pos,screen_width,screen_height)
            KbName('UnifyKeyNames')
            this.step = step;
            this.x_pos = x_pos;
            this.y_pos = y_pos;
            this.x_pos_default = x_pos;
            this.y_pos_default = y_pos;
            this.screen_width = screen_width;
            this.screen_height = screen_height;
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
        
        function check_boundary(this)
            if this.x_pos < 0
                this.x_pos = 0;
            elseif this.x_pos > this.screen_width
                this.x_pos =  this.screen_width;
            end
            
            if this.y_pos < 0
                this.y_pos = 0;
            elseif this.y_pos >  this.screen_height
                this.y_pos =  this.screen_height;
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
        
    end
    methods (Access = private, Static)
        function [keyCode] = kbCheck()
            [~,~, keyCode] = KbCheck;
        end
    end
        
end

