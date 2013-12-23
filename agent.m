classdef agent < matlab.mixin.Copyable % handle + copyable
    
    properties
        options
        flags
        reward
        mode
        vars
    end
    
    methods
        
        %% constructor
        function obj = agent(opt)
            obj.options = opt;
            obj.flags   = struct();
            obj.reward  = reward(opt);
            obj.mode.action = '';
            obj.mode.perception = '';
            % vars
            obj.vars    = struct();
            obj.vars.vision   = [];
            obj.vars.u_vision = [];
            obj.vars.n_vision = [];
            obj.vars.action   = [0,0];
            obj.vars.n_action = 1000;
            obj.vars.u_action = opt.retina_focus * randn(obj.vars.n_action,2);
        end
        
        %% play methods
        function action = play(obj,vision)
            obj.vars.vision = vision;
            % perception
            if ~isempty(obj.mode.perception)
                obj.print(sprintf('mode perception "%s"',obj.mode.perception));
                switch obj.mode.perception
                    case 'none'
                    case 'dist'
                        obj.p_dist();
                end
            end
            % action
            if ~isempty(obj.mode.action)
                obj.print(sprintf('mode action "%s"',obj.mode.action));
                switch obj.mode.action
                    case 'none'
                        obj.vars.action = [0,0];
                    case 'rand'
                        obj.a_rand();
                end
            end
            action = obj.vars.action;
        end
        
        %% perception methods
        function p_dist(obj)
            % save visions
            found = false;
            for i = 1:size(obj.vars.u_vision,1)
                if all(obj.vars.u_vision(i,:)==obj.vars.vision)
                    found = true;
                    obj.vars.n_vision(i) = obj.vars.n_vision(i)+1;
                    break;
                end
            end
            % new vision
            if ~found
                obj.vars.u_vision(end+1,:) = obj.vars.vision;
                obj.vars.n_vision(end+1)   = 1;
            end
            % update probability
            obj.vars.p_vision = obj.vars.n_vision / sum(obj.vars.n_vision);
            % update quobability
            p = (obj.vars.p_vision')*ones(1,size(obj.vars.u_vision,2));
            u = (obj.vars.u_vision==1);
            obj.vars.q_vision = mean(p.*u);
            % print entropy
            obj.print(sprintf('entropy = %7.2f',entropy(obj.vars.p_vision)));
        end
        
        %% action methods
        function a_rand(obj)
            obj.vars.action = obj.vars.u_action(randi(obj.vars.n_action),:);
        end
        
        %% commands
        function help(obj)
            fprintf('\n');
            fprintf('agent  - help        : general help\n');
            fprintf('agent  - flag        : set a flag\n');
            fprintf('agent  - perception  : set perception mode\n');
            fprintf('agent  - action      : set perception mode\n');
            fprintf('\n');
        end
        
        %% execute methods
        function execute(obj,cmds)
            obj.print(sprintf('execute: %s',cell2str(cmds)));
            switch cmds{1}
                case 'action'
                    obj.mode.action = cmds{2};
                case 'flag'
                    obj.flags.(cmds{2}) = eval(cmds{3});
                case 'help'
                    obj.help();
                case 'perception'
                    obj.mode.perception = cmds{2};
                otherwise
                    obj.print(sprintf('command %s not valid.',cmd));
                    obj.help();
            end
        end
        
        %% general methods
        function print(obj,cmd)
            if obj.options.agent_verbose
                dtime = toc(obj.options.time);
                fprintf('%6.2fsec - agent : %s\n',dtime,cmd);
            end
        end
        
    end
end

function h = entropy(p)
    h = sum(-p .* log2(p));
end

function s = cell2str(c)
    s = '';
    for i = 1:length(c)
        s = [s,c{i},' '];
    end
    s(end) = [];
end

