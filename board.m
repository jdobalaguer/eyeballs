classdef board < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        ball
        cartes
        retina
    end
    
    methods
        %% constructor
        function obj = board(opt)
            obj.options = opt;
            obj.ball    = ball(opt);
            obj.cartes  = cartes(opt);
            obj.retina  = retina(opt);
        end
        
        %% play methods
        function obj = play(obj)
            obj.ball.play();
        end
        
        %% view methods
        
        % update perception
        function vision = view(obj)
            vision_retina = obj.view_retina();
            vision_cartes = obj.view_cartes();
            vision = [mat2vec(vision_retina),mat2vec(vision_cartes)];
        end
        
        % update retina perception
        function vision = view_retina(obj)
            vision = zeros(1,obj.options.retina_density);
            for i = 1:obj.options.retina_density
                pigment = obj.retina.centre+obj.retina.pigments(i,:);
                dist2   = obj.ball.dist2_point(pigment);
                % frame
                if any(pigment<[0,0] | pigment>obj.options.board_size)
                    vision(i) = 1;
                % ball
                elseif any(dist2(:) < obj.options.ball_radius*obj.options.ball_radius) % ball
                    vision(i) = 2;
                % background
                else
                    vision(i) = 0;
                end
            end
            obj.retina.vision = vision;
        end
        
        % update cartes perception
        function vision = view_cartes(obj)
            vision  = zeros(obj.options.cartes_nbx,obj.options.cartes_nby);
            x = find(obj.cartes.x - obj.retina.centre(1) >= 0 , 1) - 1;
            y = find(obj.cartes.y - obj.retina.centre(2) >= 0 , 1) - 1;
            x(~x) = 1;
            y(~y) = 1;
            vision(x,y) = 1;
            obj.cartes.vision = vision;
        end
        
        %% update methods
        function reset(obj)
            obj.ball.reset();
            obj.retina.reset();
        end
    end
end


%% auxiliar methods
function y = mat2vec(x)
    y = reshape(x,[1,numel(x)]);
end