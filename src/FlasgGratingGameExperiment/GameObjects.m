classdef GameObjects < handle
    %GAMEOBJECTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vehicle
        target
        non_target
        size
        
        min_distance
        num_obstacles
        num_items
        
        items
        prev_hit_item_index = -1;
        current_hit_item_index;
    end
    
    methods
        function this = GameObjects(size)
            this.min_distance = 50;
            this.size = size;
        end
        
        function this = targetsLeftRight(this)
            this.target = ScreenObject([255 255 255], [0 0 this.size this.size]);
            this.non_target = ScreenObject([100 100 100], [0 0 this.size this.size]);
            items(1) = this.target;
            items(2) = this.non_target;
            this.items = items;
            this.num_items = 2;
        end
        
        function this = randomObjectsAndTargets(this, size, num_obstacles)
            this.target = ScreenObject([255 255 255], [0 0 size size]);
            
            items(1) = this.target;
            for i =1:num_obstacles
                items(i+1) =  ScreenObject([100 100 100], [0 0 size size]);
            end
            
            this.items = items;
            
            this.num_obstacles = num_obstacles;
            this.num_items = num_obstacles + 1;
        end
        
        function setPosition(this, new_pos)
            for i =1:this.num_items
                this.items(i).setPosition(new_pos(i,1), new_pos(i,2));
                this.items(i).is_hit = false;
                if i == 1
                    this.target.x_pos = new_pos(1,1);
%                     disp(new_pos(1,1))
%                     disp(this.target.x_pos)
                     this.target.is_hit = false;
                 end
            end
        end
        
        function [is_hit, is_new] = checkItemStatus(this, game_state, x_pos, y_pos)
            is_hit = false;
            for i = 1:this.num_items
                item_hit = this.items(i).isHit(x_pos, y_pos, this.min_distance);
                if item_hit
                    is_hit = item_hit;
                    game_state.current_hit_item_index = i;
                    updateScore(game_state, 1)
                end
            end
            is_new = false;
            if game_state.current_hit_item_index ~= game_state.prev_hit_item_index
                is_new = true;
                game_state.prev_hit_item_index = game_state.current_hit_item_index;
            end
            %                 disp(is_hit)
            %                 game_state.checkBoxStatus(this.items, -1);
            this.target.isHit(x_pos, y_pos, this.min_distance);
        end
        
        function drawTexture(this, window, shape)
            for i =1:this.num_items
                this.items(i).drawTexture(window, shape)
            end
        end
    end
end

