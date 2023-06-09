# Simple data fitting example: Fitting a line to noisy points. 
# The example will readily generalize to any simple data fitting problem.

# First generate the data. We will make a data set consisting of (x,y)
# pairs of the form y = a*x + b + noise.
# These are the parameters used to generate the data:
a = 2.0
b = -4.0
sigma = 0.5 # noise sigma

# Generate ten data points evenly spaced in x:
n_data = 10
X = linspace(0.0, 10.0, n_data)
Y = a*X + b + randn(n_data)*sigma

# In a real application, everything above would come from the data.
# Now start the actual estimation process.


using MCJulia

# When fitting data, our likelihood function has the form 1/sigma^n * exp(-ChiSq/2), where
# ChiSq = sum((model - data)/sigma)^2 and n is the number of our data points. 
# We use a wide normal prior distribution for a and b, and a Jeffreys prior p(x) ~= 1/x for sigma.
# Our log-probability function has two extra arguments after the parameter vector,
# giving the x and y values of the data points.
function log_probability(parameters::Array{Float64}, X_data::AbstractVector{Float64}, Y_data::AbstractVector{Float64})
	a = parameters[1]
	b = parameters[2]
	sigma = parameters[3]
	if sigma <= 0
		return -Inf
	end
	n = length(X_data)
	Y_model = a*X_data + b
	ChiSq = 0.5 * sum(((Y_model - Y_data)/sigma).^2)
	return -(n+1)*log(sigma) -ChiSq - (a/100.0)^2 - (b/100.0)^2
end

# We give our data points to the sampler in the extra arguments tuple.
args = (X, Y)

# Set up the sampler. It is good to use a large number of walkers.
dim = 3
walkers = 100
S = Sampler(walkers, dim, log_probability, args)

# Generate starting positions for the walkers from a N(0,10)
# distribution, squaring it for sigma. The ideal starting positions
# will be in a spherical shell around the high-probability region, but
# as long as they are close enough, the walkers will relax towards
# the region fairly quickly.
p0 = randn((walkers, 3)) * 10
p0[:,3] = p0[:,3].^2

# Do a burn-in of 200 steps (20000 samples). Discard the samples
# but keep the final position of the walkers. This is a small
# problem, so it's fast.
println("Burn-in...")
p = sample(S, p0, 200, 1, false)
println("acceptance ratio: $(S.accepted / S.iterations)")

# Start sample for another 100 steps, saving the chain every 5
# steps, starting at the end position of the burn-in.
println("Sampling...")
sample(S, p, 100, 5, true)
println("acceptance ratio: $(S.accepted / S.iterations)")

# Save and plot the chain.
println("Plotting...")
save_chain(S, "chain.jld")
# run(`python plot_chains.py chain.txt`)
