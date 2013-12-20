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
        
        %% screen
        function start(obj)
            Screen('Preference', 'Verbosity',0);
            Screen('Preference', 'SuppressAllWarnings', 1);
            Screen('Preference', 'SkipSyncTests', 2);
            obj.ptb_rect = obj.options.cinema_rect;
            obj.ptb_screens = Screen('Screens');
            obj.ptb_screen  = obj.ptb_screens(end);
            obj.ptb_window  = Screen('OpenWindow',obj.ptb_screen,0,obj.ptb_rect,32,2);
        end
        
        function stop(obj)
            WaitSecs(3);
            Screen('CloseAll');
        end
        
        function background(obj)
            colour = [128,128,128];
            Screen('FillRect',obj.ptb_window,colour,obj.ptb_rect);
        end
        
        function flip(obj)
            Screen('Flip',obj.ptb_window);
        end
        
        function draw_board(obj)
            obj.background();
            obj.draw_frame();
            obj.draw_balls();
            obj.draw_retinapigments();
            obj.draw_retinaradius();
            obj.draw_retinacross();
            obj.flip();
        end
        
        function draw_frame(obj)
            marge = obj.options.cinema_marge;
            rect  = obj.options.cinema_rect;
            frame = [marge,marge,rect(3)-rect(1)-marge,rect(4)-rect(2)-marge];
            colour = [0,0,0];
            penwidth = 2;
            Screen('FrameRect',obj.ptb_window,colour,frame,penwidth);
        end
        
        function draw_balls(obj)
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
        
        function draw_retinacross(obj)
            board_frame   = [0,0,obj.options.board_size];
            board_centre  = obj.board.retina.centre;
            cinema_frame  = obj.options.cinema_frame;
            cinema_centre = rescale_point(board_centre,board_frame,cinema_frame);
            colour = [255,0,0];
            length = 10;
            line_x = [cinema_centre(1)-length,cinema_centre(2),cinema_centre(1)+length,cinema_centre(2)];
            line_y = [cinema_centre(1),cinema_centre(2)-length,cinema_centre(1),cinema_centre(2)+length];
            penwidth = 1;
            Screen('DrawLine',obj.ptb_window,colour,line_x(1),line_x(2),line_x(3),line_x(4),penwidth);
            Screen('DrawLine',obj.ptb_window,colour,line_y(1),line_y(2),line_y(3),line_y(4),penwidth);
        end
        
        function draw_retinaradius(obj)
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
        
        function draw_retinapigments(obj)
            for i = 1:obj.options.retina_density
                board_frame   = [0,0,obj.options.board_size];
                board_centre  = obj.board.retina.centre + [obj.board.retina.hpigments(i),obj.board.retina.vpigments(i)];
                cinema_frame  = obj.options.cinema_frame;
                cinema_centre = rescale_point(board_centre,board_frame,cinema_frame);
                radius = 1;
                rect   = [cinema_centre(1)-radius,cinema_centre(2)-radius,cinema_centre(1)+radius,cinema_centre(2)+radius];
                colour = [192,64,64];
                Screen('FillOval',obj.ptb_window,colour,rect);
            end
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
