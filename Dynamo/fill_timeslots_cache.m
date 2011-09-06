function fill_timeslots_cache()
% Will invalidate everything, then re-calc everything in the cache
% Used mostly for debugging (since it essentially overrides all matrix-op optimization mechanisms)

global OC;

invalidate_timeslots_calc_cache();
OC.timeSlots.currPoint.H_needed_now(:) = true;
OC.timeSlots.currPoint.P_needed_now(:) = true;
OC.timeSlots.currPoint.U_needed_now(:) = true;
OC.timeSlots.currPoint.L_needed_now(:) = true;

recompute_timeslots_now();
get_current_value();
