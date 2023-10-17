using Distributed, ProgressMeter, IterTools, Random



@everywhere include("test_maker.jl")


timeout = 240

instances = load_instances("testsTwoMachines")

filter!(x->x.n≤10, instances)

functions1 = get_functions("Branch and Bound - 1|r_j|Lmax", "Shifting Bottleneck", "Shifting Bottleneck - DPC")

n = length(instances) * length(functions)

instances_with_functions_matrix = product(instances, functions) |> collect
instances_with_functions = reduce(push!, instances_with_functions_matrix; init=[])
# filter!(x->!(x[1].n>8 && any(x[1].n_i.>22) && x[2][1] == "Shifting Bottleneck - DPC"), instances_with_functions)


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

println("Saving results...")


dfs = DataFrame.(result_list)
df = reduce(append!, dfs)

CSV.write("results/result1.csv", df)



functions2 = get_functions("Algorithm2_TwoMachinesJobShop")
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
        elseif e isa InterruptException
            println("$(instance.name) instance solved with $name timeouted at$(time() - t0)")
            ShopInstances.ShopError(instance, "Timeout at: $timeout", algorithm=name)
        else
            println("$(instance.name) instance solved with $name threw an error: $e")
            ShopInstances.ShopError(instance, "Error: $e", algorithm=name)
        end
    end
    close(timer)
    result
end

println("Saving results...")


dfs = DataFrame.(result_list)
df = reduce(append!, dfs)

CSV.write("results/result2.csv", df)


