include("utils.jl")


function plot_two_machinesN(df::DataFrame, algorithm, tickx=2, tick0x=2)
    # calculate max n and max n_i
    max_n = maximum(df[!,:n])
    max_n_i = maximum(df[!,:operation_maximum])
    min_n = minimum(df[!,:n])
    min_n_i = minimum(df[!,:operation_maximum])

    dataframe = filter(row -> row[:algorithm] == algorithm, df)
    sort!(dataframe, [:n, :operation_maximum])

    # get instances with errors
    error_data = error_dataframe(df)

    data = AbstractTrace[]
    push!(data, scatter(
        x = error_data[!,:operation_maximum],
        y = error_data[!,:timeSecondsM],
        mode = "markers",
        marker = attr(
            color = "red",
            size = 14
        )
    ))

    okDataframe = filter(row -> row[:status] == "OK", dataframe)
    okDataframe = mean_time(okDataframe)

    DataframeSplitted = [filter(row -> row[:n] == x, okDataframe) for x in 2:2:4]
    data1 = map(DataframeSplitted) do df1
        scatter(
            x = df1[!,:operation_maximum],
            y = df1[!,:timeSecondsM],
            mode = "lines+markers",
            x0 = tick0x,
            dx = tickx,
            name = L"\huge{n = %$(first(df1[1,:n]))}",
            marker_size=10,
            line_width=4
        )
    end
    append!(data, data1)
    plot(data, layout_two_machines_time(tickx, tick0x, min_n, max_n))
end

function main_two_machines_time()
    PlotlyKaleido.start(mathjax=true, plotly_version=v"2.27.1")
    cd("D:\\Studia\\sem7\\ShopAlgorithmsNewTests\\plotGenerator")
    dir = "twomachines"
    mkpath(dir)
    df = Analyser.load_df("../results/resultsTwoMachines/resultmemoryN.csv") |> Analyser.compress
    cd("twomachines")
    # get list of algorithms
    algorithms = unique(df[!,:algorithm])
    for algorithm in algorithms
        plot = plot_two_machinesN(df, algorithm)
        algorithm_name = replace(algorithm, "|"=>",")
        PlotlyKaleido.savefig(plot, algorithm_name * "_timeN.png"; width = 1000, height = 800)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_two_machines_time()
end


