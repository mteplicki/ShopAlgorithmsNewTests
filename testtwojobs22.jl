# 3 pracowników
using Distributed

@everywhere include("test_maker.jl")

timeout = 60

instances = load_instances("testsTwoJobs2")

functions = get_functions(
    # "Shifting Bottleneck", 
    # "Shifting Bottleneck - DPC", 
    "Two jobs job shop - geometric approach", 
    # "Shifting Bottleneck - DPC with stack", 
    # "Shifting Bottleneck - DPC with timeout 0.5 with depth 0", 
    # "Shifting Bottleneck - DPC with timeout 0.5 with depth 1", 
    # "Shifting Bottleneck - DPC with timeout 10.0 with depth 1", 
    # "Shifting Bottleneck - DPC with timeout 10.0 with depth 0",
    # "Branch and Bound - Carlier", 
    # "Branch and Bound - 1|r_j|Lmax"
    )

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoJobs/result22.csv")
