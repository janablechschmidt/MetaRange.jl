# Usage

## Configuration

Configuration files for MetaRange are most commonly to be supplied together in a folder.  

```text
configuration
├── configuration.csv
└── environment
│   ├── Parameter_1.csv
│   ├── Parameter_2.csv
│   └── ...
└── species
    ├── Species_1.csv
    ├── Species_2.csv
    └── ...
```

### Configuration File

Configuration files are supplied as Space separated `.csv` files.  Files are formatted very strictly, no
comments or trailing spaces are allowed. Empty lines are okay for formatting.  

```text
Argument Value
Species ./species/
Temperature ./environment/Parameter_1.csv
Precipitation ./environment/Parameter_2.csv
input_backup 


```

### Environment Files

### Species Files

## Running the simulation

## Output
