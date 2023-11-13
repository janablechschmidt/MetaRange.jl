"""
    plot_abundances(SD::Simulation_Data)

Plot the total abundances of a species over time.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = plot_abundances(SD)
julia> f
```
![Abundance plot](img/plot_abundances.png)
"""
function plot_abundances(SD::Simulation_Data)
    #abundance over time
    abundances = SD.species[1].output.abundances
    max_time = SD.parameters.timesteps
    total_abundance = [sum(skipmissing(abundances[:, :, t])) for t in 1:max_time]

    # calculate carrying capacity
    carrying_capacity = SD.species[1].output.carry
    habitat_suitability = SD.species[1].output.habitat
    carry = [
        sum(filter(!isnan, carrying_capacity[:, :, t] .* habitat_suitability[:, :, t])) for
        t in 1:max_time
    ]

    #create figure
    x = collect(1:max_time)
    #y = total_abundance
    f = Figure(; fontsize=24)
    ax = Axis(
        f[1, 1];
        title="Species Abundance over Time",
        xlabel="timestep",
        ylabel="total abundance",
    )

    lines!(ax, x, total_abundance; label="Abundance", linewidth=4)
    lines!(ax, x, carry; label="Carrying Capacity", linewidth=4)
    CairoMakie.ylims!(ax, 0, maximum(total_abundance) + 20)
    axislegend()
    return f
end

"""
    image_abundances(SD::Simulation_Data, t::Int)

Plot the species abundance in the landscape for timestep t.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `t::Int`: timestep

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = image_abundances(SD, 30)
julia> f
```
![Image of abundances on the map](img/image_abundances.png)
"""
function image_abundances(SD::Simulation_Data, t::Int)
    abundance = SD.species[1].output.abundances[:, :, t]'
    ratio =
        size(SD.species[1].output.abundances, 1) / size(SD.species[1].output.abundances, 2)
    f = Figure()
    ax = Axis(f[1, 1]; title="Abundance at Timestep $t", aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, abundance; colormap=:YlGnBu)
    Colorbar(f[1, 2], hm)
    return f
end

"""
    image_suitability(SD::Simulation_Data, t::Int)

Plot the habitat suitability of a landscape for timestep t.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `t::Int`: timestep

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = image_suitability(SD, 30)
julia> f
```
![Image of habitat suitability on the map](img/image_suitability.png)
"""
function image_suitability(SD::Simulation_Data, t::Int)
    suitability = SD.species[1].output.habitat[:, :, t]'
    ratio = size(SD.species[1].output.habitat, 1) / size(SD.species[1].output.habitat, 2)
    f = Figure()
    ax = Axis(
        f[1, 1]; title="Habitat Suitability at Timestep $t", aspect=ratio, yreversed=true
    )
    hm = CairoMakie.heatmap!(ax, suitability; colormap=:YlOrBr)
    Colorbar(f[1, 2], hm)
    return f
end

"""
    image_temperature(SD::Simulation_Data, t::Int)

Plot the temperature of a landscape for timestep t.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `t::Int`: timestep

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = image_temperature(SD, 30)
julia> f
```
![Image of temperatures on the map](img/image_temperature.png)
"""
function image_temperature(SD::Simulation_Data, t::Int)
    temp = SD.landscape.environment["temperature"][:, :, t]'
    ratio =
        size(SD.landscape.environment["temperature"], 1) /
        size(SD.landscape.environment["temperature"], 2)
    f = Figure()
    ax = Axis(f[1, 1]; title="Temperature at Timestep $t", aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, temp; colormap=:plasma)
    Colorbar(f[1, 2], hm)
    return f
end

"""
    image_precipitation(SD::Simulation_Data, t::Int)

Plot the precipitation of a landscape for timestep t.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `t::Int`: timestep

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = image_precipitation(SD, 30)
julia> f
```
![Image of precipitation levels on the map](img/image_precipitation.png)
"""
function image_precipitation(SD::Simulation_Data, t::Int)
    prec = SD.landscape.environment["precipitation"][:, :, t]'
    ratio =
        size(SD.landscape.environment["precipitation"], 1) /
        size(SD.landscape.environment["precipitation"], 2)
    f = Figure()
    ax = Axis(f[1, 1]; title="Precipitation at Timestep $t", aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, prec; colormap=:viridis)
    Colorbar(f[1, 2], hm)
    return f
