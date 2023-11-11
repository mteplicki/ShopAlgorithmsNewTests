# 3 pracowników
using Distributed

@everywhere include("test_maker.jl")

# ------------------------------ #

timeout = 60

instances = load_instances("testsTwoJobsM2")

functions = get_functions(
    "Two jobs job shop - geometric approach"
    )

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoJobs/resultM2.csv"; compress = true)

# ------------------------------ #

timeout = 120

instances = load_instances("testsTwoJobsM1")

functions = get_functions(
    "Branch and Bound - Carlier", 
    "Branch and Bound - 1|r_j|Lmax")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoJobs/resultM1.csv"; compress = true)
