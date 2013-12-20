classdef game < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        looper
        board
        agent
        cinema
    end
    
    methods
        function obj = game(opt)
            obj.options = opt;
            obj.looper  = looper(opt);
            obj.board   = board(opt);
            obj.agent   = agent(opt,obj.board.retina);
            obj.cinema  = cinema(opt,obj.board);
        end
        
        function start(obj)
            try
                obj.looper.start();
                while obj.looper.run; eval(obj.looper.get()); end
            catch err
                Screen('CloseAll');
                rethrow(err);
            end
        end
    end
end
