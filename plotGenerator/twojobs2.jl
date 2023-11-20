include("utils.jl")


function plot_two_jobs2(df::DataFrame, algorithms, tickx=200, tick0x=200, dtkickx=400; r_scale = false)
    # calculate max n and max n_i
    max_n_i = maximum(df[!,:operation_maximum])
    min_n_i = minimum(df[!,:operation_maximum])

    okDataframe = filter(row -> row[:status] == "OK", df)
    okDataframe = mean_time(okDataframe, [:algorithm, :operation_maximum])

    # get instances with errors
    error_data = error_dataframe(df, :algorithm, :operation_maximum)
    errordatajoined = innerjoin(error_data, okDataframe, on = [:algorithm, :operation_maximum], makeunique = true)

    data = AbstractTrace[]
    push!(data, scatter(
        x = r_scale ? errordatajoined[!,:operation_maximum] .^ 2 : errordatajoined[!,:operation_maximum],
        y = errordatajoined[!,:timeSecondsM_1],
        mode = "markers",
        marker = attr(
            color = "red",
            size = 21
        ),
        showlegend = false
    ))

    DataframeSplitted = [filter(row -> row[:algorithm] == algorithm, okDataframe) for algorithm in algorithms]
    data1 = map(DataframeSplitted) do df1
        scatter(
            x = r_scale ? df1[!,:operation_maximum] .^ 2 : df1[!,:operation_maximum],
            y = df1[!,:timeSecondsM],
            mode = "lines+markers",
            x0 = tick0x,
            dx = tickx,
            name = "$(algorithms_short_name[first(df1[!,:algorithm])])",
            marker_size=10,
            line_width=4
        )
    end
    append!(data, data1)
    layout = if r_scale
        values = unique(sort(okDataframe, :operation_maximum)[!,:operation_maximum] .^ 2)
        layout_two_machines_time([values[1:3:7]; values[9:2:end]])
    else
        layout_two_machines_time(tickx, tick0x, min_n_i, max_n_i; dtickx = dtkickx, xlabel = r_scale ? "r" : "n_i")
    end
    plot(data, layout)
end

function plot_two_jobs2_solution(df::DataFrame, algorithms, accurate_algortihm, tickx=200, tick0x=200)
    # calculate max n and max n_i
    max_n_i = maximum(df[!,:operation_maximum])
    min_n_i = minimum(df[!,:operation_maximum])

    accurate_dataframe = filter(row -> row[:algorithm] == accurate_algortihm, df)
    joined = innerjoin(df, accurate_dataframe, on = :name, makeunique = true)
    filter!(row -> row[:status_1] == "OK", joined)
    joined_OK = filter(row -> row[:status] == "OK", joined)
    joined_OK[!,:error] = (joined_OK[!,:objectiveValue] .- joined_OK[!,:objectiveValue_1] ) ./ joined_OK[!,:objectiveValue_1]

    joined_OK = combine(groupby(joined_OK, [:algorithm, :operation_maximum]), :error => mean => :error)

    # get instances with errors
    error_data = error_dataframe(df, :algorithm, :operation_maximum)

    errordatajoined2 = innerjoin(error_data, joined_OK, on = [:algorithm, :operation_maximum], makeunique = true)
    filter!(row -> row[:algorithm] in algorithms, errordatajoined2)

    data = AbstractTrace[]
    push!(data, scatter(
        x = errordatajoined2[!,:operation_maximum],
        y = errordatajoined2[!,:error],
        mode = "markers",
        marker = attr(
            color = "red",
            size = 21
        ),
        showlegend = false
    ))

    DataframeSplitted = [filter(row -> row[:algorithm] == algorithm, joined_OK) for algorithm in algorithms]
    filter!(df -> !isempty(df), DataframeSplitted)
    data1 = map(DataframeSplitted) do df1
        scatter(
            x = df1[!,:operation_maximum],
            y = df1[!,:error],
            mode = "lines+markers",
            x0 = tick0x,
            dx = tickx,
            name = "$(algorithms_short_name[first(df1[!,:algorithm])])",
            marker_size=10,
            line_width=4
        )
    end
    append!(data, data1)
    plot(data, layout_two_machines_time(tickx, tick0x, min_n_i, max_n_i; dtickx = 400, ylabel = raw"\delta_x"))
end

function main_two_jobs_2()
    cd("D:\\Studia\\sem7\\ShopAlgorithmsNewTests\\plotGenerator")
    dir = "twojobs2"
    mkpath(dir)
    @info "Loading data"
    df = Analyser.load_df(["../results/resultsTwoJobs/result21.csv", "../results/resultsTwoJobs/result22.csv"])
    @info "Data loaded"
    cd(dir)
    # get list of algorithms
    algorithms = unique(df[!,:algorithm])
    @info "Creating plot"
    plot = plot_two_jobs2(df, algorithms)
    @info "Plot created. Saving..."
    PlotlyKaleido.savefig(plot, "twojobs" * "_time2.png"; width = 1200, height = 800)
    plot = plot_two_jobs2(df, algorithms;r_scale = true)
    PlotlyKaleido.savefig(plot, "twojobs" * "_time2r.png"; width = 1200, height = 800)
    @info "Plot saved"

    heuristics = [
        "Shifting Bottleneck - DPC with timeout 10.0 with depth 0",
        "Shifting Bottleneck - DPC with timeout 10.0 with depth 1",
        "Shifting Bottleneck - Carlier"
    ]
    @info "Creating plot"
    plot = plot_two_jobs2_solution(df, heuristics, "Two jobs job shop - geometric approach")
    @info "Plot created. Saving..."
    PlotlyKaleido.savefig(plot, "twojobs" * "_solution2.png"; width = 1200, height = 800)
    @info "Plot saved"
end

function main_two_jobs_M()
    cd("D:\\Studia\\sem7\\ShopAlgorithmsNewTests\\plotGenerator")
    dir = "twojobsM"
    mkpath(dir)
    @info "Loading data"
    df = Analyser.load_df(["../results/resultsTwoJobs/resultM1.csv"])
    @info "Data loaded"
    cd(dir) do 
        algorithms = unique(df[!,:algorithm])
        @info "Creating plot"
        plot = plot_two_jobs2(df, algorithms, 200, 200, 200)
        @info "Plot created. Saving..."
        PlotlyKaleido.savefig(plot, "twojobs" * "_timeM1.png"; width = 1200, height = 800)
        @info "Plot saved"
    end

    df = Analyser.load_df(["../results/resultsTwoJobs/resultM2.csv"])
    @info "Data loaded"
    cd(dir) do 
        algorithms = ["Two jobs job shop - geometric approach"]
        @info "Creating plot"
        plot = plot_two_jobs2(df, algorithms, 10000,10000,20000)
        @info "Plot created. Saving..."
        PlotlyKaleido.savefig(plot, "twojobs" * "_timeM2.png"; width = 1200, height = 800)
        @info "Plot saved"
    end
end

PlotlyKaleido.is_running() || PlotlyKaleido.start(mathjax=true, plotly_version=v"2.27.1")

if abspath(PROGRAM_FILE) == @__FILE__
    main_two_jobs_2()
    main_two_jobs_2()
end


