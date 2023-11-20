# 3 pracownik około 2 godzin
using Distributed

@everywhere include("test_maker.jl")

@everywhere timeout = 480

@everywhere instances = load_instances("testsWithRecirculation")

@everywhere functions = get_functions("Shifting Bottleneck", "Shifting Bottleneck - DPC", "Shifting Bottleneck - Carlier", "Shifting Bottleneck - DPC with timeout 10.0 with depth 0", "Shifting Bottleneck - DPC with timeout 10.0 with depth 1")

@everywhere instances_with_functions = mix_instances_with_functions(instances, functions)

make_tests(instances_with_functions, timeout, "results/resultsRecirculation/result_dpc.csv")
