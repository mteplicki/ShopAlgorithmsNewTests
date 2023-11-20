# 3 -pracownik około 2 godzin

using Distributed

@everywhere include("test_maker.jl")

@everywhere const timeout::Int = 4000

@everywhere const instances = load_instances("testsNoRcrc")

@everywhere const functions = get_functions("Branch and Bound - Carlier", "Branch and Bound - Carlier with Stack")

@everywhere instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsNoRcrc/resultbandb.csv")
