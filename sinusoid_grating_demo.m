% Grating cycles/pixel
f=0.05;

% Speed of grating in cycles per second:
cyclespersecond=1;

% orientation of the grating: We default to 30 degrees.
orientation=0;

movieDurationSecs=60; % Abort demo after 60 seconds.
textex_size=300; % Half-tex_size of the grating image.
% 
% AssertOpenGL;

% Get the list of screens and choose the one with the highest screen number.
screenNumber=max(Screen('Screens'));

% Find the color values which correspond to white and black.
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);

% Round gray to integral number, to avoid roundoff artifacts with some
% graphics cards:
gray=round((white+black)/2);

% This makes sure that on floating point framebuffers we still get a
% well defined gray. It isn't strictly neccessary in this demo:
if gray == white
    gray=white / 2;
end
inc=white-gray;

% Open a double buffered fullscreen window with a gray background:
window =Screen('OpenWindow',screenNumber, black);
[scrn_width, scrn_height] = Screen('WindowSize', window);
window_rect = [0, 0, scrn_width, scrn_height];
% Make sure this GPU supports shading at all:
AssertGLSL;

% Enable alpha blending for typical drawing of masked textures:
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Create a special texture drawing shader for masked texture drawing:
glsl = MakeTextureDrawShader(window, 'SeparateAlphaChannel');

f=0.05;

% Calculate parameters of the grating:

tex_size = 300;
grating1 = sinusoidGrating(f, tex_size);
gratingtex1 = Screen('MakeTexture', window, grating1 , [], [], [], [],0);

tex_size_2 = ceil(tex_size/3);
grating2 = sinusoidGrating(f, tex_size_2);
gratingtex2 = Screen('MakeTexture', window, grating2, [], [], [], [], 0);

% Definition of the drawn source rectorientation on the screen:
visibletex_size=2*tex_size+1;
srcRect=[0 0 visibletex_size visibletex_size];

visible2tex_size = 2*tex_size_2+1;
% Definition of the drawn source rectorientation on the screen:
src2Rect=[0 0 visible2tex_size visible2tex_size];

% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', window);

waitframes = 1;
waitduration = waitframes * ifi;

% Recompute p, this time without the ceil() operation from above.
% Otherwise we will get wrong drift speed due to rounding!
p = 1/f; % pixels/cycle

% Translate requested speed of the gratings (in cycles per second) into
% a shift value in "pixels per frame", assuming given waitduration:
shiftperframe = cyclespersecond * p * waitduration;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl = Screen('Flip', window);

% We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
vblendtime = vbl + movieDurationSecs;
i=0;

% Animation loop: Run until timeout or keypress.
[x_center, y_center] = RectCenter(window_rect);

cntrller = KeyboardGUIController(10, x_center, y_center, scrn_width, scrn_height);

flicker_frequency = 3;
orientation_2 = 0;
while cntrller.update()
    
    % Shift the grating by "shiftperframe" pixels per frame. We pass
    % the pixel offset 'yoffset' as a parameter to
    % Screen('DrawTexture'). The attached 'glsl' texture draw shader
    % will apply this 'yoffset' pixel shift to the RGB or Luminance
    % color channels of the texture during drawing, thereby shifting
    % the gratings. Before drawing the shifted grating, it will mask it
    % with the "unshifted" alpha mask values inside the Alpha channel:
    yoffset = mod(i*shiftperframe, p);
    i=i+1;
    t = GetSecs;
        
    foveal_intensity = sin(t*2*pi*flicker_frequency)*127+128;
    
    x_pos = cntrller.x_pos;
    y_pos = cntrller.y_pos;
    destRect = CenterRectOnPointd(srcRect, x_pos, y_pos);
    dest2Rect = CenterRectOnPointd(src2Rect, x_pos, y_pos);

    if cntrller.flipped()
        if orientation_2 == 0
            orientation_2 = orientation + 90;
        else
            orientation_2 = 0;
        end
    end
    % Draw first grating texture, rotated by "orientation":
    Screen('DrawTexture', window, gratingtex1, srcRect, destRect, orientation_2, [], [], [], [], [], [0, yoffset, 0, 0]);
    
    % Draw 2nd grating texture, rotated by "orientation+45":
    Screen('DrawTexture', window, gratingtex2, src2Rect, dest2Rect, orientation, [], [], foveal_intensity, [], [], [0, yoffset, 0, 0]);
    
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
end

% The same commands wich close onscreen and offscreen windows also close textures.
sca;

