using ShopAlgorithms, Random


# generate a random instances

rng = MersenneTwister(1234)

# m = 2

# for n in 2:2:14
#     for n_i in 14:-2:2
#         for i in 1:5
#             instance = InstanceLoaders.random_instance_generator(n, m; 
#                 rng=rng, 
#                 n_i=[n_i for _ in 1:n],
#                 machine_repetition=true,
#                 job_recirculation=true)
#             open("tests.jl/testsTwoMachines/n$(n)n_i$(n_i)i$i.txt", "w") do io
#                 write(io, InstanceLoaders.TaillardSpecification(instance))
#             end
#         end
#     end
# end

# for n in 2:2:4
#     for n_i in 2:2:30
#         for i in 1:5
#             instance = InstanceLoaders.random_instance_generator(n, m; 
#                 rng=rng, 
#                 n_i=[n_i for _ in 1:n],
#                 machine_repetition=true,
#                 job_recirculation=true)
#             open("tests.jl/testsTwoMachinesN/n$(n)n_i$(n_i)i$i.txt", "w") do io
#                 write(io, InstanceLoaders.TaillardSpecification(instance))
#             end
#         end
#     end
# end

n = 2

# for n_i in 10:4:90
#     for m in 2:4:90
#         for i in 1:5
#             instance = InstanceLoaders.random_instance_generator(n, m; 
#                 rng=rng, 
#                 n_i=[n_i for _ in 1:n],
#                 machine_repetition=true,
#                 job_recirculation=true)
#             open("tests.jl/testsTwoJobs/m$(m)n_i$(n_i)i$i.txt", "w") do io
#                 write(io, InstanceLoaders.TaillardSpecification(instance))
#             end
#         end
#     end
# end

for n_i in 25:25:500
    for i in 1:5
        local m = n_i
        instance = InstanceLoaders.random_instance_generator(n, m; 
                rng=rng, 
                n_i=[n_i for _ in 1:n],
                machine_repetition=true)
        open("tests.jl/testsTwoJobsM/m$(m)n_i$(n_i)i$i.txt", "w") do io
            write(io, InstanceLoaders.TaillardSpecification(instance))
        end
    end
end

for n_i in 25:25:500
    for i in 1:5
        local m = 2
        instance = InstanceLoaders.random_instance_generator(n, m; 
                rng=rng, 
                n_i=[n_i for _ in 1:n],
                machine_repetition=true,
                job_recirculation=true)
        open("tests.jl/testsTwoJobs2/m$(m)n_i$(n_i)i$i.txt", "w") do io
            write(io, InstanceLoaders.TaillardSpecification(instance))
        end
    end
end

# for (n,m) in [(5,5), (5,10), (5,15), (10,5), (10,10), (10,15), (15,5)]
#     for i in 1:5
#         n_i = m
#         instance = InstanceLoaders.random_instance_generator(n, m; 
#                 rng=rng, 
#                 n_i=[n_i for _ in 1:n],
#                 machine_repetition=true,
#                 job_recirculation=true)
#         open("tests.jl/testsWithRecirculation/n$(n)m$(m)n_i$(n_i)i$(i).txt", "w") do io
#             write(io, InstanceLoaders.TaillardSpecification(instance))
#         end
#     end
# end