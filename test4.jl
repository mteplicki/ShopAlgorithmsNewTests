using Distributed

@everywhere include("test_maker.jl")

timeout = 240

instances = load_instances("testsFromBenchmarks")

# filter!(x->maximum(x.n_i) <= 90, instances)

functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - DPC")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsFromBenchmarks/result1.csv")
