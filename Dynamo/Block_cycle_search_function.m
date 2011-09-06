function termination_reason = Block_cycle_search_function (subspace_mask, meta_term_cond, per_block_term_cond, block_search_function, block_size)
global OC;

wall0 = now();
cpu0 = cputime();

N_cycle_counter = 0;

stop = false;

cols_n = find(sum(subspace_mask,2) > 0);
n_blocks = ceil(length(cols_n) / block_size);

if n_blocks < 2
    block_masks = {subspace_mask};
else
    block_masks = cell(1,n_blocks);
    for n=1:n_blocks-1
        this_block = false(size(subspace_mask));
        col_selection = cols_n(((n-1)*block_size+1):(n*block_size));
        this_block(col_selection,:) = subspace_mask(col_selection,:);
        block_masks{n} = this_block;
    end
    this_block = false(size(subspace_mask));
    col_selection = cols_n((end-block_size+1):end);
    this_block(col_selection,:) = subspace_mask(col_selection,:);
    block_masks{end} = this_block;
    % Maybe it's better to do true cycling - meaning a block can start at 193..200 and continue 1..25, etc.
end

while ~stop

    tic;

    this_block = block_masks{mod(N_cycle_counter, n_blocks) + 1};
    
    per_block_term_reason = block_search_function (this_block, per_block_term_cond);

    if mod(N_cycle_counter, n_blocks)==n_blocks-1; fprintf ('After %d cycles we''re at fidelity 1-%g, with exit reason %d\n', floor(N_cycle_counter/n_blocks)+1, 1-get_current_value(), per_block_term_reason); end;

    N_cycle_counter = N_cycle_counter + 1; 
    curr_val = get_current_value();
    curr_grad = +Inf; % For Krotov-like searches, calculating this value (which is for all slices) requires more computational resources than the Krotov step itself. It has therefore been dropped.
    
    if per_block_term_reason == OC.const.termination_reason.goal_achieved
        termination_reason = OC.const.termination_reason.goal_achieved;
        stop = true;
    else
        if meta_term_cond.loop_count <= N_cycle_counter;                    termination_reason = OC.const.termination_reason.loop_count;     stop = true; end;
        if meta_term_cond.wall_time_to_stop <= (now()-wall0)*(24*60*60);    termination_reason = OC.const.termination_reason.wall_time;      stop = true; end;
        if meta_term_cond.cputime_to_stop <= (cputime()-cpu0);              termination_reason = OC.const.termination_reason.cpu_time;       stop = true; end;
        if meta_term_cond.gradient_norm_min >= curr_grad;                   termination_reason = OC.const.termination_reason.gradient_norm;  stop = true; end;
        if meta_term_cond.goal <= curr_val;                                 termination_reason = OC.const.termination_reason.goal_achieved;  stop = true; end;
    end
    
end
