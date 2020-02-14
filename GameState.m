classdef GameState < handle
    
   properties
        is_new_trial = true;
        boundary_x;
        boundary_y;
   end
   
   methods
       function this = GameState(width, height)
           this.boundary_x = width;
           this.boundary_y = height;
       end
   
       function new_pos = generateRandomPosition(this, x_pos, y_pos, num_pos, min_distance)
           ref_pos = [x_pos, y_pos];
           width = this.boundary_x - min_distance;
           height = this.boundary_y - min_distance;
           new_pos = create_random_points_with_distance(ref_pos, width, height, num_pos, min_distance);
       end
       
%        function newTrial(this)
%            if is_new_trial
%            
%            end
%        end
       
       function checkBoxStatus(this, is_hit)
           if is_hit
               this.is_new_trial = true;
           end
       end
   end
   
end