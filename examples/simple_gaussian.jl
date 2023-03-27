# A Simple MC Julia test case with detailed explanation

# Load the module and import its public names
include("../src/MCJulia.jl") # or wherever you have the MCJulia.jl file
using .MCJulia  # imports the MCJulia exported namespace

import Distributed: @everywhere
import Random: seed!, rand, randn

# In this simple test case we'll estimate the one-dimensional
# probability distribution N(1, 1). We need to give the logarithm
# of a function proportional to the actual density.
# The position is given to the function as a vector.
@everywhere function log_probability(X)
    return -(X[1] - 1.0)^2
end
# Set up the sampler with minimal options. We'll use 100 walkers
# and the dimension of our probability space is 1.
seed!(0)
walkers = 100
S = Sampler(walkers, 1, log_probability)

# Generate random starting positions for all walkers with a uniform
# distribution in the [-5, 5] interval.
p0 = rand(Float64, (walkers,1)) * 10 .- 5

# Do a 20-step burn-in without saving the results.  Since we have
# 100 walkers, we are throwing away 2000 samples. The return value
# p is the position of the walkers at the last step.
p = sample(S, p0, 20, 1, false, false)

# Now the actual sampling run.
# Run the sampler for 100 steps using p as a starting position, 
# generating a total of 10000 samples.
@time sample(S, p, 100, 5, true, false)

# Flatten and save the chain into a file.
println("Saving chain...")
save_chain(S, "./chains/gaussian")

# Uncomment the following to automatically run the simple Python
# plotting program:
# run(`python plot_chains.py chain.txt`)


# Repeat everything for a slow function using parallel processing
@everywhere function log_probability_slow(X)
    A = randn(100000).^2
    return -(X[1] - 1.0)^2
end

seed!(0)
walkers = 100
S = Sampler(walkers, 1, log_probability_slow)
p0 = rand(Float64, (walkers,1)) * 10 .- 5
p = sample(S, p0, 20, 1, false, true)
@time sample(S, p, 100, 5, true, true)
# Save the chain.
println("Saving chain...")
save_chain(S, "./chains/gaussian_multiprocessed")
