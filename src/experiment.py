import os

data_dir = 'data_sets'
result_dir = 'results'
a_pro = 'A-pro'
astral_mp = 'ASTRAL-MP'
wQFM = 'wQFM'

class PhylogeneticTreeExperiment():
    def __init__(self):
        pass

    def run_a_pro(self, input, output):
        pass
    
    def run_astral_mp(self, input, output):
        pass

    def run_wQFM(self, input, output):
        pass

    def run_experiment(self, data_set='true-gene-trees'):
        for subdir, dirs, files in os.walk(data_dir):
            if data_set in subdir:
                for file in files:
                    print(os.path.join(subdir, file))

    def run_analysis():
        for subdir, dirs, files in os.walk(result_dir):
            for file in files:
                print(os.path.join(subdir, file))