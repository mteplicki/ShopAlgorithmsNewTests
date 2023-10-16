using Distributed, ProgressMeter, IterTools, Random



@everywhere include("test_maker.jl")


timeout = 240

instances = load_instances("testsTwoMachines")

filter!(x->x.n≤8 && maximum(x.n_i) <= 26 - (2*x.n), instances)

functions = get_functions("Algorithm2_TwoMachinesJobShop")

n = length(instances) * length(functions)

# const results = RemoteChannel(()->Channel{ShopInstances.ShopResult}(n));

# progress = Progress(n)


# for (index, p) in enumerate(workers())
#     block_length = length(instances) ÷ length(workers())
#     instance_subset = if index == length(workers())
#         instances[((index-1)*block_length + 1):length(instances)]
#     else
#         instances[((index-1)*block_length + 1):index*block_length]
#     end
#     remote_do(make_tests_channel, p, instance_subset, functions, timeout, results)
# end

instances_with_functions_matrix = product(instances, functions) |> collect
instances_with_functions = reduce(push!, instances_with_functions_matrix; init=[])


result_list = @showprogress 0.5 "Computing..." pmap(instances_with_functions) do instance_function
    instance, (name, func) = instance_function
    println("Solving $(instance.name) instance with $name")
    t0 = time()
    tsk = @task func(instance)
    schedule(tsk)
    timer = Timer(timeout) do _
        istaskdone(tsk) || Base.throwto(tsk, InterruptException())
    end
    result = try
        a = fetch(tsk)
        println("Solved $(instance.name) instance with $name")
        a
    catch e
        if e isa OutOfMemoryError
            println("$(instance.name) instance solved with $name ran out of memory at $(time() - t0)")
            ShopInstances.ShopError(instance, "Out of memory", algorithm=name)
        else
            println("$(instance.name) instance solved with $name timeouted at$(time() - t0)")
            ShopInstances.ShopError(instance, "Timeout at: $timeout", algorithm=name)
        end
    end
    close(timer)
    result
end

# global n2 = n

# df::Union{DataFrame, Nothing} = nothing

println("Saving results...")

# println(result_list)

dfs = DataFrame.(result_list)
df = reduce(append!, dfs)

# while n > 0 # print out results
#     result = take!(results)
#     next!(progress)
#     global df = if n == length(instances) * length(functions)
#         DataFrame(result)
#     else
#         append!(df, DataFrame(result))
#     end
#     global n2 = n2 - 1
# end
# finish!(progress)

CSV.write("results/result11.csv", df)

# results = make_tests_paralell(instances, functions, timeout)

# dfs = DataFrame.(results)

# df = reduce(append!, dfs)

