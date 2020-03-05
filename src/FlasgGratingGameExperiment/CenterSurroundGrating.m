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
        
        window
        boundary_color;
        boundary_change_time;
        color_order
        color_index
        duration
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
        end
        
        function makeTexture(this, window)
            this.surround_grating.makeTexture(window);
            this.center_grating.makeTexture(window);
%             this.fixation_point.makeTexture(window);
        end
        
        function drawTexture(this, x_pos, y_pos, window, i) 
            this.surround_grating.drawTexture( x_pos, y_pos, window, i);
            this.center_grating.drawTexture( x_pos, y_pos, window, i);

            this.fixation_point.setPosition(x_pos, y_pos);
            this.fixation_point.drawTexture(window,'FrameOval');
        end
        
        function setBoundaryCenterCircleColor(this, time, duration)
            this.boundary_color = {[255 0 0], ...
                [0 255 0], ...
                [0 0 255 ], ...
                [255 255 0]};
            this.boundary_change_time = time;
            this.color_order = randperm(4);
            this.color_index = 0;
            this.duration = duration;
        end
        
        function drawChangingBoundaryTexture(this, x_pos, y_pos, window, time)
            current_time = this.boundary_change_time-time;
            round_time = ceil(current_time);
            delta = round_time - current_time;
%             disp(delta)
            current_index = round(this.duration)-this.color_index;
%             disp(current_index)
%             disp(mod(round_time, current_index))
            if  (delta > .5) && round_time > 1
                color = this.boundary_color{this.color_order(round_time-1)};
                disp(round_time)
                this.center_surround_boundary.setPosition(x_pos, y_pos);
                this.center_surround_boundary.drawOvalFrame(window, color, 5)
            end
        end
        
        function correct_answer_index = drawAllBoundaryBoxes(this, x_pos, y_pos, window, color_order)
            boundary_size = this.center_boundary_size*1.1;
            x_offsets = [-boundary_size*2 -boundary_size, 0, boundary_size]+(boundary_size/1.5);
            y_offsets = [boundary_size*1.25, 0, -boundary_size*1.25];
            
            rand_index = randperm(3);
            iter = 1;color_order_list = ones(3,4);
            for i = rand_index
                if iter == 1
                    color_order_list(i,:) = color_order;
                    correct_answer_index = i; 
                else
                    rand_color_order = ones(1,4);
                    while sum(rand_color_order ~= color_order) ~= 4
                        rand_color_order = randperm(4);
                    end
                    color_order_list(i,:) = rand_color_order;
                end
                iter = iter + 1;
            end
            
            
            message_str = 'Select the correct order of circle colors by appearance';
            Screen('TextSize', window, 40);
            Screen('TextFont', window, 'Courier');
            DrawFormattedText(window, message_str, 'Center', y_pos-boundary_size*2, [255 255 255])
                            
            txt_color = [255 255 255];
            for i = 1:3
                text = [num2str(i) ')'];
                color_order = color_order_list(i,:);
                Screen('TextSize', window, 40);
                Screen('DrawText', window, text, x_pos + x_offsets(1)- boundary_size*1.2, y_pos-y_offsets(i), txt_color)
                for ii = 1:length(this.boundary_color)
                    color = this.boundary_color{color_order(ii)};
                    this.center_surround_boundary.setPosition(x_pos-x_offsets(ii), y_pos-y_offsets(i));
                    this.center_surround_boundary.drawOvalFrame(window, color, 5)
                end
            end
            Screen('Flip', window)
        end
        
        
    end
end