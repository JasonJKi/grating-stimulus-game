while true
    char = '1';
%     if 1
%         char = GetKbChar(varargin{:});
%     else
%         char = GetChar;
%     end
    if isempty(char)
        string = '';
        break;
    end
    switch (abs(char))
        case {13, 3, 10}
            % ctrl-C, enter, or return
            break;
        case 8
            % backspace
            if ~isempty(string)
                % Remove last character from string:
                string = string(1:length(string)-1);
            end
        otherwise
            string = [string, char];
    end

    output = [msg, ' ', string];
    output=WrapString(output,maxNumChar);
    DrawFormattedText(windowPtr,output,x,y,textColor,[],0,0,1);
    Screen('Flip',windowPtr);
end