classdef board < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        ball
        retina
        reward
    end
    
    methods
        function obj = board(opt)
            obj.options = opt;
            obj.ball    = ball(opt);
            obj.retina = retina(opt);
            obj.reward = reward(opt,obj);
        end
        
        function obj = play(obj)
            obj.ball.move();
        end
    end
end
