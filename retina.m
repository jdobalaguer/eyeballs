classdef retina < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        pigments
        centre
        angle
        vision
    end
    
    methods
        %% constructor
        function obj = retina(opt)
            obj.options  = opt;
            obj.reset();
        end
        
        %% update methdos
        function reset(obj)
            pangle  = 2*pi*rand(1,obj.options.retina_density);
            pradius = -obj.options.retina_focus * log(rand(1,obj.options.retina_density));
            obj.pigments = ([pradius;pradius] .* [cos(pangle);sin(pangle)])';
            obj.centre   = [randi(obj.options.board_size(1)),randi(obj.options.board_size(2))];
            obj.vision   = zeros(1,obj.options.retina_density);
        end
        
    end
end
