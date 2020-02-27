classdef GaborTex < handle
    %GABOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        width
        height 
        
        aspectRatio = 1.0;
        phase = 0;
        orientation = 0;
        numCycles = 5;
        sinusoid_freq
        backgroundOffset = [0.5 0.5 0.5 0.0];
        disableNorm = 1;
        preContrastMultiplier = 0.5;
        gaborDimPix
        sigma = 100
        tex
        window
        propertiesMat
        img_contrast = 1;

        time = 0;
        ifi 

        amplitude = 1;
        start_phase = 0;
    end
    
    methods
        function this = GaborTex(window)
            this.window = window;
            this.sinusoid_freq = this.numCycles / 300;
            this.ifi = Screen('GetFlipInterval', window);
        end
        
        function setGaborProperties( )
        
        end
        
        function create(this)
%             this.tex = CreateProceduralSineGrating(this.window, this.height, this.height, [0.5 0.5 0.5 0.0]);

            this.tex = CreateProceduralGabor(this.window, this.height, ...
                this.height, [], this.backgroundOffset, ...
                this.disableNorm, this.preContrastMultiplier);
%             
            this.setProperties(this.phase, this.sinusoid_freq, this.sigma, this.img_contrast, this.aspectRatio)
            
            Screen('DrawTextures', this.window, this.tex, [], [], ...
                this.orientation, [], [], [], [],...
                kPsychDontDoRotation, this.propertiesMat);
        end
        
        function setTexSize(this, width, height)
            this.width = width;
            this.height = height;
        end
        
        function setTexPos()
        
        end
        function setProperties(this, phase, freq, sigma, img_contrast, aspectRatio)
            this.propertiesMat = [phase, freq, sigma, img_contrast, aspectRatio, 0, 0, 0]';
        end
        
        function draw(this)
          Screen('DrawTextures', this.window, this.tex, [], [], ...
                this.orientation, [], [], [], [],...
                kPsychDontDoRotation, this.propertiesMat);

        end
        
        function setFadeProperties(this, amplitude, img_contrast, start_phase)
            this.amplitude = amplitude;
            this.img_contrast = img_contrast;
            this.start_phase = start_phase;
        end
        
        function fade(this, freq)
            ang_freq = 2 * pi * freq;
            this.img_contrast = this.amplitude * sin(ang_freq * this.time + this.start_phase) + this.amplitude;
            this.setProperties(this.phase, this.sinusoid_freq, this.sigma, this.img_contrast, this.aspectRatio)
            this.time = this.time + this.ifi;
        end
        
    end
end

