###### functions for main loop ####

## Reproduction functions
"""
    ReproductionRicker(N::Int64, growrate::Float64, carry::Float64, unused::Union{Float64,Nothing})

Returns the number of Individuals in the next generation according to the Ricker model.
"""
function ReproductionRicker(
    N::Int64, growrate::Float64, carry::Float64, unused::Union{Float64,Nothing}
)
    N2 = N * exp(growrate * (1 - N / carry))
    return N2
end

"""
    ReproductionRickerAllee(N::Int64, growrate::Float64, carry::Float64, allee::Union{Float64,Nothing})

Returns the number of Individuals in the next generation according to the Ricker model.
Includes allee effects
"""
function ReproductionRickerAllee(
    N::Int64, growrate::Float64, carry::Float64, allee::Union{Float64,Nothing}
)
    N2 = N * exp.(growrate * ((4 * (carry .- N) * (N .- allee)) / ((carry - allee)^2)))
    return N2[1]
end

"""
    ReproductionBeverton(N::Int64, growrate::Float64, carry::Float64, mortality::Float64)

Returns the number of offspring in the next generation according to the Beverton-Holt
model.
"""
function ReproductionBeverton(
    N::Int64, growrate::Float64, carry::Float64, beverton_mort::Float64
)
    per_capa_R =
        growrate / (
            1 + (
                growrate * N /
                (carry * growrate * beverton_mort / (growrate - beverton_mort))
            )
        )
    return N * per_capa_R
end

#TODO: What does this function actually do?
"""
    MortalityBev(N::Int64, mortality::Float64)

Returns how many Individuals die. Includes Stochasticity
"""
function MortalityBev(N::Int64, beverton_mort::Float64)
    return max(0, N - rand(Binomial(round(Int64, N), beverton_mort)))
end

"""
    MortalityBevNoStoch(N::Int64, mortality::Float64)

Returns how many Individuals die. No Stochasticity
"""
function MortalityBevNoStoch(N::Int64, beverton_mort::Float64)
    return max(0, N - N * beverton_mort)
end

"""
    BV(N::Int64, growrate::Float64, carry::Float64, mortality::Float64)

Returns the number of individuals in the next generation according to the Beverton-Holt
model. Includes stochastic mortality.
"""
function BV(N::Int64, growrate::Float64, carry::Float64, beverton_mort::Float64)
    return ReproductionBeverton(N, growrate, carry, beverton_mort) +
           MortalityBev(N, beverton_mort)
end

"""
    BVNoStoch(N::Int64, growrate::Float64, carry::Float64, mortality::Float64)

Returns the number of individuals in the next generation according to the Beverton-Holt
model. Does not include stochastic mortality.
"""
function BVNoStoch(N::Int64, growrate::Float64, carry::Float64, beverton_mort::Float64)
    return ReproductionBeverton(N, growrate, carry, beverton_mort) +
           MortalityBevNoStoch(N, beverton_mort)
end

## Dispersal kernels
"""
    DispersalNegExpKernel(Dispersalbuffer, mean_dispersal_dist)

TODO
"""
function DispersalNegExpKernel(Dispersalbuffer, mean_dispersal_dist)
    x = 2 * Dispersalbuffer + 1
    y = 2 * Dispersalbuffer + 1
    sum = 0
    spDispKernel = zeros(x, y)

    for i in 1:x
        for j in 1:y
            r = sqrt(
                abs(i - (Dispersalbuffer + 1)) * abs(i - (Dispersalbuffer + 1)) +
                abs(j - (Dispersalbuffer + 1)) * abs(j - (Dispersalbuffer + 1)),
            )
            dispersal = DispersalNegExpFunction(mean_dispersal_dist, r)
            sum += dispersal
            spDispKernel[i, j] = dispersal
        end
    end
    spDispKernel
    # Normalizing
    for i in 1:x
        for j in 1:x
            spDispKernel[i, j] = spDispKernel[i, j] / sum
        end
    end
    return spDispKernel
end

"""
    DispersalNegExpFunction(alpha, r)

TODO
"""
function DispersalNegExpFunction(alpha, r)
    N = 2 * pi * (alpha * alpha)
    p = (1 / N) * exp(-r / alpha)
    if p < 0
        p = 0
    end
    return p
end

"""
    KernelDispersal!(N::Int64, Offspring::Array{Float64,2}, Dispersal_kernel::Array{Float64,2})

TODO
"""
function KernelDispersal!(
    N::Int64, Offspring::Array{Float64,2}, Dispersal_kernel::Array{Float64,2}
)
    Off = Offspring + N * Dispersal_kernel
    return Off
end

## recruitment
"""
    DispersalSurvivalStoch(
    Abundances::Array{Union{Missing, Int64},2},
    Offspring::Array{Float64,2},xy::Array{Int64,2},
    max_dispersal_dist::Int64
    )

TODO
"""
function DispersalSurvivalStoch(
    Abundances::Array{Union{Missing,Int64},2},
    Offspring::Array{Float64,2},
    xy::Array{Int64,2},
    max_dispersal_dist::Int64,
)
    for z in 1:size(xy, 1) # welche koordinaten sind suitable, nur dort recruiten
        y = xy[z, 1]
        x = xy[z, 2]
        Abundances[y, x] = rand(
            Poisson(Offspring[y + max_dispersal_dist, x + max_dispersal_dist])
        )
        # survival according to habitat suitability
    end
    return Abundances
end

"""
    DispersalSurvivalRound(
    Abundances::Array{Union{Missing, Int64},2},
    Offspring::Array{Float64,2}, xy::Array{Int64,2},
    max_dispersal_dist::Int64
    )

TODO
"""
function DispersalSurvivalRound(
    Abundances::Array{Union{Missing,Int64},2},
    Offspring::Array{Float64,2},
    xy::Array{Int64,2},
    max_dispersal_dist::Int64,
)
    for z in 1:size(xy, 1)
        y = xy[z, 1]
        x = xy[z, 2]
        Abundances[y, x] = round(
            Int64, Offspring[y + max_dispersal_dist, x + max_dispersal_dist]
        )
    end
    return Abundances
end

"""
    HabitatMortality(Abundances::Matrix{Union{Missing,Int64}}, Is_habitat::BitArray{2})

Habitat based mortality.

This function kills individuals that are in non suitable Habitat.

- `Abundances`: array with the number of individuals in the landscape
- `Is_habitat`: array with boolean values that indicate
which cell is habitat in the next timestep
"""
function HabitatMortality(Abundances::Matrix{Union{Missing,Int64}}, Is_habitat::BitArray{2})
    h = findall(iszero, Is_habitat)
    Abundances[h] .= 0
    return Abundances
end
