function [value_at_point, gradient] = gradient_finite_diff (subspace_mask, epsilon)
% Gradient by finite difference method: f'(x) = (f(x+eps) - f(x))/eps (trivial and relatively slow, but a good reference point)

global OC;

gradient = NaN(size(subspace_mask));

% Mask which Hs, Us, & Ls we need for this calculation
% (it's more efficient to do so before we ask for the current_value, since then get_current_value's call to recompute_timeslots_now
% will be most efficient as it knows of all calculations needed at one, and not piece-meal).
for t=1:size(subspace_mask,1)
    OC.timeSlots.currPoint.H_needed_now(t) = true;
    if any(subspace_mask(t,:))
        OC.timeSlots.currPoint.U_needed_now(t) = true;
        OC.timeSlots.currPoint.L_needed_now(t+1) = true;
    end
end

value_at_point = get_current_value_Phi0_norm(); % Important: Gradient functions live in the Phi0 space. Wrappers take care of conversion to SU/PSU
recompute_timeslots_now();

for t=1:size(subspace_mask,1)
    for ctrl = 1:size(subspace_mask,2)
        if subspace_mask(t,ctrl)
            Heps = OC.timeSlots.currPoint.H{t} + epsilon * OC.config.hamControl{ctrl};
            P_epsilon = OC.timeSlots.expmFunc(- 1i * Heps * OC.timeSlots.tau(t));
            value_at_eps_point = Phi0_norm(P_epsilon * OC.timeSlots.currPoint.U{t}, OC.timeSlots.currPoint.L{t+1});
            % U is taken at time (t-1)dT. P_eps takes us forward dT, and LDagger continues from time t dT.
            gradient(t,ctrl) = (value_at_eps_point - value_at_point) / epsilon;
        end
    end
end
gradient = filter_by_subspace_mask (gradient, subspace_mask);
