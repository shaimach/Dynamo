%% Demo 0 for the DYNAMO Quantum Optimal Control platform
%
% DYNAMO - Quantum Dynamic Optimization Package
% (c) Shai Machnes 2010, Institute of Theoretical Physics, Ulm University, Germany
% email: shai.machnes at uni-ulm.de
%
% All computer programs/code/scripts are released under the terms of the 
% GNU Lesser General Public License 3.0, except where explicitly 
% stated otherwise. Everything else (documentation, algorithms, etc) is 
% licensed under the Creative Commons Attribution-Share Alike 3.0 License
% (see "LICENSE.txt" for details). 
%
% For the latest version, visit http://www.qlib.info
%

%% What this demo does

clc

fprintf ('This short demo will optimize a simple two-qubit QFT gate generation problem using the DYNAMO package, with the GRAPE search algorithm\n');
fprintf ('(GRAPE, depending on the specific problem does a decent to great job in terms of performance)\n');
fprintf ('\n');
fprintf ('If your interests are focused on finding optimal control sequences for your specific system - this file is all you need to understand.\n');
fprintf ('\n');

%% Define the physics of the problem - part 1

nSpins = 2;

%% Preparations

dynamo_structure_init(nSpins); % All definitions are in a global variable called OC
global OC; % and now we can access it too

SX = [0 1; 1 0];
SY = [0 -1i; 1i 0];
SZ = [1 0; 0 -1];
SI = eye(2)/2;

%% Define the physics of the problem - part 2

nSpins = 2;

OC.config.hamDrift = (1/2) * ( kron(SX,SX) + kron(SY,SY) + kron(SZ,SZ) );              % Drift Hamiltonian
OC.config.hamControl = {kron(SX,SI), kron(SY,SI), kron(SI,SX), kron(SI,SY)};

OC.config.uInitial = eye(2 ^ nSpins);
OC.config.uFinal = qft(nSpins);

OC.config.totalTime = 6 * (nSpins-1) / 1; % How much time do we have to drive the system? The value specified here has empirically been shown to work well

switch 'PSU' % Set space for goal function (see paper for discussion)
    case 'PSU' % "I don't care about global phase"
        OC.config.normFunc = @PSU_norm;
        OC.config.gradientNormFunc = @gradient_PSU_norm;
    case 'SU' % "I care about global phase"
        OC.config.normFunc = @SU_norm;
        OC.config.gradientNormFunc = @gradient_SU_norm;
    otherwise
        error ('Currently only SU and PSU norms are supported');
end

% Time-slot configuration. Assumption is of equally-sized timeslots, unless otherwise specified in OC.timeSlots.tau
OC.timeSlots.nTimeSlots = 500; % Number of time slices to specify the control fields
OC.config.controlsInitialScaling = 1;  
randseed(101); % Optional. Allows the same peudo-random initial controls to be generated on every run (helpful for debugging purposes, for example)
initial_controls = OC.config.controlsInitialScaling * (rand(OC.timeSlots.nTimeSlots, length(OC.config.hamControl)) - 0.5); % Generate random initial values
intialize_timeslot_controls (initial_controls);
controls_mask = true(OC.timeSlots.nTimeSlots, OC.config.numControls); % Which time slots do you want to modify ? All of them

% Final preperatory configuration
initSetNorm(); % Calculates the norm of the <initial | final> to scale subsequent norms

%% Now do the actual search


termination_conditions = struct( ...
    'loop_count',           1e10, ...
    'goal',                 1 - 1e-6, ...
    'wall_time_to_stop',    180, ...
    'cputime_to_stop',      180, ...
    'gradient_norm_min',    1e-20);

wall0 = now(); cpu0 = cputime(); fprintf ('Optimizing algorithm: GRAPE (BFGS 2nd order update scheme, updating all time slices concurrently)\n\n    Please wait, this may take a while (~15 secs on my laptop) ... \n\n'); drawnow;

OC.config.gradientFunc = @gradient_exact; % Which sort of gradient to use
OC.timeSlots.calcPfromHfunc = @calcPfromH_exact_gradient; % When computing exact gradient, we get exponentiation for free due to the eigendecomposition (see paper for details)
OC.config.BFGS = struct('fminopt', struct('Display', 'off'));
termination_reason = BFGS_search_function (controls_mask,termination_conditions);

fprintf('Fidelity reached: 1 - %g\n    Wall time: %g\n    CPU time:  %g\nTermination reason: %s\n\n\n', 1-get_current_value(),(now()-wall0)*(24*60*60), cputime()-cpu0, OC.const.termination_reason_str{termination_reason});

plot(cumsum(OC.timeSlots.tau),OC.timeSlots.currPoint.controls);
title ('Optimized Control Sequences'); xlabel ('Time'); ylabel('Control amplitude'); grid on; axis tight;