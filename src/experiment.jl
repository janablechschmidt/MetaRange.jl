using MetaRange
base_path = "C:\\Users\\jab50ej\\Documents\\Andre\\input_files\\"
species = readdir(base_path)
scenarios = readdir(base_path * species[1])
for sp in species
    for scen in scenarios
        config_path = base_path * sp * "\\" * scen * "\\configuration.csv"
        SD = read_input(config_path)
        run_simulation!(SD)
        save_output(SD)
    end
end
