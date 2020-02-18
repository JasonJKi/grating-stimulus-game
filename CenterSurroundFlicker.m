classdef CenterSurroundFlicker < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        surround_grating
        center_grating
    end
    
    methods
        function this = CenterSurroundFlicker(window)
            % surround
            ifi = Screen('GetFlipInterval', window);

            size = 600;f=0.05;contrast = 0;orientation = 90;flicker_freq = 3;flip_time = ifi;
            this.setSurround(size, f, contrast, orientation, flicker_freq, flip_time)
            
            % center
            size = 300;f=0.05;contrast = .5;orientation = 0;flicker_freq = 3;flip_time = ifi;
            this.setCenter(size, f, contrast, orientation, flicker_freq, flip_time)
            this.makeTexture(window);
        end
        
        function setSurround(this, size, f, contrast, orientation, flicker_freq, flip_time)
            this.surround_grating = FlashingGrating(size, f, contrast, orientation, flicker_freq, flip_time);
        end
        
        function setCenter(this, size, f, contrast, orientation, flicker_freq, flip_time)
            this.center_grating = FlashingGrating(size, f, contrast, orientation, flicker_freq, flip_time);
        end
        
        function makeTexture(this, window)
            this.surround_grating.makeTexture(window);
            this.center_grating.makeTexture(window);
        end
        
        function drawTexture(this, x_pos, y_pos, window, i) 
%             if nargin < 2
%                i = 0;
%             end
            this.surround_grating.drawTexture( x_pos, y_pos, window, i);
            this.center_grating.drawTexture( x_pos, y_pos, window, i);
        end
        
    end
end

