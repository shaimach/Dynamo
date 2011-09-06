function termination_reason = Krotov_search_function (subspace_mask, term_cond)
global OC;

meta_term_cond = term_cond;

per_block_term_cond = term_cond;
per_block_term_cond.loop_count = 1;

block_size_1 = 1;

termination_reason = Block_cycle_search_function(subspace_mask, meta_term_cond, per_block_term_cond,  @First_order_search_function, block_size_1);
