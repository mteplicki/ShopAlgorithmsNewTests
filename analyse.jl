using DataFrames, CSV

export load_df, save_df, group_by_solution, get_solutions, get_solutions_full, sort_solutions

load_df(path) = DataFrame(CSV.File(path))

save_df(df, path) = CSV.write(path, df)

group_by_solution(df) = groupby(df, [:name, :algorithm])

get_solutions(df, columns, columns_max = []) = combine(df, (column => first => column for column in columns)..., (column=>maximum for column in columns_max)...)#, :algorithm => first, :name =>first)

get_solutions(df) = get_solutions(df, (:objectiveValue, :timeSeconds, :microruns, :status))

get_solutions_full(df) = get_solutions(df, (:date, :m, :n, :solution_id, :objectiveValue, :microruns, :timeSeconds, :memoryBytes, :metadata, :status), (:operation,))

sort_solutions(df) = sort(df, :name)