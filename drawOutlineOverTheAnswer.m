function is_correct = drawOutlineOverTheAnswer(answer, correct_answer, x_lim, y_lim, win)
color_correct = [100 255 100];
color_incorrect = [255 100 100];
is_correct = 0;
if answer == correct_answer
    is_correct = 1;
end

draw_index = correct_answer;
x_pos = mean(x_lim(draw_index,:));
y_pos = mean(y_lim(draw_index,:));
size = [0 0 abs(diff(x_lim(draw_index,:))+50) abs(diff(y_lim(draw_index,:)))];

rect_pos = CenterRectOnPointd(size, x_pos, y_pos);

if is_correct
    message_str = 'Correct';
    color = [100 255 100];
else
    message_str = 'In Correct';
    color = [255 100 100];
end
Screen('FrameRect', win, color, rect_pos, 10);
Screen('TextSize', win, 40);
Screen('TextFont', win, 'Courier');
DrawFormattedText(win, message_str, 'Center', 1080-200, color);
Screen('Flip', win, [], 1)

end
