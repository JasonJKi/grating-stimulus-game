classdef CenterAttentionCircle < handle
   
    properties
        circle
        radius
        
        window
        boundary_color;
        boundary_change_time;
        color_order
        color_index
        duration
        
        score = 0;
    end

    methods
        function this = CenterAttentionCircle(radius)
            this.circle = ScreenObject([0 0 0], [0 0 radius radius]);
            this.radius = radius;
        end
        
        function setParam(this, time, duration)
            this.boundary_color = {[255 0 0], ...
                [0 255 0], ...
                [0 0 255 ], ...
                [255 255 0]};
            this.boundary_change_time = time;
            this.color_order = randperm(4);
            this.color_index = 0;
            this.duration = duration;
        end
        
        function drawTexture(this, x_pos, y_pos, window, time)
            
            current_time = (this.boundary_change_time-time);
            round_time = ceil(current_time);
            delta = round_time - current_time;
%             disp(delta)
%             current_index = round(this.duration)-this.color_index;
%             disp(current_index)
%             disp(mod(round_time, current_index))
            if  (delta > .5) && round_time > 1
                color = this.boundary_color{this.color_order(round_time-1)};
%                 disp(round_time)
                this.circle.setPosition(x_pos, y_pos);
                this.circle.drawOvalFrame(window, color, 5);
            end
        end
        
        function [correct_answer, x_lim, y_lim] = drawAttentionCircleSurvey(this, x_pos, y_pos, window)
            
            rand_index = randperm(3);
            iter = 1; color_order_list = ones(3,4);
            random_perm_list = perms(1:4);
            random_perm_list = random_perm_list(randperm(length(random_perm_list)),:);
            for i = 1:3
                ind = rand_index(i);
                if i == 1
                    color_order_list(ind,:) = this.color_order;
                    correct_answer = ind; 
                else
                    k = 1;
                    rand_color_order = ones(1,4);
                    while sum(rand_color_order ~= this.color_order) ~= 4
                        rand_color_order = random_perm_list(k,:);
                        random_perm_list(k,:) = [];
                        k = k+1;
                    end
                    color_order_list(ind,:) = rand_color_order;
                end
                iter = iter + 1;
            end
            
            size = this.radius*1.1;
            x_offsets = [-size*2, -size, 0, size]+(size/1.5);
            y_offsets = [-size*1.25, 0, size*1.25];
                    
            txt_color = [255 255 255];
%             yrgb
%             num_order = [3:-1:1];
            for i = 1:3 %row 
                text = [num2str(i) ')'];
                order = color_order_list(i,:);
                Screen('TextSize', window, 40);
                Screen('DrawText', window, text, x_pos - size*3, y_pos + y_offsets(i), txt_color);

                n_columns = length(this.boundary_color);
                for ii = 1:n_columns %columns
                    color = this.boundary_color{order(ii)};
                    this.circle.setPosition(x_pos - x_offsets(ii), y_pos + y_offsets(i));
                    this.circle.drawOvalFrame(window, color, 5)
                end
                y_min(i) = y_pos+y_offsets(i)-100;
                y_max(i) = y_pos+y_offsets(i)+100;
                x_min(i) = [x_pos - size*3]; 
                x_max(i) = [x_pos + size*2];
            end
            x_lim = [x_min' x_max'];
            y_lim = [y_min' y_max'];

            message_str = 'Select the circle color order by appearance';
            Screen('TextSize', window, 40);
            Screen('TextFont', window, 'Courier');
            DrawFormattedText(window, message_str, 'Center', y_pos-size*2, [255 255 255]);
            
            Screen('Flip', window, [], 1);
        end
        
        function addScore(this, is_correct)
            this.score = this.score + is_correct;
        end
    end
end