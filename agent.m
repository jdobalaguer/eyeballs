classdef agent < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        retina
    end
    
    methods
        
        %% constructor
        function obj = agent(opt,rtn)
            obj.options = opt;
            obj.retina  = rtn;
        end
        
        %% play methods
        function play(obj)
            
        end
        
        function reward(obj,reward)
        end
        
        function action(obj)
        end
        
    end
end
