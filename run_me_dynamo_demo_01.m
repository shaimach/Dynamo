%% Demo 1 for the DYNAMO Quantum Optimal Control platform
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

fprintf ('This demo will optimize a simple two-qubit QFT gate generation problem using a wide variety of algorithms\n');
fprintf ('\n');
fprintf ('If your interests are focued on finding optimal control sequences for your specific system, please refer to demo 00.\n');
fprintf ('However, if you are interested in OC algorithm research, this is the place for you.\n');
fprintf ('\n\n');

%% Define the physics of the problem - Part 1

nSpins = 2;

%% Preparations

dynamo_structure_init(nSpins); % All definitions are in a global variable called OC
global OC; % and now we can access it too

SX = [0 1; 1 0];
SY = [0 -1i; 1i 0];
SZ = [1 0; 0 -1];
SI = eye(2)/2;

%% Define the physics of the problem 

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
OC.timeSlots.nTimeSlots = 500; % Number of timeslices to specify the control fields
OC.config.controlsInitialScaling = 1;  
randseed(101); % Optional. Allows the same peudo-random initial controls to be generated on every run (helpful for debugging purposes, for example)
initial_controls = OC.config.controlsInitialScaling * (rand(OC.timeSlots.nTimeSlots, length(OC.config.hamControl)) - 0.5); % Generate random initial values
intialize_timeslot_controls (initial_controls);
controls_mask = true(OC.timeSlots.nTimeSlots, OC.config.numControls); % Which time slots do you want to modify ? All of them

% Final preperatory configuration
initSetNorm(); % Calculates the norm of the <initial | final> to scale subsequent norms

%% Now some search methods

% Setup ---------------------------------------------------------------------------------

OC.config.gradientFunc = @gradient_exact;
OC.timeSlots.calcPfromHfunc = @calcPfromH_exact_gradient;


% Which time slots do you want to modify ?
controls_mask = true(OC.timeSlots.nTimeSlots, OC.config.numControls); % All of them
controls_mask(40:45, :) = false; % Keep these at initial random value, for no good reason other than demoing capabilities

% Try various methods ------------------------------------------------------------------

termination_conditions = struct( ...
    'loop_count',           1e10, ...
    'goal',                 1 - 1e-6, ...
    'wall_time_to_stop',    60, ...
    'cputime_to_stop',      60, ...
    'gradient_norm_min',    1e-20);

wall0 = now(); cpu0 = cputime(); fprintf ('Krotov (1st order update scheme, serial timeslot update - 1 step per timeslot)\n'); drawnow;
termination_reason = Krotov_search_function (controls_mask, termination_conditions);
fprintf('Goal reached: 1 - %g\n    Wall time: %g\n    CPU time:  %g\nTermination reason: %s\n\n\n', 1-get_current_value(),(now()-wall0)*(24*60*60), cputime()-cpu0, OC.const.termination_reason_str{termination_reason});
invalidate_timeslots_calc_cache(); intialize_timeslot_controls (initial_controls);

wall0 = now(); cpu0 = cputime(); fprintf ('1st order update scheme, modifying all timeslices concurrently (at each step)\n'); drawnow;
termination_reason = First_order_search_function (controls_mask,termination_conditions);
fprintf('Goal reached: 1 - %g\n    Wall time: %g\n    CPU time:  %g\nTermination reason: %s\n\n\n', 1-get_current_value(),(now()-wall0)*(24*60*60), cputime()-cpu0, OC.const.termination_reason_str{termination_reason});
invalidate_timeslots_calc_cache(); intialize_timeslot_controls (initial_controls);

wall0 = now(); cpu0 = cputime(); fprintf ('GRAPE (BFGS, all timeslices)\n'); drawnow;
OC.config.BFGS = struct('fminopt', struct('Display', 'off'));
termination_reason = BFGS_search_function (controls_mask,termination_conditions);
fprintf('Goal reached: 1 - %g\n    Wall time: %g\n    CPU time:  %g\nTermination reason: %s\n\n\n', 1-get_current_value(),(now()-wall0)*(24*60*60), cputime()-cpu0, OC.const.termination_reason_str{termination_reason});
invalidate_timeslots_calc_cache(); intialize_timeslot_controls (initial_controls);

% And now some hybrid schemes

per_block_termination_conditions = struct( ...
    'loop_count',           10, ...
    'goal',                 1 - 1e-6, ...
    'wall_time_to_stop',    6, ...
    'cputime_to_stop',      6, ...
    'gradient_norm_min',    1e-20);
meta_block_termination_conditions = struct( ...
    'loop_count',           1e4, ...
    'goal',                 1 - 1e-6, ...
    'wall_time_to_stop',    60, ...
    'cputime_to_stop',      60, ...
    'gradient_norm_min',    1e-20);

wall0 = now(); cpu0 = cputime(); fprintf ('Hybrid scheme: 1st order update method, updating 12 timeslices on each step, 10 steps per block before moving on to the next 12 timeslices\n'); drawnow;
termination_reason = Block_cycle_search_function (controls_mask, meta_block_termination_conditions, per_block_termination_conditions, @First_order_search_function, 12);
fprintf('Goal reached: 1 - %g\n    Wall time: %g\n    CPU time:  %g\nTermination reason: %s\n\n\n', 1-get_current_value(),(now()-wall0)*(24*60*60), cputime()-cpu0, OC.const.termination_reason_str{termination_reason});
invalidate_timeslots_calc_cache(); intialize_timeslot_controls (initial_controls);

first_stage_termination_condition = termination_conditions;
first_stage_termination_condition.goal = 1 - 0.1;
wall0 = now(); cpu0 = cputime(); fprintf ('Crossover demo: start with Krotov, finish with GRAPE. Crossover on goal of 1-%g\n', 1-first_stage_termination_condition.goal); drawnow;
termination_reason = Two_method_crossover_function (controls_mask, first_stage_termination_condition, @Krotov_search_function, termination_conditions, @BFGS_search_function);
fprintf('Goal reached: 1 - %g\n    Wall time: %g\n    CPU time:  %g\nTermination reason: %s\n\n\n', 1-get_current_value(),(now()-wall0)*(24*60*60), cputime()-cpu0, OC.const.termination_reason_str{termination_reason});
invalidate_timeslots_calc_cache(); intialize_timeslot_controls (initial_controls);

fprintf('\n\nAll done\n');
tmp=load('handel.mat'); sound(tmp.y(1600:18000), tmp.Fs);