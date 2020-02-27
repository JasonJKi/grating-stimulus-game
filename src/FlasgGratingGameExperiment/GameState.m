classdef GameState < handle
    
   properties
        is_new_trial = false;
        boundary_x;
        boundary_y;
        score = 0;
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
       
       function new_pos = generateRandomXPosition(this, x_pos, min_distance)
%            min_distance = 200; 
           pos = (1:this.boundary_x);
           lower_bound = (min_distance:x_pos-min_distance);
           lower_limit = x_pos-min_distance;
           if lower_limit < 0 
                lower_bound  = [];
           end
           upper_bound = (x_pos+min_distance:this.boundary_x-min_distance);
           upper_limit = x_pos+min_distance;
           if upper_limit > this.boundary_x
               upper_bound = [];
           end
           rand_pos = pos([lower_bound upper_bound]);
           idx=randperm(length(rand_pos),1);
           x_pos = rand_pos(idx);
           y_pos = this.boundary_y/2;
           new_pos = [x_pos y_pos];
       end
       
       function updateScore(this, point)
           this.score = this.score + point;
       end
       
       function checkBoxStatus(this, is_hit, point)
           if is_hit
               this.is_new_trial = true;
               updateScore(this, point)
           end
       end
   end
   
   methods (Static)       

   end
   
end