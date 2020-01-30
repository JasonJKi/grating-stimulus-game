close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

[window, windowRect] = PsychImaging('OpenWindow', 1, black);
[scrn_width, scrn_height] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% This is the cue which determines whether we exit the demo
is_exit = false;
gabor_size = [scrn_width scrn_height];
gabor_tex = GaborTex(window);
gabor_tex.setTexSize(scrn_width, scrn_height)

gabor_tex.create()

gabor_tex.draw()
Screen('Flip', window);

step = 10;
rect_color = [1 0 0];
baseRect = [0 0 200 200];
[x_center, y_center] = RectCenter(windowRect);
guiController = KeyboardGUIController(step, x_center, y_center, scrn_width, scrn_height);
% Loop the animation until the escape key is pressed
while guiController.update()
    x_pos = guiController.x_pos;
    y_pos = guiController.y_pos;
    
    % DriftDemo5()
    % Center the rectangle on the centre of the screen
    rect = CenterRectOnPointd(baseRect, x_pos, y_pos);
    gabor_tex.fade(5)
    gabor_tex.draw()

    % Draw the rect to the screen
    Screen('FillRect', window, rect_color, baseRect);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end
 gratingsize = 360;
res = [gratingsize gratingsize];
gratingtex = CreateProceduralSineGrating(window, res(1), res(2), [0.5 0.5 0.5 0.0]);
% Clear the screen
sca;