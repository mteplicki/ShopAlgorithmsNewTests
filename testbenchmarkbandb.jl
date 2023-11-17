using Distributed

@everywhere include("test_maker.jl")

const timeout::Int = 4000

instances = load_instances("testsFromBenchmarks")

filter!(x->(x.n<=15 && x.m <= 10), instances)

my_functions = get_functions("Branch and Bound - 1|R_j|Lmax", "Branch and Bound - Carlier")

instances_with_functions = mix_instances_with_functions(instances, my_functions)

make_tests(instances_with_functions, timeout, "results/resultsFromBenchmarks/resultbandb.csv"; garbage_collect=true)

instances = load_instances("testsFromBenchmarks")

filter!(x->(x.n<=15 && x.m <= 10), instances)

my_functions = get_functions("Branch and Bound - Carlier with Stack")

instances_with_functions = mix_instances_with_functions(instances, my_functions)

make_tests(instances_with_functions, timeout, "results/resultsFromBenchmarks/resultbandb2.csv"; garbage_collect=true)



