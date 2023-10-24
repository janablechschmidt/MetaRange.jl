# Testfile to run manually with a debugger in VSCode
using MetaRange

config_path = "C:\\Users\\jblec\\Documents\\MetaRangeTutorial\\Example1_Static_Environment\\configuration.csv"
SD = read_input(config_path)
run_simulation!(SD)
