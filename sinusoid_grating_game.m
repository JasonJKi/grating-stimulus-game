% close all; clear all;
[window, scrn_width, scrn_height, glsl]= create_screen();
window_rect = [0, 0, scrn_width, scrn_height];

f=0.05;
cyclespersecond=1;
orientation = 0;

% Create circular sinusoidal gratings 
tex_size = 400;
grating1 = sinusoidGrating(f, tex_size);
grating_tex_surround = Screen('MakeTexture', window, grating1 , [], [], [], [], glsl);

tex_size_2 = ceil(150);
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
% cntrller.test()
flicker_frequency_fovea = 5;
flicker_frequency_surround = 15;
orientation_2 = 0;
surround_contrast = 1;
i=0;

target_color = [255 255 255];
target_size = [0 0 200 200];
target_hit = false;

obstacle_color = [100 100 100];
obstacle_size = [0 0 200 200];
obstacle_hit = false;
obstacle_2_color = [100 100 100];
obstacle_2_size = [0 0 200 200];
obstacle_2_hit = false;
obstacle_3_color = [100 100 100];
obstacle_3_size = [0 0 200 200];
obstacle_3_hit = false;

new_trial = false;
cntrller = KeyboardGUIController(20, x_center, y_center, scrn_width, scrn_height);
d = 5; pos = tex_size_2-25;

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
    foveal_intensity = sin(t*2*pi*flicker_frequency_fovea)*127+128;
    
    peripheral_intensity = (sin(t*2*pi*flicker_frequency_surround)*127+128)*surround_contrast;

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
    
    if  i == 1 || new_trial == true
        new_pos = create_random_points_with_distance([x_pos y_pos] , scrn_width-200, scrn_height-200, d, 400);
    end
    
    % target hitting logic
    % place box randomly
    if i == 1 || new_trial
        target_pos_x = new_pos(2,1);
        target_pos_y = new_pos(2,2);
        target_rect = CenterRectOnPointd(target_size, target_pos_x, target_pos_y);
        target_hit = false;
        
        obstacle_pos_x = new_pos(3,1);
        obstacle_pos_y = new_pos(3,2);
        obstacle_rect = CenterRectOnPointd(obstacle_size, obstacle_pos_x, obstacle_pos_y);
        obstacle_hit = false;
        
        obstacle_2_pos_x = new_pos(4,1);
        obstacle_2_pos_y = new_pos(4,2);
        obstacle_2_rect = CenterRectOnPointd(obstacle_2_size, obstacle_2_pos_x, obstacle_2_pos_y);
        obstacle_2_hit = false;
        
        obstacle_3_pos_x = new_pos(5,1);
        obstacle_3_pos_y = new_pos(5,2);
        obstacle_3_rect = CenterRectOnPointd(obstacle_3_size, obstacle_3_pos_x, obstacle_3_pos_y);
        obstacle_3_hit = false;
        new_trial = false;
    end
    
    % check that position of keyboard and the target box are close to each
    % other.
    
    if (target_pos_x + pos > x_pos && target_pos_x - pos < x_pos) && (target_pos_y + pos > y_pos && target_pos_y - pos  < y_pos)
        target_hit = true;
        new_trial = true;
    end
    
    if (obstacle_pos_x + pos > x_pos && obstacle_pos_x - pos < x_pos) && (obstacle_pos_y + pos > y_pos && obstacle_pos_y - pos  < y_pos)
        obstacle_hit = true;
        new_trial = true;
    end
    
    % check that position of keyboard and the target box are close to each
    % other.
    if (obstacle_2_pos_x + pos > x_pos && obstacle_2_pos_x - pos < x_pos) && (obstacle_2_pos_y + pos > y_pos && obstacle_2_pos_y - pos  < y_pos)
        obstacle_2_hit = true;
        new_trial = true;
    end
    
    if (obstacle_3_pos_x + pos > x_pos && obstacle_3_pos_x - pos < x_pos) && (obstacle_3_pos_y + pos > y_pos && obstacle_3_pos_y - pos  < y_pos)
        obstacle_3_hit = true;
        new_trial = true;
    end

    % Draw first grating texture, rotated by "orientation":
    Screen('DrawTexture', window, grating_tex_surround, src_rect, dest_rect, orientation, [], [], peripheral_intensity, [], [], [0, yoffset, 0, 0]);
    Screen('DrawTexture', window, grating_tex_center, src_rect_2, dest_rect_2, orientation_2, [], [], foveal_intensity, [], [], [0, yoffset, 0, 0]);
    Screen('FillRect', window, target_color, target_rect);
    Screen('FillRect', window, obstacle_color, obstacle_rect);
    Screen('FillRect', window, obstacle_2_color, obstacle_2_rect);
    Screen('FillRect', window, obstacle_3_color, obstacle_3_rect);

    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    

end

% The same commands wich close onscreen and offscreen windows also close textures.
sca;

