# Developers

## How to contribute

## Accessing the internal Data

### Simulation Data Object

To directly check the results and to do more detailed analyses directly inspect the [`Simulation_Data`](@ref MetaRange.Simulation_Data) object. In julia this is done by looking at the fields with the period character `.`. So to see the final population size of the first species you would use:

```julia
SD.species[1].abundances[:,:,end]
```  

## Internal structures

```@autodocs
Modules = [MetaRange]
```
