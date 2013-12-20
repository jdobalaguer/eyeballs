classdef game < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        board
        cinema
    end
    
    methods
        function obj = game(opt)
            obj.options = opt;
            obj.board = board(opt);
            obj.cinema = cinema(opt,obj.board);
        end
        
        function start(obj)
            obj.cinema.start();
            while true
                obj.cinema.draw_board();
                obj.board.play();
            end
            obj.cinema.stop();
        end
    end
end
