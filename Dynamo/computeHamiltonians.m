function O = computeHamiltonians(O)
O.hamTotal = cell(O.numTimeSlices, 1);
for t = 1:O.numTimeSlices
    O.hamTotal{t} = O.hamDrift;
    for ctrl = 1:O.numControls
        O.hamTotal{t} = O.hamTotal{t} + O.controls(t,ctrl) * O.hamControl{ctrl};
    end
end
end
