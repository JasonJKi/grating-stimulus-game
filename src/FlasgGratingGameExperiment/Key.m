classdef Key
    %KEY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        up = KbName('UpArrow');
        down = KbName('DownArrow');
        left = KbName('LeftArrow');
        right = KbName('RightArrow');
        left_numpad = KbName('4');
        right_numpad = KbName('6');

        escape = KbName('ESCAPE');
        space = KbName('SPACE');

        one = KbName('1');
        two = KbName('2');
        three = KbName('3');
        four = KbName('4');

    end
    
    methods
        function obj = Key()
            %KEY Construct an instance of this class
            %   Detailed explanation goes here
        end
       
       
    end
end

