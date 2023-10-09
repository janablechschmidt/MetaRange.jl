# Instructions for Newbies

Welcome Newbies!
This is a step-by-step guide for anyone who is new to Julia and/or modelling in general. We hope you find any information you need here. 

## Setting up Julia on your PC
### Downloading Julia
First things first: Let's [install Julia](https://julialang.org/downloads/). Download the version that corresponds to your operating system and install it on your device.
### Downloading VSCode
It is best to use a User Interface when applying MetaRange, though it is not required. We recommend using VSCode - if you have used RStudio before, you will find this very intuitive to use. If not, don't worry, it's less complicated than it looks.
Download VSCode [here](https://code.visualstudio.com/Download) and install it on your PC.
### Connecting the two
Now, we need to set VSCode up so it knows that you want to program in Julia language. To do so, open VSCode. In the top menu bar, select "View", then "Extensions". In the appearing search bar, type "julia". Select the Julia extension and hit the "Install" button. Finally, restart VSCode.
You have now connected Julia and VSCode! 
## Setting up MetaRange
Now, we need to open a terminal. In the top menu bar, select "Terminal" and then "New Terminal". Then, press and hold Alt, and press "j" and then "o" while holding Alt. This will tell it "Julia open", so it starts up Julia in your terminal. 
To the left of your coursor, it should now say "julia>". 

To set up MetaRange, type the following:
```julia
import Pkg; Pkg.add(url = "https://github.com/janablechschmidt/MetaRange.jl.git")
```
This will download MetaRange as a package and install it with all its necessary dependencies, so you don't have to worry about those.
Installation may take a while. You'll know it's done when on the far left of your terminal, the word "julia>" appears on the bottom again.

### Where did it install
When installation is done, you'll need to locate the package on your PC. On windows, packages typically install inside the folder called ".julia" (the dot indicates that this folder is hidden), which contains a folder called "packages". If you cannot find it, try searching for "MetaRange" in the search bar.
Once you've located it, it is recommended to copy the folder "examples" from the MetaRange package to the place where you want to run your simulations.

## Using MetaRange - Example folder
You'll see that there are two folders inside the examples folder. One contains a static environment, meaning environmental conditions stay the same throughout all timesteps. The other one contains some environmental change, so conditions will vary with each timestep.
Let's take a look at the files in the "static environment" folder for now.

### Configuration file
The CSV file "configuration.csv" contains instructions for the model on the simulation settings. It has several optional parameters and four required ones: 
- experiment_name: the folder that contains all simulation inputs, in this case "Experiment2_Static_Environment"
- timesteps: number of timesteps to be simulated, in this case 50
- temperature: where the model can find your temperature input. Can either be a CSV file or a folder containing multiple CSV files in alphabetical order
- precipitation: where the model can find your precipitation input. Can either be a CSV file or a folder containing multiple CSV files in alphabetical order
For the optional parameters, refer to the parameters section of the documentation.

### Environment folder
This folder contains the environment that you want to model your species in. It can contain one CSV file for each environmental variable, which means the environment will stay the same for each timestep. Alternatively, it can contain folders with one CSV file for each timestep. These need to be named in a way that can be sorted by your PC - for example, you can name them "Temp1.csv", "Temp2.csv", etc. If you use one single CSV file, put its name in the corresponding row of the config file. If you are using multiple files, put the name of the folder that contains them.
In our example, we are modelling "Example2_Static_Environment" for 50 timesteps and provide precipitation.csv and temperature.csv.

### Species folder
The species folder contains information on the species that you are modelling. It has to contain one CSV file per species.

!!! note
    Multiple species modelling is currently broken. You can only simulate one species at a time.

You'll need to supply parameters on your species' demographics, mass, environmental preferences, and dispersal abilities. Check out the species.csv to have a look at all required parameters and refer to the parameters section of the documentation for more info.

### Running the simulation 
Let's try running the example on your machine.
Use
```julia
using MetaRange
```
to tell your PC that you want to use functions from the MetaRange package.
It's easiest to run the model from where you saved your simulation inputs. So, let's say you saved your input folder in a path like "C:\\Users\\yourname\\Simulations\\".
To change your working directory to that folder, type 
```julia
cd("C:\\Users\\yourname\\Simulations")
```
If you are ever unsure about where your computer currently thinks you are, you can type `pwd()` (short for "print working directory") and your PC will tell you in which folder it currently is.

Next up, we'll read the input files into the model to set up the simulation. Type
```julia
SD = read_input("./Example2_Static_Environment/configuration.csv")
```
You are doing two things here. First, you are naming a variable called SD - short for Simulation Data - and assigning it the result of the read_input() function. Second, you are telling read_input() where it can find the simulation configurations: in a folder called "Example2_Static_Environment" in a file called "configuration.csv".

Finally, it is time for the simulation itself.
```julia
run_simulation!(SD)
```
You are now telling the model to run the simulation on your previously created variable "SD". The exclamation point behind the function name indicates that the variable you give it as an argument, SD, will be altered by the function.


## Using MetaRange - Use your own data
