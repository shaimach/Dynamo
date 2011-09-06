function spaghetti_stats_collector_init()
global OC;

if ~isfield(OC,'stats')
    OC.stats = struct();
    OC.stats.goal_value      = [];
    OC.stats.goal_cpu_time   = [];
    OC.stats.goal_wall_time  = [];
end

