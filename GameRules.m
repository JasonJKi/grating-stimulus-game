classdef GameState < handle
    
   properties
        is_new_trial = false;
        boundary_x;
        boundary_y;
   end
   
   methods
       function this = GameRules(width, height)
           boundary_x = width;
           boundary_y = height;
       end
   
       function new_pos= generateRandomPosition(this, x_pos, y_pos, num_pos, min_distance);
           ref_pos = [x_pos, y_pos];
           new_pos = create_random_points_with_distance(ref_pos, scrn_width-200, scrn_height-200, num_pos, min_distance);
       end
       
%        function newTrial(this)
%            if is_new_trial
%            
%            end
%        end
       
       function checkBoxStatus(is_hit)
           if is_hit
               is_new_trial = true;
           end
       end
   end
   
end