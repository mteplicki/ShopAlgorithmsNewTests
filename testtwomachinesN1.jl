# 1 pracownik, około 9 godzin
using Distributed

@everywhere include("test_maker.jl")

timeout = 720

instances = load_instances("testsTwoMachinesN")

functions = get_functions("Algorithm2_TwoMachinesJobShop")

n = length(instances) * length(functions)

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsTwoMachines/resultmemoryN.csv"; garbage_collect = true)
