# 3 pracowników
using Distributed

@everywhere include("test_maker.jl")

timeout = 60

instances = load_instances("testsTwoJobs")

functions = get_functions(
    "Shifting Bottleneck - DPC",
    "Shifting Bottleneck - DPC with stack",
    "Shifting Bottleneck - DPC with timeout 10.0 with depth 0")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoJobs/result2.csv")
