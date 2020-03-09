classdef GameState < handle
    
   properties
        is_new_trial = false;
        boundary_x;
        boundary_y;
        score = 0;
        
        fixed_pos
        x_lim
        y_lim
        
        count = 1;
        current_hit_item_index
        prev_hit_item_index
        target_pos
   end
   
   methods
       
       function this = GameState(width, height, distance)
           this.boundary_x = width;
           this.boundary_y = height;
           
           this.x_lim = [0 + distance, width - distance];
           this.y_lim = [0 + distance, height - distance];
       end
   
       function new_pos = generateRandomPosition(this, x_pos, y_pos, num_pos, min_distance)
           ref_pos = [x_pos, y_pos];
           width = this.boundary_x - min_distance;
           height = this.boundary_y - min_distance;
           new_pos = create_random_points_with_distance(ref_pos, width, height, num_pos, min_distance);
           this.target_pos = new_pos;
           this.prev_hit_item_index = -1;
           this.score = 0;
%            disp(this.prev_hit_item_index)
       end
       
       function new_pos = generateRandomXPosition(this, x_pos, min_distance)
           % min_distance = 200; 
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
       
       function setFixedPosition(this)
           this.target_pos = flipud(this.fixed_pos);
           % this.target.pos = this.fixed_pos(1,:);
           % this.count = mod(1,this.count);
       end
           
       function this = moveLeftRight(this, distance)
           %            min_distance = 200;
           x = this.boundary_x;
           y = this.boundary_y;
           pos_x = [0 + distance, x - distance];
           pos_y = [y/2, y/2];
          
           for i = 1:length(pos_x)
               this.fixed_pos(i, :) = [pos_x(i), pos_y(i)];
           end
           this.x_lim =pos_x;
           this.y_lim =pos_y;
       end
       
       function pos = pickRandomFixedPosition(this)           
           pos = this.fixed_pos(this.count,:);
%            this.count = mod(1,this.count);
       end
       
       function updateScore(this, point)
           if this.current_hit_item_index ~= this.prev_hit_item_index
               
               this.score = this.score + point;
               this.prev_hit_item_index = this.current_hit_item_index;
               
               disp(this.score)
           end
       end
       
       function checkBoxStatus(this, items)
           for i = 1:length(items)
               if i ~= this.current_hit_item_index
                   updateScore(this, 1)
                   this.current_hit_item_index = i;
               end
           end
       end
       
   end
   
   methods (Static)       

   end
   
end