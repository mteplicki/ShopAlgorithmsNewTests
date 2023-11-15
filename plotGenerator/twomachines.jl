include("utils.jl")

function plot_two_machines_time(df::DataFrame, algorithm, tickx=2, tick0x=2, ticky=2, tick0y=2)
    # calculate max n and max n_i
    max_n = maximum(df[!,:n])
    max_n_i = maximum(df[!,:operation_maximum])
    min_n = minimum(df[!,:n])
    min_n_i = minimum(df[!,:operation_maximum])

    dataframe = filter(row -> row[:algorithm] == algorithm, df)
    sort!(dataframe, [:n, :operation_maximum])
    okDataframe = filter(row -> row[:status] == "OK", dataframe)
    okDataframe = groupby(okDataframe, [:n, :operation_maximum])
    okDataframe = combine(okDataframe, :timeSeconds => mean => :timeSecondsM)

    data = AbstractTrace[]
    push!(data, heatmap(
        x = okDataframe[!,:n],
        y = okDataframe[!,:operation_maximum],
        z = okDataframe[!,:timeSecondsM],
        hoverongaps = false
    ))

    # get instances with errors
    append!(data, error_traces(dataframe, tickx, ticky))

    layout = layout_two_machines(tickx, tick0x, ticky, tick0y, min_n, max_n, min_n_i, max_n_i)
    plot(data, layout)
end

function plot_two_machines_solution(df::DataFrame, algorithm, accurate_algortihm; kwargs...)
    tickx  = 2
    tick0x = 2
    ticky  = 2
    tick0y = 2

    # check if in kwargs there is a key "max_z"
    kwargs_dict = Dict(kwargs)
    

    # calculate max n and max n_i
    max_n = maximum(df[!,:n])
    max_n_i = maximum(df[!,:operation_maximum])
    min_n = minimum(df[!,:n])
    min_n_i = minimum(df[!,:operation_maximum])

    dataframe = filter(row -> row[:algorithm] == algorithm, df)
    accurate_dataframe = filter(row -> row[:algorithm] == accurate_algortihm, df)
    joined = innerjoin(dataframe, accurate_dataframe, on = :name, makeunique = true)
    filter!(row -> row[:status_1] == "OK", joined)

    joined_OK = filter(row -> row[:status] == "OK", joined)

    # calculate approximation error_
    joined_OK[!,:error] = (joined_OK[!,:objectiveValue] .- joined_OK[!,:objectiveValue_1] ) ./ joined_OK[!,:objectiveValue_1]
    
    # calculate mean approximation error_
    joined_OK = combine(groupby(joined_OK, [:n, :operation_maximum]), :error => mean => :error)

    max_z = if haskey(kwargs_dict, :max_z)
        kwargs_dict[:max_z]
    else
        maximum(joined_OK[!,:error])
    end

    data = AbstractTrace[]
    push!(data, heatmap(
        x = joined_OK[!,:n],
        y = joined_OK[!,:operation_maximum],
        z = joined_OK[!,:error],
        hoverongaps = false,
        zmin = 0,
        zmax = max_z
    ))

    # get instances with errors
    append!(data, error_traces(joined, tickx, ticky))

    layout = layout_two_machines(tickx, tick0x, ticky, tick0y, min_n, max_n, min_n_i, max_n_i)
    plot(data, layout)
end

function main_two_machines()
    PlotlyKaleido.start(mathjax=true, plotly_version=v"2.27.1")
    cd("D:\\Studia\\sem7\\ShopAlgorithmsNewTests\\plotGenerator")
    dir = "twomachines"
    mkpath(dir)

    df = cd("../results/resultsTwoMachines") do
        Analyser.load_df(["resultmemory2.csv", "resultmemory2.csv", "resultspeed.csv"]) |> Analyser.compress
    end
    
    cd("twomachines")

    # get list of algorithms
    algorithms = unique(df[!,:algorithm])
    for algorithm in algorithms
        plot = plot_two_machines_time(df, algorithm)
        algorithm_name = replace(algorithm, "|"=>",")
        PlotlyKaleido.savefig(plot, algorithm_name * "_time.png"; width = 1000, height = 800)
    end

    heuristics = [
        "Shifting Bottleneck - DPC with timeout 10.0 with depth 0",
        "Shifting Bottleneck - DPC with timeout 10.0 with depth 1",
        "Shifting Bottleneck - DPC with timeout 0.5 with depth 1",
        "Shifting Bottleneck - DPC with timeout 0.5 with depth 0",
        "Shifting Bottleneck - Carlier"
    ]

    for heuristic in heuristics
        plot = plot_two_machines_solution(df, heuristic, "Branch and Bound - Carlier"; max_z=0.06)
        heuristic_name = replace(heuristic, "|"=>",")
        PlotlyKaleido.savefig(plot, heuristic_name * "_solution.png"; width = 1000, height = 800)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_two_machines()
end





