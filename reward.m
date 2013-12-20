classdef reward < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
    end
    
    methods
        
        %% constructor
        function obj = reward(opt)
            obj.options = opt;
        end
        
        %% get reward
        function r = get(obj,vision)
            r = sum(vision) / obj.options.retina_density;
        end
    end
end
