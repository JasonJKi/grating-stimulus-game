classdef Key
    %KEY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        up = KbName('UpArrow');
        down = KbName('DownArrow');
        left = KbName('LeftArrow');
        right = KbName('RightArrow');   
        escape = KbName('ESCAPE');
        space = KbName('Space');

    end
    
    methods
        function obj = Key()
            %KEY Construct an instance of this class
            %   Detailed explanation goes here
        end
       
       
    end
end