end

"""
    image_restrictions(SD::Simulation_Data, t::Int)

Plot the restrictions of a landscape for timestep t.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `t::Int`: timestep

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = image_restrictions(SD, 30)
julia> f
```
"""
function image_restrictions(SD::Simulation_Data, t::Int)
    restr = SD.landscape.restrictions[:, :, t]'
    ratio = size(SD.landscape.restrictions, 1) / size(SD.landscape.restrictions, 2)
    f = Figure()
    ax = Axis(f[1, 1]; title="Restrictions at Timestep $t", aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, restr; colormap=:grays)
    Colorbar(f[1, 2], hm)
    return f
end

"""
    abundance_gif(SD::Simulation_Data; frames=2)

Create a gif of the species abundance in a landscape over time.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `frames::Int`: number of frames per second

# Returns
- The gif is saved under the name "Abundance.gif" in the output directory.

# Examples
```julia-repl
julia> abundance_gif(SD)
```
![.gif of abundance](img/static_abundances.gif)
"""
function abundance_gif(SD::Simulation_Data, frames=2)
    #get timesteps
    t = Observable(1)
    timesteps = SD.parameters.timesteps

    #find colorbar limits
    min = minimum(skipmissing(SD.species[1].output.abundances))
    max = maximum(skipmissing(SD.species[1].output.abundances))

    #set Makie Observables
    abund = @lift(SD.species[1].output.abundances[:, :, $t]')

    #create Makie Figure
    ratio =
        size(SD.species[1].output.abundances, 1) / size(SD.species[1].output.abundances, 2)
    f = Figure()
    title = Observable("Abundance at timestep $(t)")
    ax = Axis(f[1, 1]; title=title, aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, abund; colormap=:YlOrBr, colorrange=(min, max))
    Colorbar(f[1, 2], hm)

    #record GIF
    record(f, "Abundance.gif", 1:timesteps; framerate=frames) do i
        t[] = i
        title[] = "Abundance at timestep $(i)"
    end
end

"""
    suitability_gif(SD::Simulation_Data; frames=2)

Create a gif of habitat suitability in a landscape for all timesteps

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `frames::Int`: number of frames per second

# Returns
- The gif is saved under the name "Suitability.gif" in the output directory.

# Examples
```julia-repl
julia> suitability_gif(SD)
```
![.gif of suitability](img/static_suitability.gif)
"""
function suitability_gif(SD::Simulation_Data; frames=2)
    #get timesteps
    t = Observable(1)
    timesteps = SD.parameters.timesteps

    #find colorbar limits
    min = minimum(skipmissing(SD.species[1].output.habitat))
    max = maximum(skipmissing(SD.species[1].output.habitat))

    #set Makie Observables
    suitability = @lift(SD.species[1].output.habitat[:, :, $t]')

    #create Makie Figure
    ratio = size(SD.species[1].output.habitat, 1) / size(SD.species[1].output.habitat, 2)
    f = Figure()
    title = Observable("Habitat suitability at timestep $(t)")
    ax = Axis(f[1, 1]; title=title, aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, suitability; colormap=:YlOrBr, colorrange=(min, max))
    Colorbar(f[1, 2], hm)

    #record GIF
    record(f, "Suitability.gif", 1:timesteps; framerate=frames) do i
        t[] = i
        title[] = "Habitat suitability at timestep $(i)"
    end
end

"""
    carry_gif(SD::Simulation_Data; frames=2)

Create a gif of the carrying capacity in a landscape for all timesteps.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `frames::Int`: number of frames per second

# Returns
- The gif is saved under the name "CarryingCapacity.gif" in the output directory.

# Examples
```julia-repl
julia> carry_gif(SD)
```
![.gif of carrying capacity](img/static_carryingcapacity.gif)
"""
function carry_gif(SD::Simulation_Data; frames=2)
    #get timesteps
    t = Observable(1)
    timesteps = SD.parameters.timesteps

    #find colorbar limits
    min = minimum(skipmissing(SD.species[1].output.carry))
    max = maximum(skipmissing(SD.species[1].output.carry))

    #set Makie Observables
    carry = @lift(SD.species[1].output.carry[:, :, $t]')

    #create Makie Figure
    ratio = size(SD.species[1].output.carry, 1) / size(SD.species[1].output.carry, 2)
    f = Figure()
    title = Observable("Carrying Capacity at timestep $(t)")
    ax = Axis(f[1, 1]; title=title, aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, carry; colormap=:YlOrBr, colorrange=(min, max))
    Colorbar(f[1, 2], hm)

    #record GIF
    record(f, "CarryingCapacity.gif", 1:timesteps; framerate=frames) do i
        t[] = i
        title[] = "Carrying Capacity at timestep $(i)"
    end
end

"""
    reproduction_gif(SD::Simulation_Data; frames=2)

Create a gif for the reproduction rate of a species in a landscape for all timesteps.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `frames::Int`: number of frames per second

# Returns
- The gif is saved under the name "Reproduction.gif" in the output directory.

# Examples
```julia-repl
julia> reproduction_gif(SD)
```
![.gif of reproduction rate](img/static_reproduction.gif)
"""
function reproduction_gif(SD::Simulation_Data; frames=2)
    #get timesteps
    t = Observable(1)
    timesteps = SD.parameters.timesteps

    #find colorbar limits
    min = minimum(
        skipmissing(isnan(x) ? missing : x for x in SD.species[1].output.growrate)
    )
    max = maximum(
        skipmissing(isnan(x) ? missing : x for x in SD.species[1].output.growrate)
    )

    #set Makie Observables
    r = @lift(SD.species[1].output.growrate[:, :, $t]')

    #create Makie Figure
    ratio = size(SD.species[1].output.growrate, 1) / size(SD.species[1].output.growrate, 2)
    f = Figure()
    title = Observable("Reproduction rate at timestep $(t)")
    ax = Axis(f[1, 1]; title=title, aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, r; colormap=:YlOrBr, colorrange=(min, max))
    Colorbar(f[1, 2], hm)

    #record GIF
    record(f, "Reproduction.gif", 1:timesteps; framerate=frames) do i
        t[] = i
        title[] = "Reproduction rate at timestep $(i)"
    end
end

"""
    mortality_gif(SD::Simulation_Data; frames=2)

Create a gif of the mortality rate of a species in a landscape for all timesteps.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `frames::Int`: number of frames per second

# Returns
- The gif is saved under the name "Mortality.gif" in the output directory.

# Examples
```julia-repl
julia> mortality_gif(SD)
```
![.gif of mortality rate](img/static_mortality.gif)
"""
function mortality_gif(SD::Simulation_Data; frames=2)
    #get timesteps
    t = Observable(1)
    timesteps = SD.parameters.timesteps

    #find colorbar limits
    min = minimum(skipmissing(isnan(x) ? missing : x for x in SD.species[1].output.bevmort))
    max = maximum(skipmissing(isnan(x) ? missing : x for x in SD.species[1].output.bevmort))

    #set Makie Observables
    m = @lift(SD.species[1].output.bevmort[:, :, $t]')

    #create Makie Figure
    ratio = size(SD.species[1].output.bevmort, 1) / size(SD.species[1].output.bevmort, 2)
    f = Figure()
    title = Observable("Mortality rate at timestep $(t)")
    ax = Axis(f[1, 1]; title=title, aspect=ratio, yreversed=true)
    hm = CairoMakie.heatmap!(ax, m; colormap=:YlOrBr, colorrange=(min, max))
    Colorbar(f[1, 2], hm)

    #record GIF
    record(f, "Mortality.gif", 1:timesteps; framerate=frames) do i
        t[] = i
        title[] = "Mortality rate at timestep $(i)"
    end
end

"""
    plot_all(SD::Simulation_Data, t::Int)

Plot all input and output variables for a given timestep.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `t::Int`: timestep

# Returns
- `f::Figure`: Figure object

# Examples
```julia-repl
julia> f = plot_all(SD, 19)
julia> f
```
![All plots](img/plot_all.png)
"""
function plot_all(SD::Simulation_Data, t::Int)
    temp = SD.landscape.environment["temperature"][:, :, t]'
    prec = SD.landscape.environment["precipitation"][:, :, t]'
    suitability = SD.species[1].output.habitat[:, :, t]'
    abundance = SD.species[1].output.abundances[:, :, t]'
    start_prec = minimum(filter(!isnan, prec))
    stop_prec = maximum(filter(!isnan, prec))
    start_temp = minimum(filter(!isnan, temp))
    stop_temp = maximum(filter(!isnan, temp))
    x_prec = collect(range(0; stop=(stop_prec * 2), length=1000)) #TODO find better start-stop
    y_prec = get_habitat_suit(
        SD.species[1].traits.env_preferences["precipitation"].upper_limit,
        SD.species[1].traits.env_preferences["precipitation"].optimum,
        SD.species[1].traits.env_preferences["precipitation"].lower_limit,
        x_prec,
    )
    x_temp = collect(
        range(
            (start_temp - start_temp / 10); stop=(stop_temp + (stop_temp / 10)), length=1000
        ),
    ) #TODO find better start-stop
    y_temp = get_habitat_suit(
        SD.species[1].traits.env_preferences["temperature"].upper_limit,
        SD.species[1].traits.env_preferences["temperature"].optimum,
        SD.species[1].traits.env_preferences["temperature"].lower_limit,
        x_temp,
    )

    f = Figure(; resolution=(1200, 800), figure_padding=1)

    ratio =
        size(SD.species[1].output.abundances, 1) / size(SD.species[1].output.abundances, 2)

    box_size_l = 12

    box_size_r = 7

    plot_size = 4

    f_left = f[1:2, 1:6] = GridLayout()
    f_right = f[1:2, 7:9] = GridLayout()

    box_left = Box(
        f_left[1:(box_size_l - 2), 1:box_size_l];
        color=(:gray80, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
        #padding=(50, 80, 80, 50),
    )

    box_right = Box(
        f_right[1:(box_size_l - 2), 1:box_size_r];
        color=(:white, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
    )

    title_left = Label(
        f_left[1, 2:(box_size_l - 1), Top()],
        "Input parameters";
        fontsize=26,
        font=:bold,
        padding=(0, 20, 20, 0),
    )

    title_right = Label(
        f_right[1, 2:(box_size_r - 1), Top()],
        "Output";
        fontsize=26,
        font=:bold,
        padding=(0, 20, 20, 0),
    )

    ax1 = Axis(
        f_left[2:(1 + plot_size), 2:(1 + plot_size)];
        title="Temperature tolerance",
        xlabel="temperature [K]",
        ylabel="fitness",
    )
    tol_t = CairoMakie.lines!(ax1, x_temp, y_temp)

    ax2 = Axis(
        f_left[2:(1 + plot_size), (3 + plot_size):(2 + plot_size * 2)];
        title="Precipitation tolerance",
        xlabel="precipitation [mm]",
        ylabel="fitness",
    )
    tol_p = CairoMakie.lines!(ax2, x_prec, y_prec)

    ax3 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)];
        title="Temperature at t = $t",
        aspect=ratio,
    )
    hm3 = CairoMakie.heatmap!(ax3, temp; colormap=:plasma)
    Colorbar(f_left[(2 + plot_size):(1 + plot_size * 2), 2 + plot_size], hm3)
    ax3.yreversed = true
    ax4 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), (3 + plot_size):(2 + plot_size * 2)];
        title="Precipitation at t = $t",
        aspect=ratio,
    )
    hm4 = CairoMakie.heatmap!(ax4, prec; colormap=:viridis)
    Colorbar(f_left[(2 + plot_size):(1 + plot_size * 2), 3 + plot_size * 2], hm4)
    ax4.yreversed = true
    ax5 = Axis(
        f_right[2:(1 + plot_size), 2:(1 + plot_size)];
        title="Habitat Suitability at t = $t",
        aspect=ratio,
    )
    hm5 = CairoMakie.heatmap!(ax5, suitability; colormap=:YlOrBr)
    Colorbar(f_right[2:(1 + plot_size), (box_size_r - 1)], hm5)
    ax5.yreversed = true
    ax6 = Axis(
        f_right[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)];
        title="Abundance at t = $t",
        aspect=ratio,
    )
    hm6 = CairoMakie.heatmap!(ax6, abundance; colormap=:YlGnBu)
    Colorbar(f_right[(2 + plot_size):(1 + plot_size * 2), (box_size_r - 1)], hm6)
    ax6.yreversed = true
    return f
