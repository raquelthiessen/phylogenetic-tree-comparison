# phylogenetic-tree-comparison
Course: Comp 7934   
Students: Raquel Thiessen (7813231), Vasena Jayamanna (7902600)

## Setup
### Install Python3 (and R for analysis)
Currently we are using python 3.8.5 and R version 4.1.2 (latter is for figures and result processing)

### Install Other Requirements   
Run: `pip install -r requirements.txt`

(For R requirements, run `Rscript src/r_requirements.R`)


### Package setup
If any of the packages do not run properly, pull from the following and follow the instructions from each project (may have to run `./make.sh` to build the project for ASTRAL-MP):
- [ASTRAL-MP](https://github.com/smirarab/ASTRAL/tree/MP)
- [ASTRAL-Pro](https://github.com/chaoszhang/A-pro)
- [wQFM](https://github.com/Mahim1997/wQFM-2020)


## File Organization
- In the **data sets** folder there is the input gene tree data and the true species tree data used for comparison of accuracy
- The packages for the algorithms we are comparing are in the **packages** folder
- Our code to run the comparison is in **src**
- The results are in the **results** folder and are sorted by which package the results are for
- The output for each input file consists of the species tree and the log file for the run


## Run Program
`python3 src/main.py`


## Figure Generation
Run: `Rscript src/processing.R` 
This will save a _metrics.txt_ file to the _results/_ directory. 

Then run: `Rscript src/plotting.R` 
This will generate the _figs/_ folder with a series of plots.
