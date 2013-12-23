classdef cinema < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        board
        ptb_screens
        ptb_screen
        ptb_window
        ptb_rect
    end
    
    methods
        %% constructor
        function obj = cinema(opt,brd)
            obj.options = opt;
            obj.board   = brd;
        end
        
        %% start/stop methods
        function start(obj)
            if ~obj.options.cinema_display; return; end
            Screen('Preference', 'Verbosity',0);
            Screen('Preference', 'SuppressAllWarnings', 1);
            Screen('Preference', 'SkipSyncTests', 2);
            obj.ptb_rect = obj.options.cinema_rect;
            obj.ptb_screens = Screen('Screens');
            obj.ptb_screen  = obj.ptb_screens(end);
            obj.ptb_window  = Screen('OpenWindow',obj.ptb_screen,0,obj.ptb_rect,32,2);
            Screen('BlendFunction',obj.ptb_window,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        end
        
        function stop(obj)
            if ~obj.options.cinema_display; return; end
            Screen('Close',obj.ptb_screen);
        end
        
        %% screen methods
        function background(obj)
            if ~obj.options.cinema_display; return; end
            colour = [128,128,128];
            Screen('FillRect',obj.ptb_window,colour,obj.ptb_rect);
        end
        
        function flip(obj)
            if ~obj.options.cinema_display; return; end
            Screen('Flip',obj.ptb_window);
        end
        
        %% draw methods
        function draw_board(obj)
            if ~obj.options.cinema_display; return; end
            obj.background();
            obj.draw_frame();
            obj.draw_ball();
            obj.draw_cartes();
            obj.draw_retinapigments();
            obj.draw_retinaradius();
            obj.draw_retinacross();
            obj.flip();
        end
        
        % draw frame
        function draw_frame(obj)
            if ~obj.options.cinema_display; return; end
            if ~obj.options.cinema_board; return; end
            marge = obj.options.cinema_marge;
            rect  = obj.options.cinema_rect;
            frame = [marge,marge,rect(3)-rect(1)-marge,rect(4)-rect(2)-marge];
            colour = [0,0,0];
            penwidth = 2;
            Screen('FrameRect',obj.ptb_window,colour,frame,penwidth);
        end
        
        % draw balls
        function draw_ball(obj)
            if ~obj.options.cinema_display; return; end
            if ~obj.options.cinema_ball; return; end
            for i = 1:obj.options.ball_number
                board_frame   = [0,0,obj.options.board_size];
                board_centre  = obj.board.ball.centre(i,:);
                board_radius  = obj.options.ball_radius;
                board_rect    = [board_centre(1)-board_radius,board_centre(2)-board_radius,board_centre(1)+board_radius,board_centre(2)+board_radius];
                cinema_frame  = obj.options.cinema_frame;
                cinema_rect   = rescale_rect(board_rect,board_frame,cinema_frame);
                colour = [192,192,192];
                Screen('FillOval',obj.ptb_window,colour,cinema_rect);
            end
        end
        
        % draw cartes
        function draw_cartes(obj)
            if ~obj.options.cinema_display; return; end
            if ~obj.options.cinema_cartes; return; end
            board_frame  = [0,0,obj.options.board_size];
            cinema_frame = obj.options.cinema_frame;
            greencolour  = [64,255,64,128];
            blackcolour  = [0,0,0]; 
            penwidth     = 2;
            % rectangle x
            i            = find(any(obj.board.cartes.vision,2));
            board_rect   = [obj.board.cartes.x(i),0,obj.board.cartes.x(i+1),obj.options.board_size(2)];
            cinema_rect  = rescale_rect(board_rect,board_frame,cinema_frame);
            Screen('FillRect',obj.ptb_window,greencolour,cinema_rect,penwidth);
            % rectangle y
            i            = find(any(obj.board.cartes.vision,1));
            board_rect   = [0,obj.board.cartes.y(i),obj.options.board_size(1),obj.board.cartes.y(i+1)];
            cinema_rect  = rescale_rect(board_rect,board_frame,cinema_frame);
            Screen('FillRect',obj.ptb_window,greencolour,cinema_rect,penwidth);
            % x lines
            for i = 1:(obj.options.cartes_nbx+1)
                board_line  = [obj.board.cartes.x(i),0,obj.board.cartes.x(i),obj.options.board_size(2)];
                cinema_line = rescale_rect(board_line,board_frame,cinema_frame);
                Screen('DrawLine',obj.ptb_window,blackcolour,cinema_line(1),cinema_line(2),cinema_line(3),cinema_line(4),penwidth);
            end
            % y lines
            for i = 1:(obj.options.cartes_nby+1)
                board_line  = [0,obj.board.cartes.y(i),obj.options.board_size(1),obj.board.cartes.y(i)];
                cinema_line = rescale_rect(board_line,board_frame,cinema_frame);
                Screen('DrawLine',obj.ptb_window,blackcolour,cinema_line(1),cinema_line(2),cinema_line(3),cinema_line(4),penwidth);
            end
        end
        
        % draw retina pigments
        function draw_retinapigments(obj)
            if ~obj.options.cinema_display; return; end
            if ~obj.options.cinema_retinapigments; return; end
            for i = 1:obj.options.retina_density
                board_centre  = obj.board.retina.centre + obj.board.retina.pigments(i,:);
                board_frame   = [0,0,obj.options.board_size];
                cinema_frame  = obj.options.cinema_frame;
                cinema_centre = rescale_point(board_centre,board_frame,cinema_frame);
                radius = 1;
                rect   = [cinema_centre(1)-radius,cinema_centre(2)-radius,cinema_centre(1)+radius,cinema_centre(2)+radius];
                switch obj.board.retina.vision(i)
                    case 0
                        colour = [255,255,255]; % background
                    case 1
                        colour = [0,0,0]; % frame
                    case 2
                        colour = [192,64,64]; % ball
                    otherwise
                        error('cinema: draw_retinapigments: error.');
                end
                Screen('FillOval',obj.ptb_window,colour,rect);
            end
        end
        
        % draw retina cross
        function draw_retinacross(obj)
            if ~obj.options.cinema_display; return; end
            if ~obj.options.cinema_retinacross; return; end
            board_frame   = [0,0,obj.options.board_size];
            board_centre  = obj.board.retina.centre;
            board_radius  = obj.options.retina_focus;
            board_linex   = [board_centre(1)-board_radius,board_centre(2),board_centre(1)+board_radius,board_centre(2)];
            board_liney   = [board_centre(1),board_centre(2)-board_radius,board_centre(1),board_centre(2)+board_radius];
            cinema_frame  = obj.options.cinema_frame;
            cinema_linex  = rescale_rect(board_linex,board_frame,cinema_frame);
            cinema_liney  = rescale_rect(board_liney,board_frame,cinema_frame);
            colour = [255,0,0];
            penwidth = 1;
            Screen('DrawLine',obj.ptb_window,colour,cinema_linex(1),cinema_linex(2),cinema_linex(3),cinema_linex(4),penwidth);
            Screen('DrawLine',obj.ptb_window,colour,cinema_liney(1),cinema_liney(2),cinema_liney(3),cinema_liney(4),penwidth);
        end
        
        % draw retina radius
        function draw_retinaradius(obj)
            if ~obj.options.cinema_display; return; end
            if ~obj.options.cinema_retinaradius; return; end
            board_frame   = [0,0,obj.options.board_size];
            board_centre  = obj.board.retina.centre;
            board_radius  = obj.options.retina_focus;
            board_rect    = [board_centre(1)-board_radius,board_centre(2)-board_radius,board_centre(1)+board_radius,board_centre(2)+board_radius];
            cinema_frame  = obj.options.cinema_frame;
            cinema_rect   = rescale_rect(board_rect,board_frame,cinema_frame);
            colour = [255,0,0];
            penwidth = 1;
            Screen('FrameOval',obj.ptb_window,colour,cinema_rect,penwidth);
        end

    end
end

%% auxiliar
function point2 = rescale_point(point1,frame1,frame2)
    dframe1 = [frame1(3)-frame1(1),frame1(4)-frame1(2)];
    dframe2 = [frame2(3)-frame2(1),frame2(4)-frame2(2)];
    rframe  = dframe2./dframe1;
    dpoint1 = point1 - frame1(1:2);
    point2 = frame2(1:2) + dpoint1.*rframe;
end
function rect2 = rescale_rect(rect1,frame1,frame2)
    dframe1 = [frame1(3)-frame1(1),frame1(4)-frame1(2)];
    dframe2 = [frame2(3)-frame2(1),frame2(4)-frame2(2)];
    oframe1 = frame1(1:2);
    oframe2 = frame2(1:2);
    rframe  = dframe2./dframe1;
    drect1 = rect1 - [oframe1,oframe1];
    rect2 = [oframe2,oframe2] + drect1.*[rframe,rframe];
end
