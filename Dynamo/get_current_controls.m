function ret = get_current_controls(subspace_mask)
global OC;

if nargin==0
    ret = OC.timeSlots.currPoint.controls;
else
    ret = OC.timeSlots.currPoint.controls(subspace_mask);
end

