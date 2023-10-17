using Distributed

@everywhere include("test_maker.jl")

timeout = 240

instances = load_instances("testsTwoMachines")

filter!(x->x.n≤10, instances)

functions = get_functions("Algorithm2_TwoMachinesJobShop", "Branch and Bound - 1|r_j|Lmax", "Shifting Bottleneck", "Shifting Bottleneck - DPC")

n = length(instances) * length(functions)

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "result3.csv")
