function recompute_timeslots_now ()
global OC;

% The 'needed_now' function looks at everything we need to recompute now,
% compared to what in principle is_stale, and (in principle) executes the
% optimal set of operations so that for everything which was marked
% 'needed_now' is up-to-date.
%
% It then updates the 'is_stale' to indicate what has been actually
% computed, and clears the 'needed_now'
%
% Assumption: the inter-dependence of H and U/L updates is taken care of in 'update_timeslot_controls'


U_recompute_now = OC.timeSlots.currPoint.U_needed_now & OC.timeSlots.currPoint.U_is_stale;
L_recompute_now = OC.timeSlots.currPoint.L_needed_now & OC.timeSlots.currPoint.L_is_stale;

% To recompute U, you need to start at a cell that is fully recomputed.
for t=(OC.timeSlots.nTimeSlots+1):(-1):2
    if U_recompute_now(t) && OC.timeSlots.currPoint.U_is_stale(t-1)
        U_recompute_now(t-1) = true;
    end
end
for t=1:(OC.timeSlots.nTimeSlots-1)
    if L_recompute_now(t) && OC.timeSlots.currPoint.L_is_stale(t+1)
        L_recompute_now(t+1) = true;
    end
end

% Now that we know which Us & Ls we need to recompute, we can figure out which Ps and Hs must be up-to-date
P_recompute_now = (U_recompute_now(2:end) | L_recompute_now(1:(end-1)) | OC.timeSlots.currPoint.P_needed_now) & OC.timeSlots.currPoint.P_is_stale;
H_recompute_now = (P_recompute_now | OC.timeSlots.currPoint.H_needed_now) & OC.timeSlots.currPoint.H_is_stale;

% Compute the Hamiltonians
h_idx = find(H_recompute_now);
for t=h_idx
    H = OC.config.hamDrift;
    for ctrl = 1:length(OC.config.hamControl)
        H = H + OC.timeSlots.currPoint.controls(t,ctrl) * OC.config.hamControl{ctrl};
    end
    OC.timeSlots.currPoint.H{t} = H;
end

% Compute the exp(H) and any other per-H computation which may be needed for the gradient function
p_idx = find(P_recompute_now);
for t=p_idx
    OC.timeSlots.calcPfromHfunc(t); % Compute the Ps - a single piece of propagator
    % Note: calcPfromHfunc may also compute other values which will be needed for gradient calculations
    %       These should be stored in OC.timeSlots.currPoint Their up-to-date-ness is identical to that of P
end

% Compute the Us - forward propagation (we never recompute U{1})
u_idx = find (U_recompute_now);
for t=u_idx
    OC.timeSlots.currPoint.U{t} = OC.timeSlots.currPoint.P{t-1} * OC.timeSlots.currPoint.U{t-1};
end

% Compute the Ls - backward propagation
el_idx = fliplr(find (L_recompute_now));
for t=el_idx
    OC.timeSlots.currPoint.L{t} = OC.timeSlots.currPoint.L{t+1} * OC.timeSlots.currPoint.P{t};
end

% Mark what has been actually computed
OC.timeSlots.currPoint.H_is_stale(H_recompute_now) = false;
OC.timeSlots.currPoint.P_is_stale(P_recompute_now) = false;
OC.timeSlots.currPoint.U_is_stale(U_recompute_now) = false;
OC.timeSlots.currPoint.L_is_stale(L_recompute_now) = false;
OC.timeSlots.currPoint.H_needed_now = false(1,OC.timeSlots.nTimeSlots);
OC.timeSlots.currPoint.P_needed_now = false(1,OC.timeSlots.nTimeSlots);
OC.timeSlots.currPoint.U_needed_now = false(1,OC.timeSlots.nTimeSlots+1);
OC.timeSlots.currPoint.L_needed_now = false(1,OC.timeSlots.nTimeSlots+1);
