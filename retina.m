classdef retina < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        pigments
        centre
        angle
        vision
    end
    
    methods
        function obj = retina(opt)
            obj.options  = opt;
            pangle  = 2*pi*rand(1,opt.retina_density);
            pradius = -opt.retina_focus * log(rand(1,opt.retina_density));
            obj.pigments = ([pradius;pradius] .* [cos(pangle);sin(pangle)])';
            obj.centre   = [randi(opt.board_size(1)),randi(opt.board_size(2))];
            obj.vision   = zeros(1,opt.retina_density);
        end
    end
end
