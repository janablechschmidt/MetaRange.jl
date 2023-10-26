# Testfile to run manually with a debugger in VSCode
using MetaRange

config_path = "C:\\Users\\jab50ej\\Documents\\MetaRangeTutorial\\static\\configuration.csv"
SD = read_input(config_path)
run_simulation!(SD)
