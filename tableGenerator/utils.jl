algorithms_short_names = Dict(
    "Algorithm2_TwoMachinesJobShop" => "2m",
    "Branch and Bound - Carlier" => "bnbcarlier",
    "Branch and Bound - Carlier with Stack" => "bnbcarlier_s",
    "Branch and Bound - Carlier with stack" => "bnbcarlier_s",
    "Branch and Bound - 1|R_j|Lmax" => "bnb",
    "Shifting Bottleneck - DPC" => "sbdpc",
    "Shifting Bottleneck - DPC with timeout 0.5 with depth 0" => "sbdpc_t0.5_d0",
    "Shifting Bottleneck - DPC with timeout 0.5 with depth 1" => "sbdpc_t0.5_d1",
    "Shifting Bottleneck - DPC with timeout 10.0 with depth 0" => "sbdpc_t10_d0",
    "Shifting Bottleneck - DPC with timeout 10.0 with depth 1" => "sbdpc_t10_d1",
    "Shifting Bottleneck" => "sb",
    "Shifting Bottleneck - Carlier" => "sbcarlier",
    "Two jobs job shop - geometric approach" => "2j"
)

instance_order = cd(raw"D:\Studia\sem7\ShopAlgorithmsNewTests\tests.jl\testsFromBenchmarks") do 
    Dict((String(split(y,".")[1])=>x for (x,y) in zip(1:length(readdir()), readdir())))
end

# split instance order by dot

