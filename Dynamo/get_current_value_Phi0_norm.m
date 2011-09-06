function v = get_current_value_Phi0_norm()
global OC;

if ~OC.timeSlots.currPoint.curr_Phi0_val_stale 
    v = OC.timeSlots.currPoint.curr_Phi0_val;
    return;
end

at_which_t = get_current_value_setup_recalc();
recompute_timeslots_now();

v = Phi0_norm(OC.timeSlots.currPoint.U{at_which_t}, OC.timeSlots.currPoint.L{at_which_t});

OC.timeSlots.currPoint.curr_Phi0_val_stale = false;
OC.timeSlots.currPoint.curr_Phi0_val = v;


