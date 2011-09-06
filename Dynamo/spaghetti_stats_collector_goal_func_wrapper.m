function v = spaghetti_stats_collector_goal_func_wrapper(goal_func, x)
global OC;

v = goal_func(x);

OC.stats.goal_value(end+1)      = v;
OC.stats.goal_cpu_time(end+1)   = cputime();
OC.stats.goal_wall_time(end+1)  = now();
