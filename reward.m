classdef reward < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        board
    end
    
    methods
        function obj = reward(opt,brd)
            obj.options = opt;
            obj.board   = brd;
        end
    end
end
