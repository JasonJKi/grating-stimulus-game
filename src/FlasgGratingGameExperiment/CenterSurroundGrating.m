classdef CenterSurroundGrating < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        surround_grating
        center_grating
        
        surround_size
        center_size
        
        fixation_point
        center_surround_boundary
        center_boundary_size
       detecion_ring
    end
    
    methods
        function this = CenterSurroundGrating()
            % surround
        end
        
        function setSurround(this, size, f, contrast, orientation, flicker_freq, flip_time)
            this.surround_grating = FlashingGrating(size, f, contrast, orientation, flicker_freq, flip_time);
        end
        
        function setCenter(this, size, f, contrast, orientation, flicker_freq, flip_time)
            this.center_grating = FlashingGrating(size, f, contrast, orientation, flicker_freq, flip_time);
        end
        
        function setBoundaryPoints(this, fixation_size, boundary_size)
            this.fixation_point = ScreenObject([255 0 0], fixation_size);
            this.center_boundary_size = boundary_size;
            this.center_surround_boundary = ScreenObject([0 0 0], [0 0 boundary_size boundary_size]);
            this.detecion_ring = ScreenObject([200 200 200], [0 0 boundary_size boundary_size]);
            
        end
        
        function makeTexture(this, window)
            this.surround_grating.makeTexture(window);
            %             this.center_grating.makeTexture(window);
            %             this.center_surround_boundary.makeTexture(window);
            %             this.fixation_point.makeTexture(window);
        end
        
        function drawTexture(this, x_pos, y_pos, window, i)
            this.surround_grating.drawTexture( x_pos, y_pos, window, i);
            %             this.center_grating.drawTexture( x_pos, y_pos, window, i);
            
            this.fixation_point.setPosition(x_pos, y_pos);
            this.fixation_point.drawTexture(window,'FrameOval');
            
            this.center_surround_boundary.setPosition(x_pos, y_pos);
            this.center_surround_boundary.drawTexture(window,'FrameOval');
        end
        
        
        function drawHitRing(this, x_pos, y_pos, window, is_hit)
            if is_hit
                this.detecion_ring.setPosition(x_pos, y_pos);
                this.detecion_ring.drawOvalFrame(window, [100 100 100], 50);
            end
        end
        
    end
end