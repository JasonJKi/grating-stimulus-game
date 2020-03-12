function is_correct = echoAnswer(response, answer, win)

is_correct = 0;
if response == answer
    is_correct = 1;
end

if is_correct
    message_str = ['Correct: ' num2str(answer)];
    color = [100 255 100];
else
    message_str = ['In Correct:' num2str(answer)];
    color = [255 100 100];
end

% Screen('FrameRect', win, color, rect_pos, 10);
Screen('TextSize', win, 40);
Screen('TextFont', win, 'Courier');
DrawFormattedText(win, message_str, 'Center', 'Center', color);
Screen('Flip', win, 1, 1)
end
