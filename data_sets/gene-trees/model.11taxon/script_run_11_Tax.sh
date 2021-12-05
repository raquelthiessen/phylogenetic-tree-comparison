#!/bin/bash

mode=1; # mode == 1, estimated || else mode == 2, simulated

run()
{
	if [[ $mode -eq 1 ]]; then
		mode_str="ESTIMATED"
		outerFolder="estimated_Xgenes_strongILS"
		innerFolder_arr=('estimated_5genes_strongILS' 'estimated_15genes_strongILS' 'estimated_25genes_strongILS' 'estimated_50genes_strongILS' 'estimated_100genes_strongILS')
		trueTreeName="true_tree_trimmed"
	else
		mode_str="SIMULATED"
		outerFolder="simulated_Xgenes_strongILS"
		innerFolder_arr=('simulated_5genes_strongILS' 'simulated_15genes_strongILS' 'simulated_25genes_strongILS' 'simulated_50genes_strongILS' 'simulated_100genes_strongILS')
		trueTreeName="model_tree"
	fi
	subscript_arr=('5genes' '15genes' '25genes' '50genes' '100genes')

	## make directories ##
	## mkdir "$outerFolder"


	for (( iter = 0; iter < ${#innerFolder_arr[*]}; iter++ ))
	do
		# subscript_name=${subscript_arr[$iter]}
		folderName_init=${innerFolder_arr[$iter]}
		folderName="$outerFolder/$folderName_init"

		
		## make directories ##
		## mkdir "$folderName"
		
		## copy gene trees. [cp src dest]


		for (( i = 1; i <= 20; i++ )); do
			# Rep1_5genes.astral
			# wt_file_name="$folderName/R$i/weighted_quartets"

			## make directories ##
			## mkdir "$folderName/R$i"

			## copy gene-trees ##
			## cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/11-taxon/$folderName/R$i/all_gt.tre" "$folderName/R$i/all_gt.tre"

			## count num-genes ##
			## wc -l "$folderName/R$i/all_gt.tre"

			# echo  "$folderName/R$i/weighted_quartets "
			# diff "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/11-taxon/$folderName/R$i/weighted_quartets" "$folderName/R$i/weighted_quartets"

			# cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/11-taxon/$folderName/R$i/astral_9June.5.7.3.tre" "$folderName/R$i/astral-July26.5.7.3.tre"

			

		done
		echo
	done
}

mode=2 # first simulated
run


mode=1 # second estimated
run
