"""
Constants that are used in the calculation of parameters with the Metabolic Theory of Ecology. 
E is the activation energy and exp is the exponent for demographic parameters.
k is the Boltzmann constant in Ev/Kelvin.
"""

const E_allee = 0.65
const E_bevmort = 0.65
const E_carry = -0.65
const E_growrate = 0.65
const k_jk = 1.380649e-23
const e = 1.602176634e-19
const k = k_jk / e
const exp_allee = -0.75
const exp_bevmort = -0.25
const exp_carry = -0.75
const exp_growrate = -0.25
