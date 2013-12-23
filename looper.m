classdef looper < matlab.mixin.Copyable % handle + copyable
    
    properties
        objects
        commands
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
        
        %% update methods
        function set(obj,newobj)
            % keep
            cinema_display = obj.objects.options.cinema_display;
            % set
            obj.objects     = newobj.objects;
            obj.commands    = newobj.commands;
            obj.inputing    = newobj.inputing;
            obj.consoling   = newobj.consoling;
            obj.vars        = newobj.vars;
            obj.paused      = newobj.paused;
            obj.running     = newobj.running;
            % restore
            obj.objects.options.cinema_display = cinema_display;
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
            obj.objects.options.time = tic();
            release();
            while obj.running
                obj.run();
            end
            Screen('CloseAll');
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
                dtime = toc(obj.objects.options.time);
                fprintf('%6.2fsec - looper: %s\n',dtime,cmd);
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
            obj.append('obj.vars.vision = obj.objects.board.view();');
            obj.append('obj.objects.cinema.draw_board();');
            obj.append('obj.objects.board.play();');
            obj.append('obj.vars.action = obj.objects.agent.play(obj.vars.vision);');
            obj.append('obj.objects.board.retina.play(obj.vars.action);');
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
                    case KbStr({'a'})
                        obj.add('obj.objects.looper.agentverbose();');
                        release();
                    % c
                    case KbStr({'c'})
                        obj.cinema();
                        release();
                    % h
                    case KbStr({'h'})
                        obj.add('obj.objects.looper.help();');
                        release();
                    % k
                    case KbStr({'k'})
                        obj.add('obj.objects.looper.onconsole();');
                        release();
                    % l
                    case KbStr({'l'})
                        obj.add('obj.objects.looper.load();');
                        release();
                    % n
                    case KbStr({'n'})
                        obj.add('obj.objects.looper.next();');
                        release();
                    % p
                    case KbStr({'p'})
                        obj.add('obj.objects.looper.pause();');
                        release();
                    % q
                    case KbStr({'q'})
                        obj.add('obj.objects.looper.stop();');
                        release();
                    % r
                    case KbStr({'r'})
                        obj.add('obj.objects.looper.resetboard();');
                        release();
                    % s
                    case KbStr({'s'})
                        obj.add('obj.objects.looper.save();');
                        release();
                    % v
                    case KbStr({'v'})
                        obj.add('obj.objects.looper.verbose();');
                        release();
                    % arrows
                    case KbStr({'UpArrow'})
                        obj.add('obj.objects.retina.play([0,-1]);');
                    case KbStr({'DownArrow'})
                        obj.add('obj.objects.retina.play([0,+1]);');
                    case KbStr({'LeftArrow'})
                        obj.add('obj.objects.retina.play([-1,0]);');
                    case KbStr({'RightArrow'})
                        obj.add('obj.objects.retina.play([+1,0]);');
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
        
        % agent verbose
        function agentverbose(obj)
            obj.objects.options.agent_verbose = ~obj.objects.options.agent_verbose;
        end
        
        % cinema
        function cinema(obj)
            switch obj.objects.options.cinema_display
                case true
                    obj.offcinema();
                case false
                    obj.oncinema();
            end
        end
        function oncinema(obj)
            obj.add('obj.objects.options.cinema_display=true;  obj.objects.cinema.start();');
        end
        function offcinema(obj)
            obj.add('obj.objects.options.cinema_display=false; obj.objects.cinema.stop();');
        end
        
        % error
        function error(obj)
            obj.print('error. hotkey not valid\n');
        end
        
        % help
        function help(obj)
            fprintf('\n');
            fprintf('looper - [a]gent     : agent verbose\n');
            fprintf('looper - [c]inema    : cinema display\n');
            fprintf('looper - [h]elp      : print this menu\n');
            fprintf('looper - [k]onsole   : console mode\n');
            fprintf('looper - [n]ext      : next step\n');
            fprintf('looper - [p]ause     : pause experiment\n');
            fprintf('looper - [q]uit      : quit\n');
            fprintf('looper - [r]eset     : reset experiment\n');
            fprintf('looper - [v]erbose   : switch verbose mode\n');
            fprintf('looper - [arrows]    : move retina\n');
            fprintf('looper - [tab]       : enter command\n');
            fprintf('looper - [escape]    : quit\n');
            fprintf('\n');
        end
        
        % input
        function oninput(obj)
            obj.flush();
            obj.inputing = true;
            obj.consoling = false;
        end
        function offinput(obj)
            obj.inputing = false;
        end
        
        % konsole
        function onconsole(obj)
            obj.flush();
            obj.consoling = true;
            obj.inputing = false;
        end
        function offconsole(obj)
            obj.consoling = false;
        end
        
        % load/save
        function load(obj,fname)
            if ~exist('fname','var'); fname='status.mat'; end
            obj.offcinema();
            loader  = load(fname);
            obj.set(loader.obj);
        end
        function save(obj,fname)
            if ~exist('fname','var'); fname='status.mat'; end
            obj.offcinema();
            save(fname,'obj');
        end
        
        % pause
        function pause(obj)
            obj.paused = ~obj.paused;
        end
        
        % reset
        function resetboard(obj)
            obj.objects.board.reset();
        end
                
        % stop
        function stop(obj)
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
            if isempty(cmds); return; end
            switch cmds{1}
                case 'exe'
                    obj.input_execute_exe(cmds);
                case 'set'
                    obj.input_execute_set(cmds);
                otherwise
                    obj.input_execute_hotkey(cmds);

            end
        end
        
        % execute: hotkey commands (1 field)
        function input_execute_hotkey(obj,cmds)
            switch cmds{1}
                case 'agent'
                    obj.add('obj.objects.looper.agentverbose();');
                case 'cinema'
                    obj.cinema();
                case 'help'
                    obj.add('obj.help();');
                case 'konsole'
                    obj.add('obj.onconsole();');
                case 'load'
                    obj.add('obj.load();');
                case 'next'
                    obj.add('obj.next();');
                case 'pause'
                    obj.add('obj.pause();');
                case 'save'
                    obj.add('obj.save();');
                case 'reset'
                    obj.add('obj.resetboard();');
                case 'quit'
                    obj.add('obj.stop();');
                case 'verbose'
                    obj.add('obj.verbose();');
                case 'exit'
                    obj.add('obj.offinput();');
                otherwise
                    fprintf('> ''%s'' not valid\n',cell2str(cmds));
            end
        end
        
        % execute: object commands
        function input_execute_exe(obj,cmds)
            if ~isfield(obj.objects,cmds{2});       fprintf('  ''%s'' not valid\n',cmds{2}); obj.help();          return; end
            obj.objects.(cmds{2}).execute(cmds(3:end));
        end
        
        % execute: set variables
        function input_execute_set(obj,cmds)
            if length(cmds)~=4;                         fprintf('  4 fields required, %d fields specified\n',length(cmds)); return; end
            if ~isfield(obj.objects,cmds{2});           fprintf('  ''%s'' not valid\n',cmds{4}); obj.help();                return; end
            if ~isprop(obj.objects.(cmds{2}),cmds{3});  fprintf('  ''%s.%s'' not valid\n',cmds{2},cmds{3}); obj.help();     return; end
            obj.objects.(cmds{2}).(cmds{3}) = eval(cmds{4});
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

% concatenate cell of strings
function s = cell2str(c)
    s = '';
    for i = 1:length(c)
        s = [s,c{i},' '];
    end
    s(end) = [];
end
