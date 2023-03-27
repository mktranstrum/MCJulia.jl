#!/usr/bin/env python
#coding: utf8

# Quick python program to plot chains produced by the
# save_chain() function in MC Julia.

from numpy import loadtxt, log, load
import matplotlib.pyplot as plt
from sys import argv, exit
from os.path import exists

if len(argv) < 2:
    print("Error: no filename given.")
    print("Usage:   %s <filename>" % (argv[0]))
    exit()
if len(argv) > 2:
    print("Warning: too many filenames.")
    print("The following were ignored:  %s" % " ".join(argv[2:]))

filename = argv[1]

if not exists(filename):
    print("Error: file not found: %s" % filename)
    exit()

try:
    chain = load(filename)#, delimiter=",")
except ValueError:
    print("Error: could not read file %s." % filename)
    exit()

s = chain.shape
if len(s) > 1:
    steps = s[1]
    dim = s[0]
else:
    steps = s[0]
    dim = 1

plt.figure(0)

# Loop over the chains for each parameter
for i in range(dim):
    if dim > 1:
        data = chain[i,:]
    else:
        data = chain[:]
    mean = data.mean()
    std = data.std()
    # Plot chain
    plt.figure(0)
    sub = dim*100 + 10 + i+1
    plt.subplot(sub)
    plt.plot(data, color="black")
    
    # Plot histogram
    plt.figure(i+1)
    counts, bins, patches = plt.hist(data, 30, color="black")
    mode = bins[counts.argmax()] + (bins[1]-bins[0])/2.0
    hist_title = u"Parameter #%d: mode = %.2f, mean±std = %.3f ± %.3f"
    plt.title(hist_title % (i+1, mode, mean, std))
  #  plt.axvline(mean, color="red")
 #   plt.axvline(mean+std, linestyle="--", color="red")
#    plt.axvline(mean-std, linestyle="--", color="red")


# Make correlation plot
if dim <= 9 and dim > 1:
    plt.figure(dim+1)
    for i in range(0, dim-1):
        for j in range(0, dim):
            if i < j:
                plt.subplot(dim-1, dim-1, i*(dim-1) + j)
                plt.ylabel("Parameter #%d" % (i+1))
                plt.xlabel("Parameter #%d" % (j+1))
                plt.scatter(chain[j,:], chain[i,:], 0.1, color="black")
plt.show()
