using Distributed

@everywhere include("test_maker.jl")

const timeout = 120

const instances = load_instances("testsFromBenchmarks")

# filter!(x->!(x.n>=20 && x.n >= 15), instances)

const functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - DPC")

const instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsFromBenchmarks/resultheuristics.csv")
