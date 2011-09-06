function termination_reason = BFGS_search_function (subspace_mask, termination_conditions)
global OC;

wall0 = now();
cpu0 = cputime();

N_iter = 0;
N_eval_counter = 0;

last_grad_norm = NaN;
N_eval_counter = 0;
        
    function stop = monitor_function(x, optimValues, state)
        stop = false;
        N_iter = N_iter + 1;

        if termination_conditions.loop_count <= N_eval_counter;                     termination_reason = OC.const.termination_reason.loop_count;     stop = true; end;
        if termination_conditions.wall_time_to_stop <= (now()-wall0)*(24*60*60);    termination_reason = OC.const.termination_reason.wall_time;      stop = true; end;
        if termination_conditions.cputime_to_stop <= (cputime()-cpu0);              termination_reason = OC.const.termination_reason.cpu_time;       stop = true; end;
        if termination_conditions.gradient_norm_min >= last_grad_norm;              termination_reason = OC.const.termination_reason.gradient_norm;  stop = true; end;
        if termination_conditions.goal <= get_current_value();                      termination_reason = OC.const.termination_reason.goal_achieved;  stop = true; end;
        
    end

    function [v, grad] = goal_and_gradient_function_wrapper (subspace_controls)
        % Note: subspace_controls is a vector containing a (possible) subset of the entire control space
        N_eval_counter = N_eval_counter + 1;

        update_timeslot_controls(subspace_controls, subspace_mask);
        v = -get_current_value ();
        
        grad = -OC.config.gradientNormFunc(subspace_mask);
  
        last_grad_norm = sum(sum(grad.*grad));
    end

problem = struct();

problem.options = optimset(...
    'TolX',         1e-8,...
    'TolFun',       1e-8,...
    'DerivativeCheck', 'off',...
    'FinDiffType',  'central',...    
    'GradObj',      'on',...
    'LargeScale',   'off', ...
    'OutputFcn',    @monitor_function,...
    'Display',      'off');
if isfield(OC.config,'BFGS') && isfield(OC.config.BFGS,'fminopt')
    fn = fieldnames(OC.config.BFGS.fminopt);
    for k=1:length(fn)
        problem.options = optimset(problem.options, fn{k}, OC.config.BFGS.fminopt.(fn{k}));
    end
end    

termination_reason = OC.const.termination_reason.gradient_norm; % If BFGS cannot find the goal, this is because the gradients are pointing nowhere useful
problem.objective = @goal_and_gradient_function_wrapper;
problem.x0 = get_current_controls(subspace_mask);

problem.solver = 'fminunc';
% try to minimise objective function to -1
[uFinal, costFinal, exitflag, output] = fminunc(problem);

update_timeslot_controls(uFinal, subspace_mask); % It may be different than the last point evaluated, and there is no problem-space 
end


