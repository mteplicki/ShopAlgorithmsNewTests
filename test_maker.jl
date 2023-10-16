using ShopAlgorithms, ProgressMeter, Dates, DataFrames, CSV, Distributed

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
    "Algorithm2_TwoMachinesJobShop" => x->Algorithms.algorithm2_two_machines_job_shop(x; yielding=true),
    "Branch and Bound - DPC" => x->Algorithms.generate_active_schedules_dpc(x; yielding=true),
    "Branch and Bound - 1|r_j, pmtn|Lmax" => x->Algorithms.generate_active_schedules(x; bounding_algorithm=:pmtn, yielding=true),
    "Branch and Bound - 1|r_j|Lmax" => x->Algorithms.generate_active_schedules(x; yielding=true),
    "Shifting Bottleneck - DPC" => x->Algorithms.shiftingbottleneckdpc(x; yielding=true),
    "Shifting Bottleneck" => x->Algorithms.shiftingbottleneck(x; suppress_warnings=true, yielding=true),
    "Two jobs job shop - geometric approach" => x->Algorithms.two_jobs_job_shop(x; yielding=true),
    "Two machines job shop" => x->Algorithms.two_machines_job_shop(x; yielding=true)
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

function make_tests_channel(instances, functions, timeout, channel)
    for instance in instances
        for (name, func) in functions
            println("Solving $(instance.name) instance with $name")
            tsk = @task func(instance)
            schedule(tsk)
            Timer(timeout) do timer
                istaskdone(tsk) || Base.throwto(tsk, InterruptException())
            end
            result = try
                fetch(tsk)
            catch _
                ShopInstances.ShopError(instance, "Timeout for $timeout s"; algorithm = name)
            end
            put!(channel, result)
            println("Solved $(instance.name) instance with $name")
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
            name1 = name
            func1 = func
            instance1 = instance
            f = function(name1, func1, instance1)
                # println("Instance $(instance1.name) starting with $(name1) algorithms at $(now())")
                result = @timeout timeout func1(instance1) ShopInstances.ShopError(instance, "Timeout for $timeout s"; algorithm = name1)
                # println("Instance $(instance1.name) finished with $(name1) algorithms at $(now())")
                next!(p)
                result
            end

            f2 = function(name1, func1, instance1)
                println("Solving $(instance1.name) instance with $name1 algorithm at $(Threads.threadid()) thread")
                tsk = @task func1(instance1)
                schedule(tsk)
                Timer(timeout) do timer
                    istaskdone(tsk) || Base.throwto(tsk, InterruptException())
                end
                result = try
                    fetch(tsk)
                catch _
                    ShopInstances.ShopError(instance, "Timeout for $timeout s"; algorithm = name1)
                end
                println("Ended solving $(instance1.name) instance with $name1 algorithm at $(Threads.threadid()) thread")
                next!(p)
                update!(p)
                result
            end
            tasks[i] = Threads.@spawn f2(name1, func1, instance1)
            i += 1
        end
    end
    # wait for all tasks to finish
    results = ShopInstances.ShopResult[]
    # Threads.wait.(tasks)
    for task in tasks
        result = fetch(task)
        push!(results, result)
    end
    finish!(p)
    return results
    
end






