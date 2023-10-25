# 3 pracowników
using Distributed

@everywhere include("test_maker.jl")

timeout = 120

instances = load_instances("testsTwoJobs2")

functions = get_functions(
    # "Shifting Bottleneck", 
    # "Shifting Bottleneck - DPC", 
    "Two jobs job shop - geometric approach", 
    # "Shifting Bottleneck - DPC with stack", 
    "Shifting Bottleneck - DPC with timeout 5.0", 
    "Shifting Bottleneck - DPC with timeout 30.0", 
    # "Branch and Bound - Carlier", 
    # "Branch and Bound - 1|r_j|Lmax"
    )

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoJobs/resultM.csv")
