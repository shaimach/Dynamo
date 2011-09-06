function termination_reason = Two_method_crossover_function (subspace_mask, first_method_term_cond, first_search_method, second_method_term_cond, second_search_method)

first_search_method(subspace_mask, first_method_term_cond);

termination_reason = second_search_method(subspace_mask, second_method_term_cond);