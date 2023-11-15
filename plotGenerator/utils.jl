include("../compress.jl")
using PlotlyJS, DataFrames, Statistics, LaTeXStrings, PlotlyKaleido

layout_two_machines_time(tickx, tick0x, min_x,max_x) = Layout(
    xaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{n_i}"
        ),
        showgrid = true,
        tickmode = "linear",
        tick0 = tick0x,
        dtick = tickx,
    ),
    yaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{t (S)}"
        ),
        showgrid = true
    ),
    font = attr(
        family = "Times New Roman",
        size = 34
    )
)

layout_two_machines(tickx, tick0x, ticky, tick0y, min_n, max_n, min_n_i, max_n_i; xlabel="n", ylabel="n_i") = Layout(
    xaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{%$(xlabel)}",
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
            text = L"\Huge{%$(ylabel)}"
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

error_dataframe(dataframe::DataFrame, x = :n, y = :operation_maximum) = combine(
    groupby(filter(row -> row[:status] != "OK", dataframe), [x, y]), 
    [:status => length => :status_count, :timeSeconds => mean => :timeSecondsM])


function mean_time(dataframe::DataFrame, x = :n, y = :operation_maximum)
    new_dataframe = filter(row -> row[:status] == "OK", dataframe)
    new_dataframe = groupby(new_dataframe, [x, y])
    new_dataframe = combine(new_dataframe, :timeSeconds => mean => :timeSecondsM)
    return new_dataframe
end

function error_traces(dataframe::DataFrame, tickx, ticky, xaxes = :n, yaxes = :operation_maximum; solidity = 0.3, size = 25)
    data = AbstractTrace[]
    errorDataframe = error_dataframe(dataframe, xaxes, yaxes)

    for row in eachrow(errorDataframe)
        if row[:status_count] > 0
            push!(data, bar(
                x = [row[xaxes]],
                y = [ticky],
                base = [row[yaxes] - ticky/2],
                marker = attr(
                    pattern = attr(
                        shape = "x",
                        fgcolor = "red",
                        bgcolor = "rgba(0,0,0,0)",
                        solidity = solidity,
                        fgopacity = 0.85,
                        fillmode = "overlay",
                        size=size
                    )
                ),
                width = tickx,
                showlegend = false
            ))
        end
    end
    return data
end