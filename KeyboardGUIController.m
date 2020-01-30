classdef KeyboardGUIController < handle
    %KEYBOARDCONTRLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        key = Key();
        x_pos
        y_pos
        step;
        current_key;
        
        screen_width
        screen_height
        last_flip = true
        flip = true;
    end
    
    methods
        function this = KeyboardGUIController(step,x_pos,y_pos,screen_width,screen_height)
            this.step = step;
            this.x_pos = x_pos;
            this.y_pos = y_pos;
            this.screen_width = screen_width;
            this.screen_height = screen_height;
            KbName('UnifyKeyNames');
        end
        
        
        function status = update(this)
            [keyIsDown,secs, keyCode] = KbCheck;
            disp(find(keyCode))
            status = true;
            upDownLeftRight(this, keyCode)
            check_boundary(this)

            if keyCode(this.key.escape)
                status = false;
            end
        end
        
        function check_boundary(this)
            if this.x_pos < 0
                this.x_pos = 0;
            elseif this.x_pos > this.screen_width
                this.x_pos =  this.screen_width;
            end
            
            if this.y_pos < 0
                this.y_pos = 0;
            elseif this.y_pos >  this.screen_height
                this.y_pos =  this.screen_height;
            end
        end
            
        function upDownLeftRight(this, keyCode)
            if keyCode(this.key.left)
                this.x_pos = this.x_pos - this.step;
            elseif keyCode(this.key.right)
                this.x_pos = this.x_pos + this.step;
            elseif keyCode(this.key.up)
                this.y_pos = this.y_pos - this.step;
            elseif keyCode(this.key.down)
                this.y_pos = this.y_pos + this.step;
            elseif keyCode(this.key.space)
                this.flip = ~this.flip;
            end
        end
        
        function status = flipped(this)
            status = false;
            if this.last_flip ~= this.flip
                status = true;
                this.last_flip = this.flip;
            end
            
        end
        
    end
    methods (Access = private, Static)
        function [keyCode] = kbCheck()
            [~,~, keyCode] = KbCheck;
        end
    end
        
end

