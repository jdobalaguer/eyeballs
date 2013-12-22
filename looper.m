classdef looper < matlab.mixin.Copyable % handle + copyable
    
    properties
        objects
        commands
        time
        inputing
        consoling
        vars
        paused
        running
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
        
        % start commands
        function start(obj)
            obj.commands    = {};
            obj.commands{end+1} = 'obj.objects.cinema.start();';
            obj.inputing    = false;
            obj.consoling   = false;
            obj.vars        = struct();
            obj.paused      = false;
            obj.running     = true;
            obj.time        = tic();
            release();
            while obj.running
                obj.run();
            end
        end
        
        % get command
        function run(obj)
            if obj.inputing;  obj.input();   obj.update(); return; end  % input mode
            if obj.consoling; obj.console(); obj.update(); return; end  % console mode
            obj.read();                                                % add shortcuts
            if isempty(obj.commands); obj.default(); end               % add default
            if isempty(obj.commands); return; end                      % check empty
            obj.runfirst();
        end
        
        % run first command
        function runfirst(obj)
            cmd = obj.commands{1};
            obj.commands(1) = [];
            obj.print(cmd);
            eval(cmd);
        end
        
        % print command
        function print(obj,cmd)
            if obj.objects.options.looper_verbose
                dtime = toc(obj.time);
                fprintf('%5.2fsec - cmd: %s\n',dtime,cmd);
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
        
        % append
        function append(obj,command)
            obj.commands{end+1} = command;
        end
        
        % default commands
        function default(obj)
            if obj.paused; return; end
            obj.next();
        end
        
        % next commands (default)
        function next(obj)
            obj.append('obj.objects.board.play();');
            obj.append('obj.objects.agent.play();');
            obj.append('obj.objects.board.view();');
            obj.append('obj.objects.cinema.draw_board();');
        end
        
        % flush commands
        function flush(obj)
            while ~isempty(obj.commands)
                obj.runfirst;
            end
        end
        
        % update looper
        function update(obj)
            obj.append('obj.objects.cinema.draw_board();');
            obj.flush();
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
                        obj.cinema();
                        release();
                    % h
                    case KbStr({'h'})
                        obj.add('obj.objects.looper.help();');
                        release();
                    % h
                    case KbStr({'k'})
                        obj.add('obj.objects.looper.onconsole();');
                        release();
                    % n
                    case KbStr({'n'})
                        obj.add('obj.objects.looper.next();');
                        release();
                    % p
                    case KbStr({'p'})
                        obj.add('obj.objects.looper.pause();');
                        release();
                    % r
                    case KbStr({'r'})
                        obj.add('obj.objects.looper.resetboard();');
                        release();
                    % v
                    case KbStr({'v'})
                        obj.add('obj.objects.looper.verbose();');
                        release();
                    % arrows
                    case KbStr({'UpArrow'})
                        cmd = 'obj.objects.looper.retina([0,-1]);';
                        if isempty(obj.commands) || ~strcmp(obj.commands{1},cmd)
                            obj.add(cmd);
                        end
                    case KbStr({'DownArrow'})
                        obj.add('obj.objects.looper.retina([0,+1]);');
                    case KbStr({'LeftArrow'})
                        obj.add('obj.objects.looper.retina([-1,0]);');
                    case KbStr({'RightArrow'})
                        obj.add('obj.objects.looper.retina([+1,0]);');
                    % tab
                    case KbStr({'tab'})
                        obj.add('obj.objects.looper.oninput();');
                        release();
                    % escape
                    case KbStr({'escape'})
                        obj.add('obj.objects.looper.stop();');
                        release();
                    % otherwise
                    otherwise
                        obj.add('obj.objects.looper.error();');
                        release();
                end
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
            fprintf('help - [k]onsole   : console mode\n');
            fprintf('help - [n]ext      : next step\n');
            fprintf('help - [p]ause     : pause experiment\n');
            fprintf('help - [r]eset     : reset experiment\n');
            fprintf('help - [v]erbose   : switch verbose mode\n');
            fprintf('help - [arrows]    : move retina\n');
            fprintf('help - [tab]       : enter command\n');
            fprintf('help - [escape]    : quit\n');
            fprintf('\n');
        end
        
        %input
        function oninput(obj)
            obj.flush();
            obj.inputing = true;
            obj.consoling = false;
        end
        function offinput(obj)
            obj.inputing = false;
        end
        
        %console
        function onconsole(obj)
            obj.flush();
            obj.consoling = true;
            obj.inputing = false;
        end
        function offconsole(obj)
            obj.consoling = false;
        end
        
        % pause
        function pause(obj)
            obj.paused = ~obj.paused;
        end
        
        % reset
        function resetboard(obj)
            obj.objects.board.reset();
        end
        
        % retina
        function retina(obj,dcentre)
            centre = obj.objects.retina.centre + dcentre;
            centre(centre<0) = 0;
            ii = (centre>obj.objects.options.board_size);
            centre(ii) = obj.objects.options.board_size(ii);
            obj.objects.retina.centre = centre;
        end
        
        % stop
        function stop(obj)
            Screen('CloseAll');
            obj.running = false;
        end
        
        % verbose
        function verbose(obj)
            obj.objects.options.looper_verbose = ~obj.objects.options.looper_verbose;
        end
        
        
        %% input methods
        
        % input
        function input(obj)
            cmd = input('> ','s');
            release();
            obj.input_execute(cmd);
        end
        
        % parse command
        function cmds = input_parse(~,cmd)
            cmd = strtrim(cmd);
            if isempty(cmd);        cmds = {};
            elseif all(cmd==' ');   cmds = {};
            else                    cmds = regexp(cmd,'\s*','split');
            end
        end
        
        % execute
        function input_execute(obj,cmd)
            cmds = obj.input_parse(cmd);
            switch length(cmds)
                case 0
                case 1
                    obj.input_execute1(cmds{1});
                case 2
                    obj.input_execute2(cmds{1},cmds{2});
                case 3
                    obj.input_execute3(cmds{1},cmds{2},cmds{3});
            end
        end
        
        % execute: hotkey commands (1 field)
        function input_execute1(obj,cmd)
            switch cmd
                case 'cinema'
                    obj.cinema();
                case 'help'
                    obj.add('obj.help();');
                case 'konsole'
                    obj.add('obj.onconsole();');
                case 'next'
                    obj.add('obj.next();');
                case 'pause'
                    obj.add('obj.pause();');
                case 'reset'
                    obj.add('obj.resetboard();');
                case 'quit'
                    obj.add('obj.stop();');
                case 'verbose'
                    obj.add('obj.verbose();');
                case 'exit'
                    obj.add('obj.offinput();');
                otherwise
                    fprintf('> ''%s'' not valid\n',cmd);
            end
        end
        
        % execute: object commands (2 fields) 
        function input_execute2(obj,object,cmd)
            if ~isfield(obj.objects,object);       fprintf('  ''%s'' not valid\n',object); obj.help();          return; end
            obj.objects.(object).execute(cmd);
        end
        
        % execute: set variables (3 fields)
        function input_execute3(obj,object,prop,value)
            if ~isfield(obj.objects,object);       fprintf('  ''%s'' not valid\n',object); obj.help();          return; end
            if ~isprop(obj.objects.(object),prop); fprintf('  ''%s.%s'' not valid\n',object,prop); obj.help();  return; end
            obj.objects.(object).(prop) = eval(value);
        end
        
        
        %% console methods
        
        % console
        function console(obj)
            cmd = input('$ ','s');
            release();
            obj.console_execute(cmd);
        end
        
        % parse
        function cmd = console_parse(~,cmd)
            cmd = strtrim(cmd);
            cmd = strrep(cmd,'!','obj.vars.');
        end
        
        % execute
        function console_execute(obj,cmd)
            cmd = obj.console_parse(cmd);
            switch cmd
                case 'exit'
                    obj.add('obj.offconsole();');
                case 'quit'
                    obj.add('obj.stop()');
                case 'input'
                    obj.add('');obj.oninput();
                otherwise
                    try
                        eval(cmd)
                    catch err
                        fprintf([err.message,'\n']);
                    end
            end
        end

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

