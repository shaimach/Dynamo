function dynamo_structure_init(num_spins)

global OC;
if numel(OC)==0
    disp (' ');
    disp ('DYNAMO - Quantum Dynamic Optimization Package v1.0');
    disp (' ');
    disp (' ');
    disp ('(c) Shai Machnes 2010, Institute of Theoretical Physics, Ulm University, Germany');
    disp ('email: shai.machnes at uni-ulm.de');
    disp (' ');
    disp ('All computer programs/code/scripts are released under the terms of the GNU Lesser General Public License 3.0 and Creative-Commons Attribution Share-Alike (see "LICENSE.txt" for details).');
    disp ('  ');
    disp ('If you use DYNAMO in your research, please add an attribution in the form of the following reference: S. Machnes et al, arXiv 1011.4874');
    disp (' ');
    disp ('For the latest version of this software, guides and information, visit http://www.qlib.info');
    disp ('  ');
    disp ('DYNAMO initialized successfully.');
    disp ('  ');    
    disp ('  ');
    drawnow;
end

OC = struct();


OC.config.uInitial = NaN(2 ^ num_spins);
OC.config.uFinal = NaN(2 ^ num_spins);

OC.config.numControls = NaN;

OC.config.totalTime = NaN;

OC.config.controlsInitialScaling = NaN;

OC.config.normType = 'PSU'; % 'SU' and 'PSU' supported

OC.timeSlots = struct();
OC.timeSlots.nTimeSlots = NaN;
OC.timeSlots.expmFunc = @expm;
OC.timeSlots.calcPfromHfunc = @calcPfromH_expm;

OC.config.gradientFunc = @gradient_exact;
OC.timeSlots.calcPfromHfunc = @calcPfromH_exact_gradient;

OC.const = struct();
OC.const.termination_reason = struct( ...
    'goal_achieved',    1, ...
    'loop_count',       2, ...
    'wall_time',        3, ...
    'cpu_time',         4, ...
    'gradient_norm',    5);
OC.const.termination_reason_str = { ...
    'Goal achieved', ...
    'Loop count limit reached', ...
    'Wall time limit reached', ...
    'CPU time limit reached', ...
    'Minimal gradient norm reached'};

OC.config.hamDrift = NaN(2^num_spins);
OC.config.hamControl = {NaN(2^num_spins), NaN(2^num_spins)};
OC.config.normFunc = @PSU_norm;
OC.config.gradientNormFunc = @gradient_PSU_norm;


