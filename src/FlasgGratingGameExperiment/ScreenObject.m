classdef ScreenObject < handle
    
    properties
        color = [0 0 0];
        size = [0 0 100 100];
        rect_pos = [0 0 0 0];

        is_hit = false;
        x_pos = 0;
        y_pos = 0;
        pos
    end
    
    methods
        function this = ScreenObject(color, size)
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
            x_min = this.x_pos - boundary;
            x_max = this.x_pos + boundary;
            y_min = this.y_pos - boundary;
            y_max = this.y_pos + boundary;
            if (x_max > x_pos && x_min < x_pos) && (y_max > y_pos && y_min < y_pos)
                status = true;
            else
                status = false;
            end
            this.is_hit = status;
        end
        
        function drawTexture(this, window, fillType)
            Screen(fillType, window, this.color, this.rect_pos);
        end
        
        function drawTextureColor(this, window, color, fillType)
            Screen(fillType, window, color, this.rect_pos);
        end
        
        function drawOvalFrame(this, window, color, width)
            Screen('FrameOval', window, color, this.rect_pos, width);
        end
        
    end
end