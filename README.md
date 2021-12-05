# phylogenetic-tree-comparison
Course: Comp 7934   
Students: Raquel Thiessen (7813231), Vasena Jayamanna (7902600)

## Setup
### Install Python3
Currently we are using python 3.8.5

### Install Other Requirements   
Run: `pip install -r requirements.txt`


## File Organization
- In the **data sets** folder there is the input gene tree data and the true species tree data used for comparison of accuracy
- The packages for the algorithms we are comparing are in the **packages** folder
- Our code to run the comparison is in **src**
- The results are in the **results** folder and are sorted by which package the results are for
- The output for each input file consists of the species tree and the log file for the run


## Run Program
`python3 src/main.py`