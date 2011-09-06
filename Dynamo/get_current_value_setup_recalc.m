function t = get_current_value_setup_recalc ()
global OC;

% Future work: Optimally, we can search for the time which will require minimum calculations to compute the value.
% However, this is tricky (we need to count the expensive H-->P computations (expm or similar) and maybe weigh-in the cheap
% U and L updates (matrix multiplications).

% But for now, we'll do a sub-optimal algorithm and take the left-most L that is up-to-date (and therefore update all L-s to the
% right of it). If all the slots updated are in a single block, we'll be optimal

flags = (~OC.timeSlots.currPoint.U_is_stale) + (~OC.timeSlots.currPoint.L_is_stale)*2;

flag3 = find(flags==3,1,'first');
if ~isempty(flag3)
    t = flag3;
else
    p1 = find(flags>0);
    p2 = find((flags(p1(1:(end-1)))==1) .* (flags(p1(2:end))==2)); % For some reason it refuses an && on a vector of booleans, so I used .* instead
    if isempty(p2); error ('There should be at least one'); end;
    cost = p1(p2+1)-p1(p2);
    [~,mincostpos] = min(cost);
    t = p1(p2(mincostpos));
end
OC.timeSlots.currPoint.U_needed_now(t) = true;
OC.timeSlots.currPoint.L_needed_now(t) = true;

