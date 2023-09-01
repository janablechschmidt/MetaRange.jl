# Testfile to run manually with a debugger in VSCode
using MetaRange

config_path = "test/testfiles/testconfig/"
SD = read_input(config_path)
run_simulation!(SD)
