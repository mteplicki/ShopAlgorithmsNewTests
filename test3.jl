using Distributed

@everywhere include("test_maker.jl")

timeout = 240

instances = load_instances("testsTwoJobs")

functions = get_functions("Branch and Bound - 1|r_j|Lmax", "Shifting Bottleneck", "Shifting Bottleneck - DPC", "Two jobs job shop - geometric approach")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "result4.csv")
