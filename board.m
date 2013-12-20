classdef board < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        ball
        retina
    end
    
    methods
        function obj = board(opt)
            obj.options = opt;
            obj.ball    = ball(opt);
            obj.retina  = retina(opt);
        end
        
        function obj = play(obj)
            obj.ball.play();
        end
        
        function view(obj)
            vision = zeros(1,obj.options.retina_density);
            for i = 1:obj.options.retina_density
                pigment = obj.retina.centre+obj.retina.pigments(i,:);
                dist2   = obj.ball.dist2_point(pigment);
                if any(dist2(:) < obj.options.ball_radius*obj.options.ball_radius)
                    vision(i) = 1;
                end
            end
            obj.retina.vision = vision;
        end
    end
end
