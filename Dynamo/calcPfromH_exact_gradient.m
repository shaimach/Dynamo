function calcPfromH_exact_gradient(t)
global OC;
% Computed once per O.hamTotal{t}, i.e. once per time slot, for a specific settings of all controls for that slot
%
%                      if eigVal(j) <> eigVal(k):  (exp(eigVal(k)) - exp(eigVal(j)))/(eigVal(k)-eigVal(j))
% factorMat(j,k) =
%                      if eigVal(j) <> eigVal(k):   exp(eigVal(k))
% The coefficient for <v(j) | H | v(k)> is -1i * dT * factorMat(j,k)
%
% References: 
%     [1] arXiv 1011.4874 (http://arxiv.org/abs/1011.4874)
%     [2] T. Levante, T. Bremi, and R. R. Ernst, J. Magn. Reson. Ser. A 121, 167 (1996)
%     [3] K. Aizu, J. Math. Phys. 4, 762 (1963)
%     [4] R. M. Wilcox, J. Math. Phys. 8, 962 (1967)

minus_i_dt_H = -1i * OC.timeSlots.tau(t) * OC.timeSlots.currPoint.H{t};

N = length(minus_i_dt_H);

[eigVec, eigVal] = eig(minus_i_dt_H);
eigVal = reshape(diag(eigVal),[N,1]);
eigValExp = exp(eigVal);

eigVal_row_mat  = eigVal*ones(1,N);
eigVal_diff_mat = eigVal_row_mat - transpose(eigVal_row_mat); % eigVal_diff_mat(j,k) = eigVal(j) - eigVal(k)

eigValExp_row_mat = eigValExp*ones(1,N);
eigValExp_diff_mat = eigValExp_row_mat - transpose(eigValExp_row_mat); % eigValExp_diff_mat(j,k) = exp(eigVal(j)) - exp(eigVal(k))

degenerate_mask = abs(eigVal_diff_mat) < 1e-10;
eigVal_diff_mat(degenerate_mask) = 1; % To prevent division by zero in next step

factorMat = eigValExp_diff_mat ./ eigVal_diff_mat; % factorMat(j,k) = (exp(eigVal(j)) - exp(eigVal(k)))/(eigVal(j)-eigVal(k))
eigValExp_row_mat = eigValExp*ones(1,N);
factorMat(degenerate_mask) = eigValExp_row_mat(degenerate_mask); % For degenerate eigenvalues, the factor is just the exponent

% factorMat = transpose(factorMat);

OC.timeSlots.currPoint.H_eigVal{t} = eigVal;
OC.timeSlots.currPoint.H_eigVec{t} = eigVec;
OC.timeSlots.currPoint.H_factorMat{t} = factorMat;

OC.timeSlots.currPoint.P{t} = eigVec * diag(eigValExp) * eigVec';
