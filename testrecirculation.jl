# 3 -pracownik około 2 godzin

using Distributed

@everywhere include("test_maker.jl")

@everywhere const timeout::Int = 4000

@everywhere const instances = load_instances("testsWithRecirculation")

@everywhere filter!(x->(x.n * maximum(x.n_i) <= 100), instances)

@everywhere const functions = get_functions("Branch and Bound - 1|R_j|Lmax", "Branch and Bound - Carlier", "Branch and Bound - Carlier with Stack")

@everywhere instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsRecirculation/resultbandb.csv")
