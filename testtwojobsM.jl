# 3 pracowników
using Distributed

@everywhere include("test_maker.jl")

timeout = 60

instances = load_instances("testsTwoJobsM")

functions = get_functions(
    "Two jobs job shop - geometric approach", 
    "Branch and Bound - Carlier", 
    "Branch and Bound - 1|r_j|Lmax"
    )

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoJobs/resultM.csv"; compress = true)
