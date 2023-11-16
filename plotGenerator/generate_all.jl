include("twojobs.jl")
include("twomachines.jl")
include("twojobs2.jl")
include("twomachinesN.jl")

if abspath(PROGRAM_FILE) == @__FILE__
    main_two_jobs()
    main_two_jobs_2()
    main_two_jobs_M()
    main_two_machines()
    main_two_machines_time()
end