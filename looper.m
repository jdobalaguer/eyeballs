classdef looper < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        commands
        time
        paused
        run
    end
    
    methods
        
        %% constructor
        function obj = looper(opt)
            obj.options  = opt;
            obj.commands = {};
        end
        
        %% loop methods
        
        % get command
        function command = get(obj)
            obj.read();
            if isempty(obj.commands)
                if   obj.paused; command = ''; return;
                else obj.default();
                end
            end
            command = obj.commands{1};
            obj.commands(1) = [];
            if obj.options.looper_verbose
                dtime = toc(obj.time);
                fprintf('%5.2fsec - cmd: %s\n',dtime,command);
            end
        end
        
        % start commands
        function start(obj)
            obj.commands{end+1} = 'obj.cinema.start();';
            obj.paused = false;
            obj.run  = true;
            obj.time = tic();
        end
        
        % reset commands
        function reset(obj)
            obj.commands(:) = [];
        end
        
        % add command
        function add(obj,command)
            obj.commands = [command, obj.commands];
        end
        
        % default commands
        function default(obj)
            obj.commands{end+1} = 'obj.board.play();';
            obj.commands{end+1} = 'obj.agent.play();';
            obj.commands{end+1} = 'obj.board.view();';
            obj.commands{end+1} = 'obj.cinema.draw_board();';
        end
        
        
        %% keyboard methods
        
        % read
        function read(obj)
            [down,~,code] = KbCheck();
            if down && sum(code)==1
                fcode = find(code);
                switch fcode
                    % c
                    case KbName('c')
                        obj.add('obj.looper.cinema();');
                    % h
                    case KbName('h')
                        obj.add('obj.looper.help();');
                    % n
                    case KbName('n')
                        obj.add('obj.looper.default();');
                    % p
                    case KbName('p')
                        obj.add('obj.looper.pause();');
                    % v
                    case KbName('v')
                        obj.add('obj.looper.verbose();');
                    % escape
                    case KbName('escape')
                        obj.add('obj.looper.stop();');
                    % otherwise
                    otherwise
                        obj.add('obj.looper.error();');
                end
                while KbCheck(); end
            end
        end
        
        
        %% methods
        % cinema
        function cinema(obj)
            switch obj.options.cinema_display
                case true
                    obj.add('obj.options.cinema_display=false; obj.cinema.stop();');
                case false
                    obj.add('obj.options.cinema_display=true;  obj.cinema.start();');
            end
        end
        
        % error
        function error(obj)
            fprintf('error - hotkey not valid\n');
        end
        
        % help
        function help(obj)
            fprintf('\n');
            fprintf('help - c:   cinema display\n');
            fprintf('help - h:   print this help menu\n');
            fprintf('help - n:   next step\n');
            fprintf('help - p:   pause experiment\n');
            fprintf('help - v:   switch verbose mode\n');
            fprintf('help - esc: exit\n');
            fprintf('\n');
        end
        
        % pause
        function pause(obj)
            obj.paused = ~obj.paused;
        end
        
        % stop
        function stop(obj)
            Screen('CloseAll');
            FlushEvents();
            obj.run = false;
        end
        
        % verbose
        function verbose(obj)
            obj.options.looper_verbose = ~obj.options.looper_verbose;
        end
        
        
    end
end
