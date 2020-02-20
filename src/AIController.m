classdef AIController < handle
    %KEYBOARDCONTRLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        key = Key();
        x_pos
        y_pos
        
        x_pos_prev;
        y_pos_prev;
        step;
        current_key;
        
        screen_width
        screen_height
        last_flip = true
        flip = true;
    end
    
    methods
        
        function this = AIController(step,x_pos,y_pos,screen_width,screen_height)
            this.step = step;
            this.x_pos = x_pos;
            this.y_pos = y_pos;
            this.screen_width = screen_width;
            this.screen_height = screen_height;
            this.x_pos_prev =  this.x_pos;
            this.y_pos_prev =  this.y_pos;
        end
        
        
        function followTarget(this, x_pos_target)
            this.x_pos_prev =  this.x_pos;
            this.y_pos_prev =  this.y_pos;
            if this.x_pos > x_pos_target 
                 this.x_pos = this.x_pos - this.step;
            else
                this.x_pos = this.x_pos + this.step;
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
    end
    
    
end