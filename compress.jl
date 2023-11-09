include("analyse.jl")

compress(in_file, out_file) = load_df(in_file) |> group_by_solution |> get_solutions_full |> Base.Fix2(save_df,out_file)

if abspath(PROGRAM_FILE) == @__FILE__
    compress(ARGS[1], ARGS[2])
end