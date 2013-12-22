classdef cartes < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        x
        y
        vision
    end
    
    methods
        %% constructor
        function obj = cartes(opt)
            obj.options = opt;
            obj.x       = linspace(0,opt.board_size(1),opt.cartes_nbx+1);
            obj.y       = linspace(0,opt.board_size(2),opt.cartes_nby+1);
            obj.vision  = zeros(opt.cartes_nbx,opt.cartes_nby);
        end
    end
end
