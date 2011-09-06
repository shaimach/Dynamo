function ret = filter_by_subspace_mask(value, subset_mask)

subset_mask = logical(subset_mask);
value (~subset_mask) = NaN;

timeslot_mask = sum(subset_mask,2) > 0;

ret = value(timeslot_mask,:);
