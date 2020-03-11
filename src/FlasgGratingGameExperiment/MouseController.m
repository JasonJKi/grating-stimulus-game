classdef MouseController
    %MOUSECONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x_pos
        y_pos
        
        x_pos_default
        y_pos_default
        
        x_pos_prev;
        y_pos_prev;
        step;
        current_key;
        
        screen_width
        screen_height
        last_flip = true
        flip = true;
        
        is_escape;
        is_space;
        
        % boundaries
        x_min
        x_max
        y_min
        y_max
    end
    
    methods
        function this = MouseController(x_pos,y_pos,screen_width,screen_height)
            this.x_pos = x_pos;
            this.y_pos = y_pos;
            this.x_pos_default = x_pos;
            this.y_pos_default = y_pos;
            this.screen_width = screen_width;
            this.screen_height = screen_height;
            setXYLim(this, [0 screen_width], [0 screen_height]);
%             reset(this)
        end
              
        function setXYLim(this, x_lim, y_lim)
            this.x_min = x_lim(1);
            this.x_max = x_lim(2);
            
            this.y_min = y_lim(1);
            this.y_max = y_lim(2);
        end
        
        function reset(this)
            this.x_pos = this.x_pos_default;
            this.y_pos = this.y_pos_default;
            SetMouse(this.x_pos, this.y_pos)
        end
        
        function outputArg = run(obj,inputArg)
            
            % History:
            % 25-Jul-2019  mk  Written.
            
            if IsOSX
                fprintf('Sorry, this demo does not work on macOS.\n');
                return;
            end
            
            % Wait for all keyboard buttons released:
            KbReleaseWait;
            
            % Get first mouse device:
            d = GetMouseIndices;
            d = d(1);
            
            % Create a keyboard queue for it, requesting return of first 3 valuators,
            % ie. x and y axis, and maybe some scroll-wheel axis. Request return of
            % raw motion event data (flag 4), so no pointer gain/acceleration/ballistics
            % is applied by the OS and returned valuators are in device specific units
            % of relative motion / movement, not absolute desktop pixel coordinates:
            KbQueueCreate(d, [], 3, [], 4);
            
            % Start movement data collection, place mouse cursor in top-left (0,0) pos:
            KbQueueStart(d);
            SetMouse(0,0)
            [x,y] = GetMouse;
            
            fprintf('Press any key on keyboard to finish demo.\n\n');
            
            % Repeat until keypress:
            while ~KbCheck
                % Fetch all queued samples:
                while KbEventAvail(d)
                    evt = KbEventGet(d);
                    
                    % Motion event? We don't care about other events:
                    if evt.Type == 1
                        % Accumulate absolute mouse position x,y from provided dx,dy movements:
                        x = x + evt.Valuators(1);
                        y = y + evt.Valuators(2);
                        
                        if IsWin
                            % Print what we got: Desktop cursor pos (with pointer acceleration),
                            % accumulated raw device position/motion, and reported increments:
                            fprintf('xc=%f  yc=%f  xi=%f  yi=%f vx=%f  vy=%f  wheel %f\n', evt.X, evt.Y, x, y, ...
                                evt.Valuators(1), evt.Valuators(2), evt.Valuators(3));
                        else
                            % On Linux/X11 in raw mode, no dedicated cursor position is reported, so
                            % skip that. Also, wheel position would be valuator 4, scrap that.
                            fprintf('xi=%f  yi=%f vx=%f  vy=%f\n', x, y, ...
                                evt.Valuators(1), evt.Valuators(2));
                        end
                    end
                end
            end
            
            % Done. Stop data collection and clean up:
            KbQueueStop(d);
            KbQueueRelease(d);
            
            fprintf('\nDone, bye!\n\n');
            
        end
    end
end

