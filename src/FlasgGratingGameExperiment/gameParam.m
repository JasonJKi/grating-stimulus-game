function param = gameParam(type, trial_duration, pause_duration)

switch type
    case 'static'
        param.is_active = true;
        param.is_obj_disabled = true;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;
        param.game_type = 1;
    case 'left and right control'
        param.is_active = true;
        param.is_obj_disabled = false;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;
        param.game_type = 2;        
    case 'left and right passive pursuit'
        param.is_active = false;
        param.is_obj_disabled = false;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;
        param.game_type = 3;
    case 'mine sweeper'
        param.is_active = true;
        param.is_obj_disabled = false;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;
        param.game_type = 4;
    case 'mine sweeper watching'
        param.is_active = true;
        param.is_obj_disabled = false;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;
        param.game_type = 4;
end

