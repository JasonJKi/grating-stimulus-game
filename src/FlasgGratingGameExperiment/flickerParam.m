function experiment_param = flickerParam(type, num_repeats)
experiment_param=[];
switch type
    case 'variable contrast'
        num_repeats = 1;
        experiment_param.surround_flicker = repmat([7 7 7 15 15 15], 1, num_repeats);
        experiment_param.center_flicker =  repmat([7 7 7 15 15 15], 1, num_repeats);
        experiment_param.surround_contrast = repmat([1 .5 0 1 .5 0], 1, num_repeats);
        experiment_param.center_contrast = repmat([1 1 1 1 1 1], 1, num_repeats);
    case 'variable frequency'
        num_repeats = 1;
        experiment_param.surround_flicker = repmat([7 15 25 7 15 25], 1, num_repeats);
        experiment_param.center_flicker =  repmat([25 7 15 15 25 7], 1, num_repeats);
        experiment_param.surround_contrast = repmat([1 1 1 1 1 1], 1, num_repeats);
        experiment_param.center_contrast = repmat([1 1 1 1 1 1], 1, num_repeats);
    case 'tutorial'
        num_repeats = 1;
        experiment_param.surround_flicker = repmat([7 7 7 15 15 15], 1, num_repeats);
        experiment_param.center_flicker =  repmat([7 7 7 15 15 15], 1, num_repeats);
        experiment_param.surround_contrast = repmat([1 .5 0 1 .5 0], 1, num_repeats);
        experiment_param.center_contrast = repmat([1 1 1 1 1 1], 1, num_repeats);
    case 'constant'
        experiment_param.surround_flicker = repmat(7, 1, num_repeats);
        experiment_param.center_flicker =  repmat(7, 1, num_repeats);
        experiment_param.surround_contrast = repmat(1, 1, num_repeats);
        experiment_param.center_contrast = repmat(1, 1, num_repeats);
end
end

