# 3 pracownik około 2 godzin
using Distributed

@everywhere include("test_maker.jl")

timeout = 480

instances = load_instances("testsTwoMachinesN")

functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - Carlier", "Branch and Bound - Carlier", "Branch and Bound - 1|r_j|Lmax", "Shifting Bottleneck - DPC with timeout 0.5 with depth 0", "Shifting Bottleneck - DPC with timeout 0.5 with depth 1", "Shifting Bottleneck - DPC with timeout 10.0 with depth 1", "Shifting Bottleneck - DPC with timeout 10.0 with depth 0")

n = length(instances) * length(functions)

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoMachines/resultspeedN.csv"; garbage_collect = true)

