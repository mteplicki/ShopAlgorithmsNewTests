include("../compress.jl")
using PlotlyJS, DataFrames, Statistics, LaTeXStrings, PlotlyKaleido

const algorithms_short_name = Dict(
    "Algorithm2_TwoMachinesJobShop" => "2m",
    "Branch and Bound - Carlier" => "bnbcarlier",
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

layout_two_machines_time(tickx, tick0x, min_x,max_x; xlabel="n_i", ylabel="t [s]", dtickx = nothing, range_extended = true) = Layout(
    xaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{%$(xlabel)}"
        ),
        showgrid = true,
        tickmode = "linear",
        tick0 = tick0x,
        dtick = isnothing(dtickx) ? tickx : dtickx,
        range = range_extended ? [min_x - tickx/2, max_x + tickx/2] : [min_x - 5, max_x + 5],
    ),
    yaxis = attr(
        title = attr(
            font = attr(
                size = 18
            ),
            text = L"\Huge{%$(ylabel)}"
        ),
        showgrid = true
    ),
    font = attr(
        family = "Times New Roman",
        size = 34
    )
)

layout_two_machines(tickx, tick0x, ticky, tick0y, min_n, max_n, min_n_i, max_n_i; xlabel="n", ylabel="n_i", dtickx = nothing, dticky = nothing, range_extended = true) = Layout(
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
        dtick = isnothing(dtickx) ? tickx : dtickx,
        range = range_extended ? [min_n - tickx/2, max_n + tickx/2] : [min_n, max_n],
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
        dtick = isnothing(dticky) ? ticky : dticky,
        range = range_extended ? [min_n_i - ticky/2, max_n_i + ticky/2] : [min_n_i, max_n_i],
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




function mean_time(dataframe::DataFrame, columns::Vector{Symbol})
    new_dataframe = filter(row -> row[:status] == "OK", dataframe)
    new_dataframe = groupby(new_dataframe, columns)
    new_dataframe = combine(new_dataframe, :timeSeconds => mean => :timeSecondsM)
    return new_dataframe
end

mean_time(dataframe::DataFrame, x = :n, y = :operation_maximum) = mean_time(dataframe, [x, y])

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