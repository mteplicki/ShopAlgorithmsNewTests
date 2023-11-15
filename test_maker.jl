include("compress.jl")

using ShopAlgorithms, ProgressMeter, Dates, DataFrames, CSV, Distributed, IterTools

const functions_dict = Dict(
    "Algorithm2_TwoMachinesJobShop" => x->Algorithms.algorithm2_two_machines_job_shop(x; yielding=true),
    "Branch and Bound - Carlier" => x->Algorithms.branchandbound_carlier(x; yielding=true, with_priority_queue=true),
    "Branch and Bound - Carlier with heuristic UB" => x->Algorithms.branchandbound_carlier(x; yielding=true, with_priority_queue=false, heuristic_UB=true),
    "Branch and Bound - Carlier with Stack" => x->Algorithms.branchandbound_carlier(x; yielding=true, with_priority_queue=false),
    "Branch and Bound - 1|R_j|Lmax" => x->Algorithms.branchandbound(x; yielding=true),
    "Shifting Bottleneck - DPC" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true),
    "Shifting Bottleneck - DPC with stack" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true, with_priority_queue=false),
    "Shifting Bottleneck - DPC with timeout 0.5 with depth 0" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true, carlier_timeout=0.5, carlier_depth=0),
    "Shifting Bottleneck - DPC with timeout 0.5 with depth 1" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true, carlier_timeout=0.5, carlier_depth=1),
    "Shifting Bottleneck - DPC with timeout 10.0 with depth 0" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true, carlier_timeout=10.0, carlier_depth=0),
    "Shifting Bottleneck - DPC with timeout 10.0 with depth 1" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true, carlier_timeout=10.0, carlier_depth=1),
    "Shifting Bottleneck" => x->Algorithms.shiftingbottleneck(x; suppress_warnings=true, yielding=true),
    "Shifting Bottleneck - Carlier" => x->Algorithms.shiftingbottleneckcarlier(x; yielding=true, with_dpc=false),
    "Two jobs job shop - geometric approach" => x->Algorithms.two_jobs_job_shop(x; yielding=true)
)

get_functions(x...) = getindex.(Ref(functions_dict), x)

struct Ordering <: Base.Order.Ordering end

function Base.Order.lt(::Ordering, x::ShopInstances.JobShopInstance, y::ShopInstances.JobShopInstance)
    return x.n < y.n || (x.n == y.n && x.m < y.m) || (x.n == y.n && x.m == y.m && maximum(x.n_i) < maximum(y.n_i)) || (x.n == y.n && x.m == y.m && maximum(x.n_i) == maximum(y.n_i) && x.name < y.name)
end

function load_instances(folder)
    path = "tests.jl/" * folder
    if folder == "testsFromBenchmarks"
        type = InstanceLoaders.StandardSpecification
    else
        type = InstanceLoaders.TaillardSpecification
    end
    return sort([read(join([path, file], "/"), type, join([folder,file], "/")) for file in readdir(path)], order=Ordering())
end

mix_instances_with_functions(instances, functions) = reduce(push!, (product(instances, functions) |> collect); init=[])

function make_tests(instances_with_functions, timeout,  file; garbage_collect=false, compress=false)
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
            if e.task.exception isa OutOfMemoryError
                println("$(instance.name) instance solved with $name ran out of memory at $(time() - t0)")
                ShopInstances.ShopError(instance, "Out of memory", ShopInstances.Cmax_function, algorithm=name)
            elseif e.task.exception isa InterruptException
                println("$(instance.name) instance solved with $name timeouted at$(time() - t0)")
                ShopInstances.ShopError(instance, "Timeout at: $(time() - t0)", ShopInstances.Cmax_function, algorithm=name)
            else
                showerror(stdout, e, catch_backtrace())
                ShopInstances.ShopError(instance, "Error: $(e.task.exception)", ShopInstances.Cmax_function, algorithm=name)
            end
        end
        close(timer)
        garbage_collect && GC.gc()
        result
    end

    sum(x->x isa ShopInstances.ShopError, result_list) |> println
    println("Saving results...")

    dfs = DataFrame.(result_list)
    df = reduce(append!, dfs)

    if compress
        df = Analyser.compress(df)
    end

    CSV.write(file, df)
end






