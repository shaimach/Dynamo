function update_timeslot_controls (new_control_values, subspace_mask)
% update_timeslot_controls (new_control_values, subspace_mask)
%       new_control_values - Control value matrix, 
% update_timeslot_controls will set the new control values (the values in new_control_values for which subspace_mask is true)
%
global OC;

if nargin == 1
    subspace_mask = true(size(OC.timeSlots.currPoint.controls));
else % We have a real subspace mask. Embed new values in existing parameter space
    ncv = OC.timeSlots.currPoint.controls;
    ncv(subspace_mask) = new_control_values;
    new_control_values = ncv;
end


old_controls = OC.timeSlots.currPoint.controls;
old_controls(~subspace_mask) = 0;
new_controls = old_controls;
new_controls(subspace_mask) = new_control_values(subspace_mask);

changed_t_mask = any(new_controls ~= old_controls,2);

if ~isempty(changed_t_mask)
    OC.timeSlots.currPoint.H_is_stale(changed_t_mask) = true;
    OC.timeSlots.currPoint.P_is_stale(changed_t_mask) = true;
    OC.timeSlots.currPoint.controls(subspace_mask) = new_control_values(subspace_mask);
    
    % Propagate the H_is_stale to the U and Ls.
    OC.timeSlots.currPoint.U_is_stale( (find(OC.timeSlots.currPoint.H_is_stale, 1, 'first')+1):end) = true;
    OC.timeSlots.currPoint.L_is_stale(1:find(OC.timeSlots.currPoint.H_is_stale, 1, 'last'))         = true;
    
    OC.timeSlots.currPoint.curr_Phi0_val_stale = true;
    OC.timeSlots.currPoint.curr_Phi0_val = NaN;
end

