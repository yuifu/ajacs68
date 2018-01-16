#####################################
	Introduction
#####################################

-This program is used for investigating cell-cell communications. Current version supports Tophat-Cuffdiff outputs. Outputs from other RNAseq analysis protocols will be supported in the next release.   
-This program is written in R and needs basic knowledge about R.


####################################
	Contact
####################################

Pls contact Stephen Wong(stwong@tmhs.org) or Fuhai Li(Fli@houstonmethodist.org) if you have any questions or suggestions. 


######################################################
		File description
######################################################



****Cuffdiff output files:
****These are sample data used in Hyejin Choi, Jianting Sheng, et.al, "Transcriptome analysis of individual stromal cell populations identifies stroma-tumor crosstalk in mouse lung cancer model," Cell Reports. 
CD11CB_output/gene_exp.diff--------------------------------cuffdiff output file for Macrophages(stroma vs tumor associated stroma)
EP_output/gene_exp.diff&genes.read_group_tracking----------cuffdiff output file for Tumor cells(tumor vs normal)
MMC_output/gene_exp.diff-----------------------------------cuffdiff output file for Myeloid monocytic cells(stroma vs tumor associated stroma)
Neu_output/gene_exp.diff-----------------------------------cuffdiff output file for Neutrophils(stroma vs tumor associated stroma)


****Newly added KEGG signaling pathways:
AMPK signaling pathway.txt
tnf signaling pathway.txt
cGMP signaling pathway.txt
Ras signaling pathway.txt
Rap1 signaling pathway.txt
FoxO signaling pathway.txt

****main program
CCCExplorer.R----------------------------main program for CCCexplorer


****other support files
HOM_MouseHumanSequence.rpt---------------mice genes to human orthologous genes mapping file
KEGG_edge_directed.txt-------------------KEGG pathways in edge matrix format
KEGG_selected_pathway.txt----------------KEGG pathways that will be considered (users can add or remove pathways)
LR_manual_revised.txt--------------------manually revised ligand-receptor pairs
TRED known TF targets files.xls----------transcription factor and their targets information from TRED
manual_binding.txt-----------------------manually revised herterodimer files 




########################################
	Run the program
########################################
step 1: install R and the packages mentioned in CCCexplorer.R
step 2: download CCCExplorer.R, the newly added KEGG pathway files as well as other support files and put them in the same folder.
step 3: download the sample files or use your own data file (cuffdiff output). Put them in the same folder with CCCExplorer.R. The sample files study the autocrine signaling for tumor cells and
	the paracrine signaling for three stroma cell types.  
step 4: make necessary changes in CCCExplorer.R according to the annotations.  
step 5: choose which file you'd like to output from CCCexplorer.R
	---remove "#" before "write.table" or set the "output_*" to "T" for the files you want to output.
	---By default, only files used for generating the cell communication networks will be output from the program. 
step 6: Using cytoscape(or other software) to generate network veiw of cell crosstalk.
	---the output files from step 5 can be used as inputs for cytoscape directly. For other software, pls modify the file format accordingly.
 