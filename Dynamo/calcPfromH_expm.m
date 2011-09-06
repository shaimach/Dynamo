function calcPfromH_expm(t)

global OC;

OC.timeSlots.currPoint.P{t} = OC.timeSlots.expmFunc(- 1i * OC.timeSlots.tau(t) * OC.timeSlots.currPoint.H{t});

