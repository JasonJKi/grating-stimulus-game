function writePTBMessage(text, duration, window)

vbl = Screen('Flip', window);
ifi = Screen('GetFlipInterval', window);

duration = vbl + duration;
is_escape = false;
while vbl < duration && ~is_escape
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        is_escape = true;
        sca
        error('pressed escape')
    end
    Screen('TextSize', window, 40);
    Screen('TextFont', window, 'Courier');
    DrawFormattedText(window, text, 'center', 'center', [255 255 255])
    vbl = Screen('Flip', window, vbl + (1 - 0.5) * ifi);
end

Screen('Flip', window)