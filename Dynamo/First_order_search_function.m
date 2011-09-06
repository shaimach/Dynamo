function termination_reason = First_order_search_function (subspace_mask, termination_conditions)
global OC;

wall0 = now();
cpu0 = cputime();

N_eval_counter = 0;


if ~isfield(OC.config, 'FirstOrder')
    OC.config.FirstOrder = struct();
end
if ~isfield(OC.config.FirstOrder,'step_size')
    OC.config.FirstOrder.step_size = 0.1; 
end

stop = false;

while ~stop
    curr_x    = get_current_controls(subspace_mask);
    curr_val  = get_current_value();
    curr_grad = OC.config.gradientNormFunc(subspace_mask);
    curr_grad_norm = sqrt(sum(sum(curr_grad .* curr_grad)));
    
    next_x    = curr_x + OC.config.FirstOrder.step_size .* to_col(curr_grad);
    update_timeslot_controls(next_x, subspace_mask);
    next_val  = get_current_value();

    actual_improvement = next_val - curr_val;
    exptected_improvement = curr_grad_norm.^2 * OC.config.FirstOrder.step_size / OC.config.normNorm;
    
    if actual_improvement < (4/12) * exptected_improvement
        OC.config.FirstOrder.step_size = OC.config.FirstOrder.step_size * 0.99;
    elseif actual_improvement > (8/12) * exptected_improvement
        OC.config.FirstOrder.step_size = OC.config.FirstOrder.step_size * 1.01;
    end
    
    N_eval_counter = N_eval_counter + 1;
    
    if termination_conditions.loop_count <= N_eval_counter;                     termination_reason = OC.const.termination_reason.loop_count;     stop = true; end;
    if termination_conditions.wall_time_to_stop <= (now()-wall0)*(24*60*60);    termination_reason = OC.const.termination_reason.wall_time;      stop = true; end;
    if termination_conditions.cputime_to_stop <= (cputime()-cpu0);              termination_reason = OC.const.termination_reason.cpu_time;       stop = true; end;
    if termination_conditions.gradient_norm_min >= curr_grad_norm;              termination_reason = OC.const.termination_reason.gradient_norm;  stop = true; end;
    if termination_conditions.goal <= next_val;                                 termination_reason = OC.const.termination_reason.goal_achieved;  stop = true; end;
end

