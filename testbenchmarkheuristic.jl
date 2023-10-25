# 3 pracownik około 2 godzin
using Distributed

@everywhere include("test_maker.jl")

timeout = 240

instances = load_instances("testsFromBenchmarks")

functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - DPC", "Shifting Bottleneck - DPC with stack", "Shifting Bottleneck - DPC with timeout 5.0", "Shifting Bottleneck - DPC with timeout 30.0")

instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsFromBenchmarks/result_sb.csv")
