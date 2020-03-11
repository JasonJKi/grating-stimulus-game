function typeOnScreen(window,pos_x,pos_y)




while true
    if useKbCheck
        char = GetKbChar(varargin{:});
    else
        char = GetChar;
    end

    if isempty(char)
        string = '';
        terminatorChar = 0;
        break;
    end

    switch abs(char)
        case {13, 3, 10, 27}
            % ctrl-C, enter, return, or escape
            terminatorChar = abs(char);
            break;
        case 8
            % backspace
            if ~isempty(string)
                % Redraw text string, but with textColor == bgColor, so
                % that the old string gets completely erased:
                oldTextColor = Screen('TextColor', windowPtr);
                Screen('DrawText', windowPtr, double(output), x, y, bgColor, bgColor);
                Screen('TextColor', windowPtr, oldTextColor);

                % Remove last character from string:
                string = string(1:length(string)-1);
            end
        otherwise
            string = [string, char]; %#ok<AGROW>
    end

    output = [msg, ' ', string];
    Screen('DrawText', windowPtr, double(output), x, y, textColor, bgColor);
    Screen('Flip', windowPtr, 0, 1);
end

end