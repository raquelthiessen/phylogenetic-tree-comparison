"""
    File: Experiment File
    Course: Comp 7934
    Authors: Raquel Thiessen, Vasena Jayamanna
"""

import os
import subprocess
from abc import ABC, abstractmethod

# Constants
data_dir = 'data_sets/gene-trees'
result_dir = 'results'
output_file_name = 'speciestree'


class Package(ABC):
    """
        Template for our package classes
    """

    """
        Method to run the package and pipe the output

        Parameters:
            input: the input file path
            output: the output file path
    """
    @abstractmethod
    def run(self, input, output):
        pass
    
    """
        Method to clear the result folder for the package
    """
    @abstractmethod
    def clear_result_folder():
        pass


class wQFM(Package):
    """
        Package Class for wQFM
    """
    def __init__(self):
        self.package_name = 'wQFM'
        self.running_dir = 'wQFM'
    
    def run(self, input, output):
        pass

    def clear_result_folder(self):
        os.system('rm -r results/{}/*'.format(self.package_name))


class ASTRAL_PRO(Package):
    """
        Package Class for ASTRAL PRO
    """
    def __init__(self):
        self.package_name = 'A-pro'
        self.running_dir = 'A-pro/ASTRAL-MP'
    
    def run(self, input, output):
        os.system('cd packages/{};java -D"java.library.path=lib/" -jar astral.1.1.6.jar -i {} > {}'.format(self.running_dir, input, output))

    def clear_result_folder(self):
        os.system('rm -r results/{}/*'.format(self.package_name))


class ASTRAL_MP(Package):
    """
        Package Class for ASTRAL MP
    """
    def __init__(self):
        self.package_name = 'ASTRAL-MP'
        self.running_dir = 'ASTRAL-MP'
    
    def run(self, input, output):
        pass

    def clear_result_folder(self):
        os.system('rm -r results/{}/*'.format(self.package_name))



class PhylogeneticTreeExperiment():
    """
        Main Experiment Class
    """
    def __init__(self):
        self.working_directory = subprocess.check_output("echo $PWD", shell=True).decode("utf-8").strip()
        self.a_pro = ASTRAL_PRO()
        self.packages = [self.a_pro]
        self.clear_folders()

    """
        Clear the result folders for all the packages
    """
    def clear_folders(self):
        for package in self.packages:
            package.clear_result_folder()

    """
        Get the input and output file paths

        Parameters:
            subdir: the subdirectory we are working in
            file: the input file name
            package: the current package we are working on

        Returns:
            input_file: the input file path (absolute path)
            output_file: the output file path (absolute path)
    """
    def get_file_paths(self, subdir, file, package):
        file_path = os.path.join(subdir, file)
        input_file = self.working_directory + "/" + file_path
        output_dir = self.working_directory + "/" + result_dir + "/" + package.package_name + "/" + subdir

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        output_file = output_dir + "/" + output_file_name

        return input_file, output_file

    """
        Main function to run the experiment
    """
    def run_experiment(self):
        for subdir, dirs, files in os.walk(data_dir):
            for file in files:
                # For mac users, ignore this file
                if "DS_Store" in file:
                    continue
    
                for package in self.packages:
                    input_file, output_file = self.get_file_paths(subdir=subdir, file=file, package=package)
                    package.run(input_file, output_file)

    def run_analysis():
        for subdir, dirs, files in os.walk(result_dir):
            for file in files:
                print(os.path.join(subdir, file))