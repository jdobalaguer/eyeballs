classdef options < matlab.mixin.Copyable % handle + copyable
% 
% options
%   set parameters
%
% board_balls
% board_size
% 
% ball radius
% ball_speed
% ball_acceleration
% 
% retina_focus
% retina density
% retina_radius
%
% cinema_display
% cinema_retinaradius
% cinema_retinapigments
%

    properties
        agent_verbose
        board_size
        ball_number
        ball_radius
        ball_speed
        ball_acceleration
        cartes_nbx
        cartes_nby
        retina_focus
        retina_density
        cinema_display
        cinema_ball
        cinema_board
        cinema_cartes
        cinema_retinacross
        cinema_retinapigments
        cinema_retinaradius
        cinema_marge
        cinema_rect
        cinema_frame
        looper_verbose
        time
    end
    
    methods
        function obj = options(varargin)
            % check length of input
            assert(~mod(nargin,2),'options: error. odd number of arguments');
            % build default options
            obj.agent_verbose           = false;
            obj.board_size              = [100,100];
            obj.ball_number             = 1;
            obj.ball_radius             = 7;
            obj.ball_speed              = 7;
            obj.ball_acceleration       = 0.95;
            obj.cartes_nbx              = 5;
            obj.cartes_nby              = 5;
            obj.retina_focus            = 5;
            obj.retina_density          = 200;
            obj.cinema_display          = false;
            obj.cinema_ball             = true;
            obj.cinema_cartes           = true;
            obj.cinema_board            = true;
            obj.cinema_retinacross      = true;
            obj.cinema_retinapigments   = true;
            obj.cinema_retinaradius     = true;
            obj.cinema_rect             = [0,0,600,600];
            obj.cinema_frame            = [100,100,500,500];
            obj.looper_verbose          = false;
            obj.time                    = 0;
            % set options
            for i = 1:2:nargin
                obj = set_option(obj,varargin{i},varargin{i+1});
            end
        end
        
        function obj = set_option(obj,field,value)
            check_option(obj,field);
            obj.(field) = value;
        end
        
        function check_option(obj,field)
            assert(isprop(obj,field), ['options: error. argument "',field,'" is not a property']);
        end
        
    end
end
