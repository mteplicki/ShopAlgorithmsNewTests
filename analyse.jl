using DataFrames, CSV

load_df(path) = DataFrame(CSV.File(path))

group_by_solution(df) = groupby(df, [:name, :algorithm])

get_solutions(df) = combine(df, :objectiveValue => first, :timeSeconds => first, :microruns => first, :status => first)#, :algorithm => first, :name =>first)