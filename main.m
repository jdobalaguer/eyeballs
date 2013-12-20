% interaction
% retina_get
% reward


try
    %% initialise variables
    o = options('cinema_rect',[0,0,600,600]);  % command
    g = game(o);     % game

    %% start game
    g.start();

    Screen('CloseAll');
catch err
    Screen('CloseAll');
    rethrow(err);
end