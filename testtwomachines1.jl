# 1 pracownik, około 9 godzin
using Distributed

@everywhere include("test_maker.jl")

timeout = 720

instances = load_instances("testsTwoMachines")

functions = get_functions("Shifting Bottleneck - DPC with timeout 0.5 with depth 0", "Shifting Bottleneck - DPC with timeout 0.5 with depth 1", "Shifting Bottleneck - DPC with timeout 10.0 with depth 1", "Shifting Bottleneck - DPC with timeout 10.0 with depth 0")

n = length(instances) * length(functions)

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoMachines/resultmemory.csv"; garbage_collect = true)
