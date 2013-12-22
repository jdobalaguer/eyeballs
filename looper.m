classdef looper < matlab.mixin.Copyable % handle + copyable
    
    properties
        objects
        commands
        time
        inputing
        paused
        run
    end
    
    methods
        %% constructor
        
        function obj = looper(gme)
            obj.objects  = struct();
            obj.objects.game    = gme;
            obj.objects.agent   = gme.agent;
            obj.objects.ball    = gme.board.ball;
            obj.objects.board   = gme.board;
            obj.objects.cartes  = gme.board.cartes;
            obj.objects.cinema  = gme.cinema;
            obj.objects.looper  = obj;
            obj.objects.options = gme.options;
            obj.objects.retina  = gme.board.retina;
            obj.objects.reward  = gme.agent.reward;
        end
        
        %% loop methods
        
        % get command
        function command = get(obj)
            % priorities
            command = '';
            if obj.inputing;            obj.input(); return;    end        % input mode
            obj.read();                                                    % add shortcuts
            if isempty(obj.commands);   obj.default();          end        % add default
            if isempty(obj.commands);   return;                 end        % check empty
            command = obj.commands{1};
            obj.commands(1) = [];
            if obj.objects.options.looper_verbose
                dtime = toc(obj.time);
                fprintf('%5.2fsec - cmd: %s\n',dtime,command);
            end
        end
        
        % start commands
        function start(obj)
            obj.commands = {};
            obj.commands{end+1} = 'obj.objects.cinema.start();';
            obj.inputing = false;
            obj.paused   = false;
            obj.run      = true;
            obj.time     = tic();
            release();
            while obj.run
                eval(obj.get());
            end
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
            if obj.paused; return; end
            obj.next();
        end
        
        % next commands (default)
        function next(obj)
            obj.commands{end+1} = 'obj.objects.board.play();';
            obj.commands{end+1} = 'obj.objects.agent.play();';
            obj.commands{end+1} = 'obj.objects.board.view();';
            obj.commands{end+1} = 'obj.objects.cinema.draw_board();';
        end
        
        
        %% keyboard methods
        
        % read
        function read(obj)
            [down,~,code] = KbCheck();
            if down
                scode = bin2str(code);
                switch scode
                    % c
                    case KbStr({'c'})
                        obj.add('obj.objects.looper.cinema();');
                    % h
                    case KbStr({'h'})
                        obj.add('obj.objects.looper.help();');
                    % n
                    case KbStr({'n'})
                        obj.add('obj.objects.looper.next();');
                    % p
                    case KbStr({'p'})
                        obj.add('obj.objects.looper.pause();');
                    % v
                    case KbStr({'v'})
                        obj.add('obj.objects.looper.verbose();');
                    % arrows
                    case KbStr({'UpArrow'})
                        obj.add('obj.objects.looper.retina([0,-1]);');
                    case KbStr({'DownArrow'})
                        obj.add('obj.objects.looper.retina([0,+1]);');
                    case KbStr({'LeftArrow'})
                        obj.add('obj.objects.looper.retina([-1,0]);');
                    case KbStr({'RightArrow'})
                        obj.add('obj.objects.looper.retina([+1,0]);');
                    % tab
                    case KbStr({'tab'})
                        obj.add('obj.objects.looper.input();');
                    % escape
                    case KbStr({'escape'})
                        obj.add('obj.objects.looper.stop();');
                    % otherwise
                    otherwise
                        obj.add('obj.objects.looper.error();');
                end
                release();
            end
        end
        
        
        %% hotkey methods
        
        % cinema
        function cinema(obj)
            switch obj.objects.options.cinema_display
                case true
                    obj.add('obj.objects.options.cinema_display=false; obj.objects.cinema.stop();');
                case false
                    obj.add('obj.objects.options.cinema_display=true;  obj.objects.cinema.start();');
            end
        end
        
        % error
        function error(obj)
            fprintf('error - hotkey not valid\n');
        end
        
        % help
        function help(obj)
            fprintf('\n');
            fprintf('help - [c]inema    : cinema display\n');
            fprintf('help - [h]elp      : print this help menu\n');
            fprintf('help - [n]ext      : next step\n');
            fprintf('help - [p]ause     : pause experiment\n');
            fprintf('help - [v]erbose   : switch verbose mode\n');
            fprintf('help - [arrows]    : move retina\n');
            fprintf('help - [tab]       : enter command\n');
            fprintf('help - [escape]    : quit\n');
            fprintf('\n');
        end
        
        %input
        function input(obj)
            obj.inputing = true;
            cmd = input('> ','s');
            release();
            obj.execute(cmd);
        end
        
        function deinput(obj)
            obj.inputing = false;
        end
        
        % pause
        function pause(obj)
            obj.paused = ~obj.paused;
        end
        
        % retina
        function retina(obj,dcentre)
            obj.objects.retina.centre = obj.objects.retina.centre + dcentre;
        end
        
        % stop
        function stop(obj)
            Screen('CloseAll');
            obj.run = false;
        end
        
        % verbose
        function verbose(obj)
            obj.objects.options.looper_verbose = ~obj.objects.options.looper_verbose;
        end
        
        
        %% execute methods
        
        function execute(obj,cmd)
            cmds = parse(cmd);
            switch length(cmds)
                case 0
                case 1
                    obj.execute1(cmds{1});
                case 2
                    obj.execute2(cmds{1},cmds{2});
                case 3
                    obj.execute3(cmds{1},cmds{2},cmds{3});
            end
        end
        
        % execute: commands
        function execute1(obj,cmd)
            switch cmd
                case 'cinema'
                    obj.cinema();
                case 'help'
                    obj.help();
                case 'next'
                    obj.next();
                case 'pause'
                    obj.pause();
                case 'quit'
                    obj.stop();
                case 'verbose'
                    obj.verbose();
                case 'exit'
                    obj.deinput();
                otherwise
                    fprintf('> ''%s'' not valid\n',cmd);
            end
        end
        
        % execute: object commands (2 fields) 
        function execute2(obj,object,cmd)
            if ~isfield(obj.objects,object);       fprintf('  ''%s'' not valid\n',object); obj.help();          return; end
            obj.objects.(object).execute(cmd);
        end
        
        % execute: set variables (3 fields)
        function execute3(obj,object,prop,value)
            if ~isfield(obj.objects,object);       fprintf('  ''%s'' not valid\n',object); obj.help();          return; end
            if ~isprop(obj.objects.(object),prop); fprintf('  ''%s.%s'' not valid\n',object,prop); obj.help();  return; end
            obj.objects.(object).(prop) = value;
        end
        
        % 
    end
end


%% Auxiliar

% release keyboard
function release()
    while KbCheck(); end
    FlushEvents();
end

% translate KbName to vector output
function kb_code = KbCode(kb_name)
    kb_code = zeros(1,256);
    kb_code(KbName(kb_name)) = 1;
end

function kb_str = KbStr(kb_name)
    if ~iscell(kb_name); kb_name = {kb_name}; end
    kb_code = KbCode(kb_name{1});
    for i = 2:length(kb_name)
        kb_code = kb_code | KbCode(kb_name{i});
    end
    kb_str  = bin2str(kb_code);
end

% convert binary vector to string
function str = bin2str(bin)
    str = dec2bin(bin)';
end

% parse command
function cmds = parse(cmd)
    if isempty(cmd);        cmds = {};
    elseif all(cmd==' ');   cmds = {};
    else                    cmds = regexp(cmd,'\s*','split');
    end
end

