using ShopAlgorithms, ProgressMeter

macro timeout(seconds, expr, fail)
    quote
        tsk = @task $expr
        schedule(tsk)
        Timer($seconds) do timer
            istaskdone(tsk) || Base.throwto(tsk, InterruptException())
        end
        try
            fetch(tsk)
        catch _
            $fail
        end
    end
end

global functions::Dict{String, Function} = Dict(
    "Algorithm2_TwoMachinesJobShop" => Algorithms.algorithm2_two_machines_job_shop,
    "Branch and Bound - DPC" => Algorithms.generate_active_schedules_dpc,
    "Branch and Bound - 1|r_j, pmtn|Lmax" => x->Algorithms.generate_active_schedules(x; bounding_algorithm=:pmtn),
    "Branch and Bound - 1|r_j|Lmax" => x->Algorithms.generate_active_schedules(x),
    "Shifting Bottleneck - DPC" => Algorithms.shiftingbottleneckdpc,
    "Shifting Bottleneck" => Algorithms.shiftingbottleneck,
    "Two jobs job shop - geometric approach" => Algorithms.two_jobs_job_shop,
    "Two machines job shop" => Algorithms.algorithm2_two_machines_job_shop
)

get_functions(x...) = filter(f->f[1] in x, functions)

function load_instances(folder)
    path = "tests.jl/" * folder
    if folder == "testsFromBenchmark"
        type = InstanceLoaders.StandardSpecification
    else
        type = InstanceLoaders.TaillardSpecification
    end
    return [read(join([path, file], "/"), type, join([folder,file], "/")) for file in readdir(path)]
end

function make_tests(instances, functions, timeout)
    for instance in instances
        for (name, func) in functions
            @timeout timeout func(instance) ShopInstances.ShopError(instance, "Timeout for $timeout s"; algorithm = name)
        end
    end
end

function make_tests_paralell(instances, functions, timeout)
    n = length(instances)*length(functions)
    p = Progress(n)
    tasks = Vector{Task}(undef, n)
    i = 1
    for instance in instances
        for (name, func) in functions
            tasks[i] = Threads.@spawn begin
                @timeout timeout func(instance) ShopInstances.ShopError(instance, "Timeout for $timeout s"; algorithm = name)
                next!(p)
            end
            i += 1
        end
    end
    # wait for all tasks to finish
    results = ShopInstances.ShopResult[]
    for task in tasks
        result = fetch(task)
        push!(results, result)
    end
    finish!(p)
    return results
    
end


