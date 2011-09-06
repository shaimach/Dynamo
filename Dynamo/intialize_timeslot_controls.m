function intialize_timeslot_controls (control_values)
global OC;

OC.config.numControls = length(OC.config.hamControl);

if ~isfield(OC.timeSlots,'tau') || isempty(OC.timeSlots.tau) || any(isnan(OC.timeSlots.tau))
    OC.timeSlots.tau = OC.config.totalTime/OC.timeSlots.nTimeSlots * ones(1,OC.timeSlots.nTimeSlots);
end

OC.timeSlots.currPoint = struct();

OC.timeSlots.currPoint.controls = NaN(size(control_values));

OC.timeSlots.currPoint.H = cell(1,OC.timeSlots.nTimeSlots);
OC.timeSlots.currPoint.P = cell(1,OC.timeSlots.nTimeSlots);     % expm(OC.timeSlots.currPoint.H) or similar. Needs to be computed by OC.timeSlots.calcPfromHfunc
OC.timeSlots.currPoint.U = cell(1,OC.timeSlots.nTimeSlots+1);   % U{1}   = uInitial; U{k+1} = OC.timeSlots.currPoint.P{k} * U{k}; % U{k} is state at time sum(OC.timeSlots.currPointtau(1:(k-1))
OC.timeSlots.currPoint.U{1} = OC.config.uInitial; 
OC.timeSlots.currPoint.L = cell(1,OC.timeSlots.nTimeSlots+1);   % L{end} = uFinal';  L{k-1} = L{k} * OC.timeSlots.currPoint.P{k}; % L{k} is state at time sum(OC.timeSlots.currPointtau(1:(k-1))
OC.timeSlots.currPoint.L{end} = OC.config.uFinal';

% Keep track of what needs re-computation if we want a complete update of everything
OC.timeSlots.currPoint.H_is_stale = true(1,OC.timeSlots.nTimeSlots);
OC.timeSlots.currPoint.P_is_stale = true(1,OC.timeSlots.nTimeSlots);
OC.timeSlots.currPoint.U_is_stale = [false true(1,OC.timeSlots.nTimeSlots)];   % Updates for H via 'update_timeslot_controls' get propagated automatically
OC.timeSlots.currPoint.L_is_stale = [true(1,OC.timeSlots.nTimeSlots) false];

% Here we indicate which values we need to have up-to-date
% The 'needed_now' function looks at everything we need to recompute now, 
% compared to what in principle is_stale, and (in principle) executes the
% optimal set of operations so that for everything which was marked
% 'needed_now' is up-to-date
OC.timeSlots.currPoint.H_needed_now = false(1,OC.timeSlots.nTimeSlots);   % Example: We modified H{3}, so in theory we need to recompute U{4:end} 
OC.timeSlots.currPoint.P_needed_now = false(1,OC.timeSlots.nTimeSlots);   % But for our immediate needs we only want U{7} and L{7}
OC.timeSlots.currPoint.U_needed_now = false(1,OC.timeSlots.nTimeSlots+1); % So we mark U{4:end} as "is_stale", but only 4:7 as "needed_now"
OC.timeSlots.currPoint.L_needed_now = false(1,OC.timeSlots.nTimeSlots+1); 

% Note - certain gradient methods may cache additional computations

OC.timeSlots.currPoint.curr_Phi0_val_stale = true;
OC.timeSlots.currPoint.curr_Phi0_val = NaN;

update_timeslot_controls(control_values);
