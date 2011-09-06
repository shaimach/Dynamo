function invalidate_timeslots_calc_cache ()
global OC;

OC.timeSlots.currPoint.H_is_stale(:) = true;
OC.timeSlots.currPoint.P_is_stale(:) = true;
OC.timeSlots.currPoint.U_is_stale(2:end) = true;
OC.timeSlots.currPoint.L_is_stale(1:(end-1)) = true;
OC.timeSlots.currPoint.curr_Phi0_val_stale = true;