end

"""
    all_gif(SD::Simulation_Data; frames = 2)

Plot all input and output variables and create a GIF.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object
- `frames::Int`: framerate

# Returns
- The gif is saved under the name "all.gif" in the output directory.

# Examples
```julia-repl
julia> all_gif(SD)
```
![Gif of input and output plots](img/dynamic_all.gif)
"""
function all_gif(SD::Simulation_Data; frames=2)
    t = Observable(1)
    timesteps = SD.parameters.timesteps
    temp = @lift(SD.landscape.environment["temperature"][:, :, $t]')
    prec = @lift(SD.landscape.environment["precipitation"][:, :, $t]')
    suitability = @lift(SD.species[1].output.habitat[:, :, $t]')
    abundance = @lift(SD.species[1].output.abundances[:, :, $t]')
    start_prec = minimum(filter(!isnan, SD.landscape.environment["precipitation"]))
    stop_prec = maximum(filter(!isnan, SD.landscape.environment["precipitation"]))
    start_temp = minimum(filter(!isnan, SD.landscape.environment["temperature"]))
    stop_temp = maximum(filter(!isnan, SD.landscape.environment["temperature"]))
    x_prec = collect(range(0; stop=(stop_prec * 2), length=1000)) #TODO find better start-stop
    y_prec = get_habitat_suit(
        SD.species[1].traits.env_preferences["precipitation"].upper_limit,
        SD.species[1].traits.env_preferences["precipitation"].optimum,
        SD.species[1].traits.env_preferences["precipitation"].lower_limit,
        x_prec,
    )
    x_temp = collect(
        range(
            (start_temp - start_temp / 10); stop=(stop_temp + (stop_temp / 10)), length=1000
        ),
    ) #TODO find better start-stop
    y_temp = get_habitat_suit(
        SD.species[1].traits.env_preferences["temperature"].upper_limit,
        SD.species[1].traits.env_preferences["temperature"].optimum,
        SD.species[1].traits.env_preferences["temperature"].lower_limit,
        x_temp,
    )

    f = Figure(; resolution=(1200, 800), figure_padding=1)

    ratio =
        size(SD.species[1].output.abundances, 1) / size(SD.species[1].output.abundances, 2)

    box_size_l = 12

    box_size_r = 7

    plot_size = 4

    f_left = f[1:2, 1:6] = GridLayout()
    f_right = f[1:2, 7:9] = GridLayout()

    box_left = Box(
        f_left[1:(box_size_l - 2), 1:box_size_l];
        color=(:gray80, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
        #padding=(50, 80, 80, 50),
    )

    box_right = Box(
        f_right[1:(box_size_l - 2), 1:box_size_r];
        color=(:white, 0.5),
        alignmode=Outside(),
        strokecolor=:black,
    )

    title_left = Label(
        f_left[1, 2:(box_size_l - 1), Top()],
        "Input parameters";
        fontsize=26,
        font=:bold,
        padding=(0, 20, 20, 0),
    )
    tt = Observable("timestep $(t)")
    title_middle = Label(
        f_left[1, 10:(box_size_l), Top()],
        tt;
        fontsize=32,
        font=:bold,
        padding=(0, 20, 20, 0),
    )
    title_right = Label(
        f_right[1, 2:(box_size_r - 1), Top()],
        "Output";
        fontsize=26,
        font=:bold,
        padding=(0, 20, 20, 0),
    )

    ax1 = Axis(
        f_left[2:(1 + plot_size), 2:(1 + plot_size)];
        title="Temperature tolerance",
        xlabel="temperature [K]",
        ylabel="fitness",
    )
    tol_t = CairoMakie.lines!(ax1, x_temp, y_temp)

    ax2 = Axis(
        f_left[2:(1 + plot_size), (3 + plot_size):(2 + plot_size * 2)];
        title="Precipitation tolerance",
        xlabel="precipitation [mm]",
        ylabel="fitness",
    )
    tol_p = CairoMakie.lines!(ax2, x_prec, y_prec)
    min_t = minimum(
        skipmissing(isnan(x) ? missing : x for x in SD.landscape.environment["temperature"])
    )
    max_t = maximum(
        skipmissing(isnan(x) ? missing : x for x in SD.landscape.environment["temperature"])
    )
    ax3 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)];
        title="Temperature",
        aspect=ratio,
        yreversed=true,
    )
    hm3 = CairoMakie.heatmap!(ax3, temp; colormap=:plasma, colorrange=(min_t, max_t))
    Colorbar(f_left[(2 + plot_size):(1 + plot_size * 2), 2 + plot_size], hm3)
    ax4 = Axis(
        f_left[(2 + plot_size):(1 + plot_size * 2), (3 + plot_size):(2 + plot_size * 2)];
        title="Precipitation",
        aspect=ratio,
        yreversed=true,
    )
    min_p = minimum(
        skipmissing(
            isnan(x) ? missing : x for x in SD.landscape.environment["precipitation"]
        ),
    )
    max_p = maximum(
        skipmissing(
            isnan(x) ? missing : x for x in SD.landscape.environment["precipitation"]
        ),
    )
    hm4 = CairoMakie.heatmap!(ax4, prec; colormap=:viridis, colorrange=(min_p, max_p))
    Colorbar(f_left[(2 + plot_size):(1 + plot_size * 2), 3 + plot_size * 2], hm4)
    ax5 = Axis(
        f_right[2:(1 + plot_size), 2:(1 + plot_size)];
        title="Habitat Suitability",
        aspect=ratio,
        yreversed=true,
    )
    min_suit = minimum(
        skipmissing(isnan(x) ? missing : x for x in SD.species[1].output.habitat)
    )
    max_suit = maximum(
        skipmissing(isnan(x) ? missing : x for x in SD.species[1].output.habitat)
    )
    hm5 = CairoMakie.heatmap!(
        ax5, suitability; colormap=:YlOrBr, colorrange=(min_suit, max_suit)
    )
    Colorbar(f_right[2:(1 + plot_size), (box_size_r - 1)], hm5)
    ax6 = Axis(
        f_right[(2 + plot_size):(1 + plot_size * 2), 2:(1 + plot_size)];
        title="Abundance",
        aspect=ratio,
        yreversed=true,
    )
    min_ab = minimum(skipmissing(SD.species[1].output.abundances))
    max_ab = maximum(skipmissing(SD.species[1].output.abundances))
    hm6 = CairoMakie.heatmap!(ax6, abundance; colormap=:YlGnBu, colorrange=(min_ab, max_ab))
    Colorbar(f_right[(2 + plot_size):(1 + plot_size * 2), (box_size_r - 1)], hm6)
    #record GIF
    record(f, "all.gif", 1:timesteps; framerate=frames) do i
        t[] = i
        tt[] = "timestep $(i)"
    end
end

"""
    save_all(SD::Simulation_Data)

Save all output variables in a .csv file.

This function writes all output variables - reproduction, mortality rate, carrying capacity, habitat suitability,
    abundance - into a .csv file.

# Arguments
- `SD::Simulation_Data`: Simulation_Data object

# Returns
- The .csv file is saved under the name "output.csv" in the output directory.

# Examples
```julia-repl
julia> save_all(SD)
```
"""
function save_all(SD::Simulation_Data)
    abundance = vec(SD.species[1].output.abundances)
    habitat = vec(SD.species[1].output.habitat)
    reproduction = vec(SD.species[1].output.growrate)
    carry = vec(SD.species[1].output.carry)
    bevmort = vec(SD.species[1].output.bevmort)
    inds = vec(CartesianIndices(SD.species[1].output.abundances))
    t = getindex.(inds, 3)
    x = getindex.(inds, 2)
    y = getindex.(inds, 1)
    abundance_out = hcat(t, x, y, abundance, repeat(["abundance"], length(t)))
    reproduction_out = hcat(t, x, y, reproduction, repeat(["reproduction"], length(t)))
    habitat_out = hcat(t, x, y, habitat, repeat(["habitat"], length(t)))
    carry_out = hcat(t, x, y, carry, repeat(["carry"], length(t)))
    bevmort_out = hcat(t, x, y, bevmort, repeat(["bevmort"], length(t)))
    out = vcat(abundance_out, habitat_out, reproduction_out, carry_out, bevmort_out)
    make_out_dir(SD.parameters.output_dir)
    return writedlm(joinpath(SD.parameters.output_dir, "output.csv"), out, ',')
end
