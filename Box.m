classdef TargetBox 
    
    properties
        color = [0 0 0];
        size = [0 0 100 100];
        rect_pos = [0 0 0 0];

        is_hit = false;
        x_pos = 0;
        y_pos = 0;
    end
    
    methods
        function this = TargetBox(color, size)
            if nargin > 0
            this.color = color;
            this.size = size;
            end
        end
        
        function setPosition(this, x_pos, y_pos)
            this.x_pos = x_pos;
            this.y_pos = y_pos;        
            this.rect_pos = CenterRectOnPointd(this.size, x_pos, y_pos);
        end
        
        function status = isHit(this, x_pos, y_pos, boundary)
            if (this.x_pos + boundary > x_pos && this.x_pos - boundary < x_pos) && (this.y_pos + boundary > y_pos && this.y_pos - boundary  < y_pos)
                this.is_hit = true;
            end
            status = this.is_hit;
        end
        
        function drawTexture(window, fillType)
            Screen(fillType, window, this.color, this.rect_pos)
        end
        
    end
end