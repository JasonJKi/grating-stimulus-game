classdef GameObjects < handle
    %GAMEOBJECTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vehicle
        target
        obstacle
        
        min_distance
        num_obstacles
        num_items
    end
    
    methods
        function this = GameObjects(num_obstacles)
            this.target = ScreenObject([255 255 255], [0 0 200 200]);
            for i =1:num_obstacles
                obstacles(i) =  ScreenObject([100 100 100], [0 0 200 200]);
            end
            this.obstacle = obstacles;
           
            this.num_obstacles = num_obstacles;
            this.num_items = num_obstacles + 1;
            this.min_distance = 200-50;
        end
        
        function setPosition(this, new_pos)
            
            this.target.setPosition(new_pos(1,1), new_pos(1,2));
            this.target.is_hit = false;
            for i =1:this.num_obstacles
                this.obstacle(i).setPosition(new_pos(i+1,1), new_pos(i+1,2));
                this.obstacle(i).is_hit = false;
            end
            
        end
        
        function checkItemStatus(this, game_state, x_pos, y_pos)
            game_state.checkBoxStatus(this.target.isHit(x_pos, y_pos, this.min_distance), 1);
            for i =1:this.num_obstacles
                game_state.checkBoxStatus(this.obstacle(i).isHit(x_pos, y_pos, this.min_distance), -1);
            end
        end
        
        function drawTexture(this, window, shape)
            this.target.drawTexture(window, shape)
            for i =1:this.num_obstacles
                this.obstacle(i).drawTexture(window, shape)
            end
        end
    end
end

