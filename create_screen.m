function [window, scrn_width, scrn_height, glsl]= create_screen(screenNumber)
    AssertOpenGL
    
    % Get the list of screens and choose the one with the highest screen number.
    if nargin < 1
        screenNumber=max(Screen('Screens'));
    end
    
    % Find the color values which correspond to white and black.
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray = round((white+black)/2);
    
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    
    % Open a double buffered fullscreen window with a gray background:
    window =Screen('OpenWindow',screenNumber, black);
    [scrn_width, scrn_height] = Screen('WindowSize', window);
    
    % Enable alpha blending for typical drawing of masked textures:
    AssertGLSL;

    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glsl = MakeTextureDrawShader(window, 'SeparateAlphaChannel');

%     sca;
%     psychrethrow(psychlasterror);
%     return
end

