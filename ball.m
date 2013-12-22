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
            obj.reset();
        end
        
        %% update methods
        function reset(obj)
            % centre of balls (no overlapping)
            if obj.options.ball_number
                ds = -1;
                obj.centre = nan(obj.options.ball_number,2);
                while any(ds(:) < 4*obj.options.ball_radius*obj.options.ball_radius)
                    obj.centre(:,1) = obj.options.ball_radius + rand(1,obj.options.ball_number) * (obj.options.board_size(1) - 2*obj.options.ball_radius);
                    obj.centre(:,2) = obj.options.ball_radius + rand(1,obj.options.ball_number) * (obj.options.board_size(2) - 2*obj.options.ball_radius);
                    ds = obj.dist2_balls();
                    ds(~ds) = Inf;
                end
                % angle and speed
                obj.angle = 2 * pi * rand(1,obj.options.ball_number);
                obj.speed = obj.options.ball_speed * rand(1,obj.options.ball_number);
            else
                obj.centre = zeros(0,2);
                obj.angle  = zeros(1,0);
                obj.speed  = zeros(1,0);
            end
        end
        
        %% distance methods
        
        % distance between balls
        function ds = dist2_balls(obj)
            x = obj.centre(:,1) * ones(1,obj.options.ball_number);
            dx = power(x-x',2);
            y = obj.centre(:,2) * ones(1,obj.options.ball_number);
            dy = power(y-y',2);
            ds = dx + dy;
        end
        
        % distance to balls
        function ds = dist2_point(obj,point)
            x = obj.centre(:,1);
            dx = power(x-point(1),2);
            y = obj.centre(:,2);
            dy = power(y-point(2),2);
            ds = dx + dy;
        end
        
        %% play methods
        
        % move balls one step
        function play(obj)
            dcentre = ([obj.speed;obj.speed] .* [cos(obj.angle);sin(obj.angle)])';
            new_centre = obj.centre + dcentre;
            collisions = [];
            for i = 1 : obj.options.ball_number
                [new_centre,dcentre,collisions] = obj.collision(i,dcentre,new_centre,collisions);
                [new_centre,dcentre]            = obj.bottombound(i,dcentre,new_centre);
                [new_centre,dcentre]            = obj.leftbound(i,dcentre,new_centre);
                [new_centre,dcentre]            = obj.topbound(i,dcentre,new_centre);
                [new_centre,dcentre]            = obj.rightbound(i,dcentre,new_centre);
            end
            obj.centre = new_centre;
            obj.speed  = obj.speed .* obj.options.ball_acceleration;
        end
        
        % correct for collisions
        function [new_centre,dcentre,collisions] = collision(obj,i,dcentre,new_centre,collisions)
            for j = (i+1):obj.options.ball_number
                dist    = (obj.centre(i,1)-obj.centre(j,1))*(obj.centre(i,1)-obj.centre(j,1)) + (obj.centre(i,2)-obj.centre(j,2))*(obj.centre(i,2)-obj.centre(j,2));
                newdist = (new_centre(i,1)-new_centre(j,1))*(new_centre(i,1)-new_centre(j,1)) + (new_centre(i,2)-new_centre(j,2))*(new_centre(i,2)-new_centre(j,2));
                if (    newdist < 4*obj.options.ball_radius*obj.options.ball_radius && ...
                        newdist < dist )
                        
                    obj.speed(i) = obj.options.ball_speed;
                    obj.speed(j) = obj.options.ball_speed;

                    nx = (obj.centre(j,1)-obj.centre(i,1))/(2*obj.options.ball_radius);
                    ny = (obj.centre(j,2)-obj.centre(i,2))/(2*obj.options.ball_radius);
                    gx = -ny;
                    gy = nx;
                    v1n = nx*dcentre(i,1) + ny*dcentre(i,2);
                    v1g = gx*dcentre(i,1) + gy*dcentre(i,2);
                    v2n = nx*dcentre(j,1) + ny*dcentre(j,2);
                    v2g = gx*dcentre(j,1) + gy*dcentre(j,2);

                    dcentre(i,:) = [nx*v2n+gx*v1g , ny*v2n+gy*v1g];
                    obj.speed(i) = atan(dcentre(i,2)/dcentre(i,1));
                    if dcentre(i,1)<0; obj.angle(i) = mod(obj.angle(i)+pi,2*pi); end
                    dcentre(i,:) = obj.speed(i)*[cos(obj.angle(i)), sin(obj.angle(i))];
                    new_centre(i,:) = obj.centre(i,:) + dcentre(i,:);

                    dcentre(j,:) = [nx*v1n+gx*v2g , ny*v1n+gy*v2g];
                    obj.angle(j) = mod(atan(dcentre(j,2)/dcentre(j,1)),2*pi);
                    if dcentre(j,1)<0; obj.angle(j) = mod(obj.angle(j)+pi,2*pi); end
                    dcentre(j,:) = obj.speed(j)*[cos(obj.angle(j)), sin(obj.angle(j))];
                    new_centre(j,:) = obj.centre(j,:) + dcentre(j,:);

                    collisions = [collisions i];
                    collisions = [collisions j];
                    
                    obj.speed(i) = obj.options.ball_speed;
                    obj.speed(j) = obj.options.ball_speed;
                end
            end
        end
        
        % correct for bottom bound
        function [new_centre,dcentre] = bottombound(obj,i,dcentre,new_centre)
            if ( new_centre(i,2) >= obj.options.board_size(2)-obj.options.ball_radius && ...
                 numinrange(obj.angle(i),pi*[0,1]))
                obj.angle(i) = mod(-obj.angle(i),2*pi);
                dcentre(i,:) = obj.speed(i)*[cos(obj.angle(i)), sin(obj.angle(i))];
                new_centre(i,:) = obj.centre(i,:) + dcentre(i,:);
                obj.speed(i) = obj.options.ball_speed;
            end
        end
        
        % correct for left bound
        function [new_centre,dcentre] = leftbound(obj,i,dcentre,new_centre)
            if ( new_centre(i,1) <= obj.options.ball_radius && ...
                 numinrange(obj.angle(i),pi*[0.5,1.5]))
                obj.angle(i) = mod(pi-obj.angle(i),2*pi);
                dcentre(i,:) = obj.speed(i)*[cos(obj.angle(i)), sin(obj.angle(i))];
                new_centre(i,:) = obj.centre(i,:) + dcentre(i,:);
                obj.speed(i) = obj.options.ball_speed;
            end
        end
        
        % correct for top bound
        function [new_centre,dcentre] = topbound(obj,i,dcentre,new_centre)
            if ( new_centre(i,2) <= obj.options.ball_radius && ...
                 numinrange(obj.angle(i),pi*[1,2]))
                obj.angle(i) = mod(-obj.angle(i),2*pi);
                dcentre(i,:) = obj.speed(i)*[cos(obj.angle(i)), sin(obj.angle(i))];
                new_centre(i,:) = obj.centre(i,:) + dcentre(i,:);
                obj.speed(i) = obj.options.ball_speed;
            end
        end
        
        % correct for rigth bound
        function [new_centre,dcentre] = rightbound(obj,i,dcentre,new_centre)
            if ( new_centre(i,1) >= obj.options.board_size(1)-obj.options.ball_radius && ...
                 (numinrange(obj.angle(i),pi*[1.5,2]) || numinrange(obj.angle(i),pi*[0,0.5])))
                obj.angle(i) = mod(pi-obj.angle(i),2*pi);
                dcentre(i,:) = obj.speed(i)*[cos(obj.angle(i)), sin(obj.angle(i))];
                new_centre(i,:) = obj.centre(i,:) + dcentre(i,:);
                obj.speed(i) = obj.options.ball_speed;
            end
        end
        
    end
end

%% auxiliar

function ret = numinrange(n,ab)
    a = ab(1);
    b = ab(2);
    ret = (n>=a && n<=b);
end
