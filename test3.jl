using Distributed

@everywhere include("test_maker.jl")

timeout = 120

instances = load_instances("testsTwoJobs")

filter!(x->maximum(x.n_i) <= 90, instances)

functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - DPC", "Two jobs job shop - geometric approach")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "result5.csv")
