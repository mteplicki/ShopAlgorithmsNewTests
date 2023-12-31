# 3 pracownik około 2 godzin
using Distributed

@everywhere include("test_maker.jl")

timeout = 480

instances = load_instances("testsTwoMachines")

functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - Carlier", "Branch and Bound - Carlier", "Branch and Bound - 1|R_j|Lmax")

n = length(instances) * length(functions)

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoMachines/resultspeed.csv"; garbage_collect = true)

