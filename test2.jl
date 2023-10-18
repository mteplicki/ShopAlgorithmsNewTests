using Distributed

@everywhere include("test_maker.jl")

timeout = 240

instances = load_instances("testsTwoJobs")
filter!(x->maximum(x.n_i) <= 50, instances)

functions = get_functions("Branch and Bound - 1|r_j|Lmax")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "resultbandb.csv")
