classdef ball < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        centre
        angle
        speed
    end
    
    methods
        %% constructor
        function obj = ball(opt)
            % options
            obj.options = opt;
            % centre of balls (no overlapping)
            ds = 0;
            while any(ds(:)<power(2*opt.ball_radius,2))
                obj.centre(:,1) = opt.ball_radius + rand(1,opt.ball_number) * (opt.board_size(1) - 2*opt.ball_radius);
                obj.centre(:,2) = opt.ball_radius + rand(1,opt.ball_number) * (opt.board_size(2) - 2*opt.ball_radius);
                x = obj.centre(:,1) * ones(1,opt.ball_number);
                dx = power(x-x',2);
                y = obj.centre(:,2) * ones(1,opt.ball_number);
                dy = power(y-y',2);
                ds = dx + dy;
                ds(power(1:opt.ball_number,2)) = Inf;
            end
            % angle and speed
            obj.angle       = 2 * pi * rand(1,opt.ball_number);
            obj.speed(1:opt.ball_number) = opt.ball_speed;
        end
        
        %% methods
        function move(obj)
            for i = 1:obj.options.ball_number
                movement = obj.speed(i) * [cos(obj.angle(i)),sin(obj.angle(i))];
                obj.centre(i,:) = obj.centre(i,:) + movement;
            end
            obj.speed = obj.speed .* obj.options.ball_acceleration;
        end
        
        function collision(obj)
            % collision entre billes (choc elastique)
            for k = j+1 : nb_agents
                dist = (xyn(j,1)-xyn(k,1))*(xyn(j,1)-xyn(k,1)) + (xyn(j,2)-xyn(k,2))*(xyn(j,2)-xyn(k,2));
                if dist < 4*rayon*rayon
                    nx = (xy(k,1)-xy(j,1))/(2*rayon);
                    ny = (xy(k,2)-xy(j,2))/(2*rayon);
                    gx = -ny;
                    gy = nx;
                    v1n = nx*dxdy(j,1) + ny*dxdy(j,2);
                    v1g = gx*dxdy(j,1) + gy*dxdy(j,2);
                    v2n = nx*dxdy(k,1) + ny*dxdy(k,2);
                    v2g = gx*dxdy(k,1) + gy*dxdy(k,2);

                    dxdy(j,:) = [nx*v2n+gx*v1g , ny*v2n+gy*v1g];
                    dt(j) = atan(dxdy(j,2)/dxdy(j,1));
                    if dxdy(j,1)<0    dt(j)=dt(j)+pi;    end
                    dxdy(j,:) = vitesse*[cos(dt(j)), sin(dt(j))];
                    xyn(j,:) = xy(j,:) + dxdy(j,:);

                    dxdy(k,:) = [nx*v1n+gx*v2g , ny*v1n+gy*v2g];
                    dt(k) = atan(dxdy(k,2)/dxdy(k,1));
                    if dxdy(k,1)<0    dt(k)=dt(k)+pi;    end
                    dxdy(k,:) = vitesse*[cos(dt(k)), sin(dt(k))];
                    xyn(k,:) = xy(k,:) + dxdy(k,:);

                    collisions_du_frame = [collisions_du_frame j];
                    collisions_du_frame = [collisions_du_frame k];
                end
            end
            % lateraux de la scene (reflexion)
            if xyn(j,1)>=rect(3)-rayon || xyn(j,1)<=rect(1)+rayon
                dt(j) = pi-dt(j);
                dxdy(j,:) = vitesse*[cos(dt(j)), sin(dt(j))];
                xyn(j,:) = xy(j,:) + dxdy(j,:);
            end
            % le haut/bas de la scene (reflexion)
            if xyn(j,2)>=rect(4)-rayon || xyn(j,2)<=rect(2)+rayon
                dt(j) = -dt(j);
                dxdy(j,:) = vitesse*[cos(dt(j)), sin(dt(j))];
                xyn(j,:) = xy(j,:) + dxdy(j,:);
            end
        end
    end
end
