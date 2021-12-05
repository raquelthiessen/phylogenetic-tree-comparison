#!/bin/bash
# outerFolder_arr=('100gene-100bp' '100gene-1000bp' '1000gene-100bp' '1000gene-1000bp')
trueTreeName="true_tree_trimmed"
outerFolder_arr=('100gene-100bp' '100gene-1000bp' '1000gene-100bp' '1000gene-1000bp' '100gene-true' '1000gene-true')


makeDirectoriesAndCopyGeneTrees()
{
	for (( iter = 0; iter < ${#outerFolder_arr[*]}; iter++ ))
	do
		
		folderName=${outerFolder_arr[$iter]}
		
		if [[ $iter -le 3 ]]; then
			otherFolder="$folderName/estimated-genetrees"
		else
			otherFolder="$folderName"
		fi

		## make directories ##
		## mkdir "$folderName"

		for (( i = 1; i <= 10; i++ )); do
			wt_file_name="$folderName/R$i/weighted_quartets"
			
			## make directories ##
			## mkdir "$folderName/R$i"		

			## copy gene-trees ##
			## cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/15-taxon/$folderName/R$i/ALL_GT_NEW.tre" "$folderName/R$i/all_gt.tre"

			## count lines ##
			# wc -l "$folderName/R$i/all_gt.tre"

			# diff "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/15-taxon/$otherFolder/R$i/weighted_quartets" "$folderName/R$i/weighted_quartets"

			cp "/home/mahim/Desktop/Thesis_Things/Stelar_Testing/STELAR/stelar-datasets/15-taxon/$otherFolder/R$i/astral.5.7.3_June9.tre" "$folderName/R$i/astral-July26.5.7.3.tre"


		done
		# echo
	done	

}

generateWQRTS()
{
	# new_folders=('100gene-100bp/estimated-genetrees' '100gene-1000bp/estimated-genetrees' '1000gene-100bp/estimated-genetrees' '1000gene-1000bp/estimated-genetrees')
	new_folders=('1000gene-true')
	for (( iter = 0; iter < ${#new_folders[*]}; iter++ ))
	do
		folderName=${new_folders[$iter]}
		for i in {1..10}; do
			./quartet-controller.sh "$folderName/R$i/ALL_GT_NEW.tre" "$folderName/R$i/weighted_quartets"
			# rm -f "$folderName/R$i/ALL_GT_NEW.tre"
			# cp "$folderName/R$i/all_gt.tree" "$folderName/R$i/ALL_GT_NEW.tre"
		done
	done	
}



# --------------------------------------------------------------------------------------

makeDirectoriesAndCopyGeneTrees
