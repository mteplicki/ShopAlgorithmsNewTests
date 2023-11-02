# 3 -pracownik około 2 godzin

using Distributed

@everywhere include("test_maker.jl")

const timeout::Int = 4000

const instances = load_instances("testsFromBenchmarks")

filter!(x->!(x.n>=20 && x.n >= 15), instances)

const functions = get_functions("Branch and Bound - 1|r_j|Lmax", "Branch and Bound - Carlier", "Shifting Bottleneck")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsRecirculation/resultbandb.csv")
