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
        board_size
        ball_number
        ball_radius
        ball_speed
        ball_acceleration
        retina_focus
        retina_density
        retina_radius
        cinema_display
        cinema_balls
        cinema_retinaradius
        cinema_retinapigments
        cinema_marge
        cinema_rect
        cinema_frame
    end
    
    methods
        function obj = options(varargin)
            % check length of input
            assert(~mod(nargin,2),'options: error. odd number of arguments');
            % build default options
            obj.board_size              = [100,100];
            obj.ball_number             = 5;
            obj.ball_radius             = 3;
            obj.ball_speed              = 2;
            obj.ball_acceleration       = 0.95;
            obj.retina_focus            = 10;
            obj.retina_density          = 1000;
            obj.cinema_display          = true;
            obj.cinema_balls            = true;
            obj.cinema_retinaradius     = true;
            obj.cinema_retinapigments   = true;
            obj.cinema_marge            = 100;
            obj.cinema_rect             = [0,0,obj.board_size + 2*obj.cinema_marge];
            % set options
            for i = 1:2:nargin
                obj = set_option(obj,varargin{i},varargin{i+1});
            end
            % set frame
            set_frame(obj);
        end
        
        function set_frame(obj)
            marge = obj.cinema_marge;
            rect  = obj.cinema_rect;
            frame = [marge,marge,rect(3)-rect(1)-marge,rect(4)-rect(2)-marge];
            obj.cinema_frame = frame;
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
