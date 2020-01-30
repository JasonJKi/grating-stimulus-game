close all;
clearvars;

% Get the screen numbers
AssertOpenGL;

screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray=round((white+black)/2);
KbWait
inc=white-gray;
[window screenRect]=Screen('OpenWindow',screenNumber, gray);

f=0.05; % Grating cycles/pixel
cyclespersecond=1;% Speed of grating in cycles per second:
orientation=0;% orientation of the grating: We default to 0 degrees.
texsize=300; % Half-Size of the grating image.
p=ceil(1/f); % pixels/cycle, rounded up.
fr=f*2*pi;
visiblesize=2*texsize+1;
visible2size=visiblesize/2;

[x, y]=meshgrid(-texsize:texsize + p, 1);
grating=gray + inc*cos(fr*x);
gratingtex=Screen('MakeTexture', window, grating);
dstRect=[0 0 visiblesize visiblesize];

freq = 5
img_contrast = .0
aspectRatio = 1.0;
phase = 0;
orientation = 0;
numCycles = 5;
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
sigma = 1000
preContrastMultiplier = 0.5;
ang_freq = 2 * pi * img_contrast;;
propertiesMat = [phase, freq, sigma, img_contrast, aspectRatio, 0, 0, 0]';

Screen('DrawTexture', window, gratingtex, ...
    srcRect, dstRect, orientation);
vbl=Screen('Flip', window);

[x2,y2]=meshgrid(-texsize/2:texsize/2 + p, 1);
m=cos(fr*x2);
grating2=gray + inc*m;

grating2tex=Screen('MakeTexture', window, grating2);

Screen('DrawTexture', window, gratingtex);
% Screen('Flip', window);

% Create a single  binary transparency mask and store it to a texture:
mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
[x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
mask(:, :, 2) = white * (1-(x.^2 + y.^2 <= texsize^2));
masktex=Screen('MakeTexture', window, mask);

% Definition of the drawn rectangle on the screen:
dstRect=[0 0 visiblesize visiblesize];
dstRect=CenterRect(dstRect, screenRect);

% Definition of the drawn rectangle on the screen:
dst2Rect=[0 0 visible2size visible2size];
dst2Rect=CenterRect(dst2Rect, screenRect);

% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', window);

waitframes = 1;
waitduration = waitframes * ifi;

% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding!
p=1/f; % pixels/cycle

% Translate requested speed of the grating (in cycles per second)
% into a shift value in "pixels per frame", assuming given
% waitduration: This is the amount of pixels to shift our "aperture" at
% each redraw:
shiftperframe= cyclespersecond * p * waitduration;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:

% We run at most 'movieDurationSecs' seconds if user doesn't abort via
% keypress.
i=0;

% Animationloop:
while 1%(vbl < vblendtime) && ~KbCheck
    
    % Shift the grating by "shiftperframe" pixels per frame:
    xoffset = mod(i*shiftperframe,p);
    i=i+1;
    
    % Define shifted srcRect that cuts out the properly shifted rectangular
    % area from the texture:
    srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
    src2Rect=[xoffset 0 xoffset + visible2size visible2size];
    disp(xoffset)
    
    % Draw grating texture, rotated by "orientation":
    Screen('DrawTexture', window, gratingtexkfjfj
    
    s, ...
        [0 0 visiblesize visiblesize], dstRect, orientation, ...
        [], [], [], [],...
        kPsychDontDoRotation, propertiesMat);
    

    if drawmask==1
        % Draw aperture over grating:
        Screen('DrawTexture', window, masktex, [0 0 visiblesize visiblesize], dstRect, orientation);
    end
    
    % Disable alpha-blending, restrict following drawing to alpha channel:
    Screen('Blendfunction', window, GL_ONE, GL_ZERO, [0 0 0 1]);
    
    % Clear 'dstRect' region of framebuffers alpha channel to zero:
    Screen('FillRect', window, [0 0 0 0], dst2Rect);
    
    % Fill circular 'dstRect' region with an alpha value of 255:
    Screen('FillOval', window, [0 0 0 255], dst2Rect);
    
    % Enable DeSTination alpha blending and reenable drawing to all
    % color channels. Following drawing commands will only draw there
    % the alpha value in the framebuffer is greater than zero, ie., in
    % our case, inside the circular 'dst2Rect' aperture where alpha has
    % been set to 255 by our 'FillOval' command:
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
    
    % Draw 2nd grating texture, but only inside alpha == 255 circular
    % aperture, and at an orientation of 90 degrees:
    Screen('DrawTexture', window, grating2tex, src2Rect, dst2Rect, 0);
    
    % Restore alpha blending mode for next draw iteration:
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end;

Priority(0);
sca;

DriftDemo7()
ContrastModulatedNoiseTheElegantStyleDemo
