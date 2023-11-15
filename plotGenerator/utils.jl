include("../compress.jl")
using PlotlyJS, DataFrames, Statistics, LaTeXStrings, PlotlyKaleido

layout_two_machines_time(tickx, tick0x, min_x,max_x) = Layout(
    xaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{n}"
        ),
        showgrid = true,
        tickmode = "linear",
        tick0 = tick0x,
        dtick = tickx,
        range = [min_x - tickx/2, max_x + tickx/2],
    ),
    yaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{t(s)}"
        ),
        showgrid = true
    ),
    font = attr(
        family = "Times New Roman",
        size = 34
    )
)

layout_two_machines(tickx, tick0x, ticky, tick0y, min_n, max_n, min_n_i, max_n_i) = Layout(
    xaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{n}"
        ),
        showgrid = false,
        tickmode = "linear",
        tick0 = tick0x,
        dtick = tickx,
        range = [min_n - tickx/2, max_n + tickx/2],
        constrain = "domain",
    ),
    yaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{n_i}"
        ),
        showgrid = false,
        tickmode = "linear",
        tick0 = tick0y,
        dtick = ticky,
        range = [min_n_i - ticky/2, max_n_i + ticky/2]
    ),
    font = attr(
        family = "Times New Roman",
        size = 34
    ),
    barmode = "overlay"
)

error_dataframe(dataframe::DataFrame) = combine(
    groupby(dataframe, [:n, :operation_maximum]), 
    :status => length => :status_count)


function mean_time(dataframe::DataFrame)
    new_dataframe = filter(row -> row[:status] == "OK", dataframe)
    new_dataframe = groupby(new_dataframe, [:n, :operation_maximum])
    new_dataframe = combine(new_dataframe, :timeSeconds => mean => :timeSecondsM)
    return new_dataframe
end

function error_traces(dataframe::DataFrame, tickx, ticky)
    data = AbstractTrace[]
    errorDataframe = error_dataframe(dataframe)

    for row in eachrow(errorDataframe)
        if row[:status_count] > 0
            push!(data, bar(
                x = [row[:n]],
                y = [ticky],
                base = [row[:operation_maximum] - ticky/2],
                marker = attr(
                    pattern = attr(
                        shape = "x",
                        fgcolor = "red",
                        bgcolor = "rgba(0,0,0,0)",
                        solidity = 0.3,
                        fgopacity = 0.85,
                        fillmode = "overlay",
                        size=25
                    )
                ),
                width = tickx,
                showlegend = false
            ))
        end
    end
    return data
end