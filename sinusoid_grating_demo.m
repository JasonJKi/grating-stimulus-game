close all; clear all;
[window, scrn_width, scrn_height, glsl]= create_screen();
window_rect = [0, 0, scrn_width, scrn_height];

f=0.05;
cyclespersecond=1;
orientation = 0;

% Create circular sinusoidal gratings 
tex_size = 300;
grating1 = sinusoidGrating(f, tex_size);
grating_tex_surround = Screen('MakeTexture', window, grating1 , [], [], [], [], glsl);

tex_size_2 = ceil(tex_size/3);
grating2 = sinusoidGrating(f, tex_size_2);
grating_tex_center = Screen('MakeTexture', window, grating2, [], [], [], [], glsl);

% Definition of the drawn source rectorientation on the screen:
visibletex_size=2*tex_size+1;
src_rect=[0 0 visibletex_size visibletex_size];

visible2tex_size = 2*tex_size_2+1;
% Definition of the drawn source rectorientation on the screen:
src_rect_2=[0 0 visible2tex_size visible2tex_size];

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

% Animation loop: Run until timeout or keypress.
[x_center, y_center] = RectCenter(window_rect);

KbName('UnifyKeyNames');
cntrller = KeyboardGUIController(20, x_center, y_center, scrn_width, scrn_height);
% cntrller.test()
flicker_frequency = 3;
orientation_2 = 0;
surround_contrast = .5;
i=0;

rect_color = [1 0 0];
baseRect = [0 0 200 200];
target_reached = false;
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
    dest_rect = CenterRectOnPointd(src_rect, x_pos, y_pos);
    dest_rect_2 = CenterRectOnPointd(src_rect_2, x_pos, y_pos);


    if cntrller.flipped()

        if orientation == 0
            orientation = orientation_2 + 90;
        else
            orientation = 0;
        end
%         flip_delay = flip_delay + 1;
    end
    
    % place box randomly
    if i == 1 || target_reached
        rand_pos_x = randi([0 scrn_width-200],1,1);
        rand_pos_y = randi([0 scrn_height-200],1,1);
        rect = CenterRectOnPointd(baseRect, rand_pos_x, rand_pos_y);
        target_reached = false;
    end
    
    pos = 150;
    % check that position of keyboard and 
    if (rand_pos_x + pos > x_pos && rand_pos_x - pos < x_pos) && (rand_pos_y + pos > y_pos && rand_pos_y - pos  < y_pos)
        target_reached = true;
    end 
    
    
    % Draw first grating texture, rotated by "orientation":
    Screen('DrawTexture', window, grating_tex_surround, src_rect, dest_rect, orientation, [], [], foveal_intensity*surround_contrast, [], [], [0, yoffset, 0, 0]);
    
    % Draw 2nd grating texture, rotated by "orientation+45":
    Screen('DrawTexture', window, grating_tex_center, src_rect_2, dest_rect_2, orientation_2, [], [], foveal_intensity, [], [], [0, yoffset, 0, 0]);
    
    Screen('FillRect', window, rect_color, rect);

    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flipr', window, vbl + (waitframes - 0.5) * ifi);
    

end

% The same commands wich close onscreen and offscreen windows also close textures.
sca;

