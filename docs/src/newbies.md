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


## Using MetaRange - Use your own data
