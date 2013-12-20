classdef retina < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        apigments
        rpigments
        hpigments
        vpigments
        centre
    end
    
    methods
        function obj = retina(opt)
            obj.options  = opt;
            obj.apigments = 2*pi*rand(1,opt.retina_density);
            obj.rpigments = -opt.retina_focus * log(rand(1,opt.retina_density));
            obj.hpigments = obj.rpigments .* cos(obj.apigments);
            obj.vpigments = obj.rpigments .* sin(obj.apigments);
            obj.centre(1) = randi(opt.board_size(1));
            obj.centre(2) = randi(opt.board_size(2));
        end
    end
end
