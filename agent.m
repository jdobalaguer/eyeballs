classdef agent < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        retina
        reward
    end
    
    methods
        
        %% constructor
        function obj = agent(opt,rtn)
            obj.options = opt;
            obj.retina  = rtn;
            obj.reward  = reward(opt);
        end
        
        %% play methods
        function play(obj)
            
        end
        
        function action(obj)
        end
        
    end
end
