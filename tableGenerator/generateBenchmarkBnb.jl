# generate benchmark bnb table with TeXTables
# output: tableBenchmarkBnb.tex
# input: benchmarkBnb.csv
# Path: tableGenerator/generateBenchmarkBnb.jl
# Compare this snippet from plotGenerator/twomachines.jl:
#
include("../compress.jl")
include("utils.jl")

using DataFrames, CSV, .Analyser, PrettyTables, Printf



df = load_df(["results\\resultsFromBenchmarks\\resultbandb.csv", "results\\resultsFromBenchmarks\\resultbandb2.csv"]) |> compress

filter!(row -> row[:m] < 15, df)

df[!,:objectiveValue] = [if x == "OK" y else "--" end for (x,y) in zip(df[!,:status], df[!,:objectiveValue])]

df[!,:microruns] = [if x == "OK" y else "--" end for (x,y) in zip(df[!,:status], df[!,:microruns])]

df[!,:timeSeconds] = [if x == "OK" y else "--" end for (x,y) in zip(df[!,:status], df[!,:timeSeconds])]

df = df[!, [:name, :n, :m, :objectiveValue, :algorithm, :timeSeconds, :microruns]]

df[!, :algorithm] = [algorithms_short_names[x] for x in df[!,:algorithm]]

df[!,:name] = String.([split(x, "/")[2] |>  a->split(a,".")[1] for x in df[!,:name]])

df[!,:lp] = [instance_order[x] for x in df[!,:name]]

split_df_by_name = [(algorithm, filter(row -> row[:algorithm] == algorithm, df)) for algorithm in unique(df[!,:algorithm])]



instances = df[!,[:lp, :n, :m, :objectiveValue]] |> unique

for (algorithm, df) in split_df_by_name
    df = df[!,[:lp, :timeSeconds, :microruns]]
    df[!, :timeSeconds] = [if x isa AbstractFloat @sprintf("%.2f", x) else x end for x in df[!,:timeSeconds]]
    println(instances)
    println(df)
    instances = innerjoin(instances, df, on = [:lp], renamecols = identity => "_$algorithm")
end


sort!(instances, :lp)



open(raw"D:\Studia\sem7\ShopAlgorithmsNewTests\tableGenerator\benchmarkbnb.txt", "w") do io
    pretty_table(io, instances; backend=Val(:latex), wrap_table=true, label="fig:benchmark:bnb")
end



