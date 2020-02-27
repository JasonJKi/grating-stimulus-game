function param = gameParam(type, trial_duration, pause_duration)

switch type
    case 'static'
        param.is_active = true;
        param.is_obj_disabled = true;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;        
    case 'active control'
        param.is_active = true;
        param.is_obj_disabled = false;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;               
    case 'passive pursuit'
        param.is_active = false;
        param.is_obj_disabled = false;
        param.trial_duration = trial_duration;
        param.pause_duration = pause_duration;
end
        
