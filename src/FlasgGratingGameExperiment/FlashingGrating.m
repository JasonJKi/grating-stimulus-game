classdef FlashingGrating < handle
    %FLASHINGGRATING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        grating;
        freq;
        contrast;
        orientation;
        size; 
        
        flicker_freq;
        drift_shift;
        
        src_rect;
        dest_rect;
        
        tex;
        
        waitframes = 1;
    end
    
    methods
        function this = FlashingGrating(size, freq, contrast, orientation, flicker_freq, flip_time)
            this.size = size;
            this.grating = sinusoidGrating(freq, size);
            this.src_rect = this.createRect(size);
            this.drift_shift = this.shiftPerFrame(flip_time, this.waitframes, freq);
            this.freq = freq; 
            this.contrast = contrast;
            this.orientation = orientation;
            this.flicker_freq = flicker_freq;
        end
        
        function makeTexture(this, window)
            this.tex = Screen('MakeTexture', window, this.grating, [], [], [], [], 1);
        end
        
        function setDestRect(this, x_pos, y_pos)
            this.dest_rect = CenterRectOnPointd(this.src_rect, x_pos, y_pos);
        end
                
        function drawTexture(this,  x_pos, y_pos, window, i)
            phase = this.currentPhase(i, this.drift_shift, 1/this.freq);
            
            intensity = this.sinusoidalIntensity(this.flicker_freq, this.contrast, GetSecs);
            this.dest_rect = CenterRectOnPointd(this.src_rect, x_pos, y_pos);
            Screen('DrawTexture', window, this.tex, this.src_rect, this.dest_rect, ...
                this.orientation, [], [], intensity, [], [], [0, phase, 0, 0]);
        end
        
    end
    
    methods (Static)
        
        function src_rect = createRect(grating_size)
            visible_grating_size = 2*grating_size+1;
            src_rect =[0 0 visible_grating_size visible_grating_size];
        end
        
        function phase = currentPhase(i, shiftperframe, pixel_cycle)
            phase = mod(i * shiftperframe, pixel_cycle);
        end
        
         function grating_shift = shiftPerFrame(flip_time, waitframes, freq)
            waitduration = waitframes * flip_time;
            p = 1/freq; % pixels/cycle
            grating_shift = p * waitduration;
         end
        
        function amplitude = sinusoidalIntensity(flicker_freq, contrast, t)
%             t = GetSecs;
            amplitude = sin(t*2*pi*flicker_freq)*(255*contrast);
%             if amplitude > 255*contrast*.50
%                 amplitude = 255*contrast;
%             end
        end
        
        
    end
    
end

