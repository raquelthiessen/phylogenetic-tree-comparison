#!/bin/bash

outer_directories=('noscale.100g.500b' 'noscale.200g.1000b' 'noscale.200g.1500b' 'noscale.200g.250b' 'noscale.200g.true' 
'noscale.25g.500b' 'noscale.400g.500b' 'noscale.50g.500b' 'noscale.800g.500b' 'scale2d.200g.500b' 'scale2u.200g.500b' 
'noscale.200g.500b_ACTUALLY_scale2d.200g.500bp_ONADER') # 7 MAY 2020 for astral RF


here_directories=('noscale.100g.500b' 'noscale.200g.1000b' 'noscale.200g.1500b' 'noscale.200g.250b' 'noscale.200g.true' 
'noscale.25g.500b' 'noscale.400g.500b' 'noscale.50g.500b' 'noscale.800g.500b' 'scale2d.200g.500b' 'scale2u.200g.500b' 
'noscale.200g.500b') # 7 MAY 2020 for astral RF


trueTreeName="true_tree_trimmed"

makeDirectoriesAndCopyGTs()
{
	#  for outerFolder in *scale*
	for (( iter = 0; iter < ${#outer_directories[*]}; iter++ ));
	do
		folderName=${outer_directories[$iter]}
		hereFolder=${here_directories[$iter]}
		
		## make directories ##
		# mkdir "$folderName"

		for i in {1..20}
		do
			## make directories ##
			# mkdir "$folderName/R$i"

			## copy gene trees ##
			# cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/37-taxon/$folderName/R$i/all_gt.tre" "$folderName/R$i/all_gt.tre"

			## count lines ##
			# wc -l "$folderName/R$i/all_gt.tre"

			# diff "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/37-taxon/$folderName/R$i/weighted_quartets" "$hereFolder/R$i/weighted_quartets"

			cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/37-taxon/$folderName/R$i/astral.5.7.3_heuristic_June9.tre" "$hereFolder/R$i/astral-July26.5.7.3.tre"

			# cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/15-taxon/$otherFolder/R$i/astral.5.7.3_June9.tre" "$folderName/R$i/astral-July26.5.7.3.tre"


		done
		echo

	done		
}


makeDirectoriesAndCopyGTs


