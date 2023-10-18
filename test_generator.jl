using ShopAlgorithms, Random


# generate a random instances

rng = MersenneTwister(1234)

m = 2

# for n in 2:2:10
#     for n_i in 26:-4:2
#         instance = InstanceLoaders.random_instance_generator(n, m; 
#             rng=rng, 
#             n_i=[n_i for _ in 1:n],
#             machine_repetition=true,
#             job_recirculation=true)
#         open("tests.jl/testsTwoMachines/n$(n)n_i$n_i.txt", "w") do io
#             write(io, InstanceLoaders.TaillardSpecification(instance))
#         end
#     end
# end

n = 2

for n_i in 10:4:130
    for m in 2:4:n_i
        instance = InstanceLoaders.random_instance_generator(n, m; 
            rng=rng, 
            n_i=[n_i for _ in 1:n],
            machine_repetition=true,
            job_recirculation=true)
        open("tests.jl/testsTwoJobs/m$(m)n_i$n_i.txt", "w") do io
            write(io, InstanceLoaders.TaillardSpecification(instance))
        end
    end
end

# for n in 2:13
#     for m in 2:13
#         instance = InstanceLoaders.random_instance_generator(n, m; 
#             rng=rng)
#         open("tests.jl/testsNoRecirculation/n$(n)m$(m).txt", "w") do io
#             write(io, InstanceLoaders.TaillardSpecification(instance))
#         end
#     end
# end

# for n in 2:13
#     for m in 2:13
#         for n_i in (m÷2):2:3m
#             instance = InstanceLoaders.random_instance_generator(n, m; 
#                 rng=rng,
#                 n_i=[n_i for _ in 1:n],
#                 machine_repetition=true,
#                 job_recirculation=true)
#             open("tests.jl/testsWithRecirculation/n$(n)m$(m)n_i$(n_i).txt", "w") do io
#                 write(io, InstanceLoaders.TaillardSpecification(instance))
#             end
#         end
#     end
# end

