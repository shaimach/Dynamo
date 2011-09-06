function [value_at_point, grad] = gradient_exact (subspace_mask)
global OC;

if ~isfield(OC.timeSlots.currPoint,'H_eigVal')
    OC.timeSlots.currPoint.H_eigVal    = cell(1, OC.timeSlots.nTimeSlots);
    OC.timeSlots.currPoint.H_eigVec    = cell(1, OC.timeSlots.nTimeSlots);
    OC.timeSlots.currPoint.H_factorMat = cell(1, OC.timeSlots.nTimeSlots);
end

grad = zeros(OC.timeSlots.nTimeSlots,length(OC.config.hamControl));

% request calculations
slot_mask = any(subspace_mask,2);
OC.timeSlots.currPoint.H_needed_now(slot_mask) = true;
OC.timeSlots.currPoint.P_needed_now(slot_mask) = true;
OC.timeSlots.currPoint.U_needed_now([slot_mask; false]) = true;
OC.timeSlots.currPoint.L_needed_now([false; slot_mask]) = true;


value_at_point = get_current_value_Phi0_norm(); % Important: Gradient functions live in the Phi0 space. Wrappers take care of conversion to SU/PSU
recompute_timeslots_now();

[Ts,Ctrls]=ind2sub(size(subspace_mask),find(subspace_mask));
for z=1:length(Ts)
    t = Ts(z);
    ctrl = Ctrls(z);
    
    ctrlH_in_deriv_basis = OC.timeSlots.currPoint.H_eigVec{t}' * (-1i * OC.timeSlots.tau(t) * OC.config.hamControl{ctrl}) * OC.timeSlots.currPoint.H_eigVec{t};
    ctrlH_times_factorMat_in_deriv_basis = ctrlH_in_deriv_basis .* OC.timeSlots.currPoint.H_factorMat{t}; % I_mk
    ctrlH_times_factorMat = OC.timeSlots.currPoint.H_eigVec{t} * ctrlH_times_factorMat_in_deriv_basis * OC.timeSlots.currPoint.H_eigVec{t}';
    grad(t,ctrl) = Phi0_norm (OC.timeSlots.currPoint.L{t+1} * ctrlH_times_factorMat * OC.timeSlots.currPoint.U{t});
    
end

grad = filter_by_subspace_mask (grad, subspace_mask);


