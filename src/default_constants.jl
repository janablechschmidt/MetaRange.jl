const E_allee = 0.65 #Between 0.6 and 0.7
const E_bevmort = 0.65 #Between 0.6 and 0.7
const E_carry = -0.65 #Between 0.6 and 0.7
const E_growrate = 0.65 #Between 0.6 and 0.7
const k_jk = 1.380649e-23 # Boltzmann constant in Joule/Kelvin, Don't change!
const e = 1.602176634e-19 # Electric charge
const k = k_jk / e
const exp_allee = -0.75 #Between -1 and 1
const exp_bevmort = -0.25 #Between -1 and 1
const exp_carry = -0.75 #Between -1 and 1
const exp_growrate = -0.25 #Between -1 and 1

"""
    get_boltzmann()

Converts Boltzmann constant k to Ev/Kelvin
"""
function get_boltzmann()
    return k_jk / e
end
