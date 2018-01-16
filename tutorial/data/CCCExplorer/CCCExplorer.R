###########################
# CCCExplorer version 1.0
###########################



##############	install the following packages: igraph,graphite,org.Hs.eg.db,gplots

library(igraph)
library(graphite)
library(org.Hs.eg.db)
library(gplots)


##############	read RNA-seq FPKM file (output of cuffdiff)
##############	Below is using sample files. Pls change to your owe file location) 
##############	the program focus on Neu->EP (From Neutrophils to tumor)paracrine. Pls define your own source and destination cell types 


EP=read.delim("EP_output\\gene_exp.diff")
Neu=read.delim("Neu_output\\gene_exp.diff")

EP_FPKM=read.delim("EP_output\\genes.read_group_tracking")
EP_exprs=matrix(EP_FPKM[,7],ncol=6,byrow=T)		#check your own data file to determine the matrix dimenstion
rownames(EP_exprs)=unique(EP_FPKM[,1])
colnames(EP_exprs)=c(rep("WT",3),rep("KP",3))		#define your own sample names and conditions


###########	set threshold

Fold_thres=1.5	#threshold for fold change
FPKM_thres=2	#threshold for FPKM value
q_thres=0.1	#threshold for q(adjust p) value
Express_thres=2	#threshold for FPKM values of receptors in tumor cells


###########	find up-regulated genes in tumor and tumor associated stroma
###########	find expressed receptors in tumor 

EP_up=EP[EP[,9]>FPKM_thres&EP[,10]>log2(Fold_thres)&EP[,13]<q_thres,]
EP_expressed=EP[EP[,9]>Express_thres,]

Neu_up=Neu[Neu[,9]>FPKM_thres&Neu[,10]>log2(Fold_thres)&Neu[,13]<q_thres,]


########## read manually revised LR file (KEGG cytokine, KEGG ECM, KEGG neuroactive, DLRP, STRING)

LR_manual=read.delim("LR_manual_revised.txt")
LR_manual=toupper(as.matrix(LR_manual))
Ligand=unique(LR_manual[,1])
Receptor=unique(LR_manual[,2])


##########	read mice-gene-to-human file. 
##########	if your data are from other species, pls replace the mapping files and make sure the first column of H2M contains the gene name of your species and the second column is human orthologous.
##########	if you are using human data, change H2M to an n by 2 matrix where the first column contains all human gene symbols while the second column is identical to the first column    

H2M=read.delim("HOM_MouseHumanSequence.rpt")
mouse=H2M[H2M[,2]=="mouse, laboratory",c(1,4)]
human=H2M[H2M[,2]=="human",c(1,4)]
H2M=merge(mouse,human,by.x=1,by.y=1)[,2:3]
H2M=H2M[!duplicated(H2M[,1])&!duplicated(H2M[,2]),]
H2M[H2M[,1]=="Areg",2]="AREG"


###########	match mice gene(or your species) to human

EP_exprs_human=merge(EP_exprs,H2M,by.x=0,by.y=1,sort=F)
rownames(EP_exprs_human)=EP_exprs_human[,8]
EP_exprs_human=EP_exprs_human[,-c(1,8)]

EP_human=merge(EP[,1],H2M,by.x=1,by.y=1,sort=F)
EP_up_human=merge(EP_up[,1],H2M,by.x=1,by.y=1,sort=F)
EP_expressed_human=merge(EP_expressed[,1],H2M,by.x=1,by.y=1,sort=F)
EP_expressed_human=as.matrix(EP_expressed_human)


Neu_up_human=merge(Neu_up[,1],H2M,by.x=1,by.y=1,sort=F)

colnames(EP_up_human)=colnames(Neu_up_human)=c("mouse","human")


###### output up-regulated genes

output_up_genes=F # change "F" to "T" if you want to output these files
if (output_up_genes){
	write.table(Neu_up_human,"up regulated genes in Neu KP (vs WT).xls",row.names=F,quote=F,sep="\t")
}



##########	check ligand&receptor information

Neu_Ligand=intersect(Neu_up_human[,2],Ligand)
EP_expressed_receptor=intersect(EP_expressed_human[,2],Receptor)



##########	find TF-targets information in KEGG 

KEGG_all_edge=read.delim("KEGG_edge_directed.txt")
KEGG_all_TF=KEGG_all_edge[KEGG_all_edge[,3]=="directed",]
KEGG_all_TF=KEGG_all_TF[KEGG_all_TF[,4]=="process(expression)",]


KEGG_TF_target=KEGG_all_TF[!duplicated(KEGG_all_TF[,1:2]),1:2]
KEGG_TF_target=as.matrix(KEGG_TF_target)


#########	read TF-targets information in TRED

TRED_TF_target=read.delim("TRED known TF targets files.xls")
TRED_TF_target=as.matrix(TRED_TF_target[,c(3,7)])


#########	combind TF-targets and merge with EP genes 

TF_all=rbind(KEGG_TF_target,TRED_TF_target)
TF_all=TF_all[!duplicated(TF_all),]

TF_EP=TF_all[TF_all[,1]%in%unique(EP_human[,2])&TF_all[,2]%in%unique(EP_human[,2],),]




########	find KEGG pathway information in graphite package

KEGG_entrez=lapply(kegg,function(x){return(nodes(x))})
KEGG_entrez=lapply(KEGG_entrez,substr,start=12,stop=100)

all_symbol=names(as.list(org.Hs.egSYMBOL[]))

KEGG_symbol=lapply(KEGG_entrez,function(x){x=intersect(x,all_symbol);unlist(as.list(org.Hs.egSYMBOL[x]))})

Find_KEGG_edge=function(x){
	x=as.matrix(x)
	x[,1]=substr(x[,1],12,100)
	x[,2]=substr(x[,2],12,100)
	temp1=x[x[,1]%in%all_symbol&x[,2]%in%all_symbol,]

	if(is.matrix(temp1)){
	temp1[,1]=unlist(as.list(org.Hs.egSYMBOL[temp1[,1]]))
	temp1[,2]=unlist(as.list(org.Hs.egSYMBOL[temp1[,2]]))
	}
	return(temp1)
}

KEGG_edge_symbol=list()
for (i in 1:length(kegg)){
	KEGG_edge_symbol[[i]]=Find_KEGG_edge(edges(kegg[[i]]))
	x=KEGG_edge_symbol[[i]]
	if (!is.matrix(x)){x=t(as.matrix(x))}
	y=x[x[,3]=="undirected",]
	if (!is.matrix(y)){y=t(as.matrix(y))}
	y=y[,c(2:1,3:4)]
	KEGG_edge_symbol[[i]]=rbind(KEGG_edge_symbol[[i]],y)
	KEGG_edge_symbol[[i]]=KEGG_edge_symbol[[i]][!duplicated(KEGG_edge_symbol[[i]]),]
}


names(KEGG_edge_symbol)=names(kegg)




######################################
#	add in newest KEGG pathway
######################################

ras=read.delim("Ras signaling pathway.txt",header=F)
tnf=read.delim("tnf signaling pathway.txt",header=F)
Rap1=read.delim("Rap1 signaling pathway.txt",header=F)
FoxO=read.delim("FoxO signaling pathway.txt",header=F)
cGMP=read.delim("cGMP signaling pathway.txt",header=F)
AMPK=read.delim("AMPK signaling pathway.txt",header=F)

add_path=c("ras","tnf","Rap1","FoxO","cGMP","AMPK")

for (i in 1:6){
	KEGG_edge_symbol[[220+i]]=as.matrix(get(add_path[i]))[,1:4]
	names(KEGG_edge_symbol)[220+i]=as.matrix(get(add_path[i]))[1,5]
	KEGG_symbol[[220+i]]=unique(as.vector(as.matrix(get(add_path[i]))[,1:2]))
	names(KEGG_symbol)[220+i]=as.matrix(get(add_path[i]))[1,5]
}






########	find KEGG Ligand-Receptor pairs(LR)

KEGG_LR_pair=list()
for (i in 1:length(KEGG_edge_symbol)){
	if (is.matrix(KEGG_edge_symbol[[i]])){
	KEGG_LR_pair[[i]]=merge(KEGG_edge_symbol[[i]][,1:2],LR_manual,by.x=1:2,by.y=1:2,sort=F)
	KEGG_LR_pair[[i]]=as.matrix(KEGG_LR_pair[[i]])
	KEGG_LR_pair[[i]]=KEGG_LR_pair[[i]][!duplicated(KEGG_LR_pair[[i]]),]
	}
}
names(KEGG_LR_pair)=names(KEGG_edge_symbol)



############ find Neu->EP LR 

Neu_EP_LR_select=list()
for (i in 1:length(KEGG_edge_symbol)){
	if (length(KEGG_LR_pair[[i]])>0){
		x=KEGG_LR_pair[[i]]
		if (!is.matrix(x)){x=t(as.matrix(x))}				
		Neu_EP_LR_select[[i]]=x[x[,1]%in%Neu_Ligand&x[,2]%in%EP_expressed_receptor,]	
	}
}
names(Neu_EP_LR_select)=names(KEGG_edge_symbol)

for (i in 1:length(KEGG_edge_symbol)){
if (is.character(Neu_EP_LR_select[[i]])){
	if (length(Neu_EP_LR_select[[i]])>0){
		if (is.matrix(Neu_EP_LR_select[[i]])){Neu_EP_LR_select[[i]]=Neu_EP_LR_select[[i]]}
		else Neu_EP_LR_select[[i]]=t(as.matrix(Neu_EP_LR_select[[i]]))
		}
	else Neu_EP_LR_select[[i]]=0
	}
else Neu_EP_LR_select[[i]]=0
}



##################################################
#	find enriched pathways in tumor
##################################################

fisher_test=function(gene_list,pathway,all_list)
	{
		a=length(intersect(gene_list,pathway))
		b=length(gene_list)-a
		c=length(pathway)-1
		d=length(all_list)-a-b-c
		matrix=matrix(c(a,c,b,d),nrow=2)
		fisher.test(matrix,alternative="greater")$p.value
	}

fisher_KEGG=lapply(KEGG_symbol,fisher_test,gene_list=as.matrix(EP_up_human[,2]),all_list=as.matrix(EP_human[,2]))
enrich_KEGG=fisher_KEGG[fisher_KEGG<0.05]
enrich_KEGG=unlist(enrich_KEGG)






######################################
###	read KEGG selected pathways
######################################

KEGG_selected_pathway=read.delim("KEGG_selected_pathway.txt")
KEGG_selected_pathway=as.matrix(KEGG_selected_pathway)


#########	enriched pathways in selected pathway

enrich_KEGG_select=enrich_KEGG[intersect(names(enrich_KEGG),KEGG_selected_pathway)]



#############	find activated transcription factors and their targets in EP

KEGG_TF=list()
for (i in 1:length(KEGG_edge_symbol)){
	KEGG_TF[[i]]=intersect(KEGG_symbol[[i]],TF_EP[,1])
}
names(KEGG_TF)=names(KEGG_edge_symbol)


TF_list=unique(TF_EP[,1])
TF_fisher=c()
for (i in 1:length(TF_list))
	{
		x=TF_EP[TF_EP[,1]==TF_list[i],2]
		TF_fisher[i]=fisher_test(gene_list=x,pathway=as.matrix(EP_up_human[,2]),all_list=as.matrix(EP_human[,2]))
	}
names(TF_fisher)=TF_list
TF_diff=TF_list[TF_fisher<0.05]
TF_diff=intersect(EP_expressed_human[,2],TF_diff)

KEGG_TF_select=list()
for (i in 1:length(KEGG_edge_symbol)){
	x=KEGG_TF[[i]]
	KEGG_TF_select[[i]]=intersect(KEGG_TF[[i]],TF_diff)
}
names(KEGG_TF_select)=names(KEGG_edge_symbol)


################################## find activated paracrine pathways

Neu_EP_select=names(KEGG_edge_symbol)[unlist(lapply(Neu_EP_LR_select,is.matrix))&unlist(lapply(KEGG_TF_select,function(x){length(x)>0}))]


#####################################################################
###	read heterodimer information from KEGG and manual revised 
#####################################################################

KEGG_binding=c("Cytokine-cytokine receptor interaction","ECM-receptor interaction","Neuroactive ligand-receptor interaction")
KEGG_binding=do.call(rbind,KEGG_edge_symbol[KEGG_binding])
KEGG_binding=KEGG_binding[KEGG_binding[,4]=="binding",]
KEGG_binding=rbind(KEGG_binding[,1:2],KEGG_binding[,2:1])

Manual_binding=read.delim("manual_binding.txt",header=F)
Manual_binding=as.matrix(Manual_binding)
Manual_binding=rbind(Manual_binding,Manual_binding[,2:1])

Receptor_binding=rbind(KEGG_binding,Manual_binding)
Receptor_binding=Receptor_binding[!duplicated(Receptor_binding),]



############	select candidate LR and TFs in Neu->EP

Neu_EP_select=intersect(Neu_EP_select,KEGG_selected_pathway[,1])
Neu_EP_pathway_select_LR_list=Neu_EP_LR_select[Neu_EP_select]
x=Neu_EP_pathway_select_LR_list
Neu_EP_heterodimer=list()
for (i in 1:length(x)){
	y=x[[i]]
	y=y[!duplicated(y),]
	if (!is.matrix(y)){y=t(as.matrix(y))}
	Neu_EP_heterodimer[[i]]=matrix(ncol=2)
	for (j in 1:nrow(y)){
		y1=y[j,1]
		y2=y[j,2]
		y3=unique(as.matrix(merge(y2,Receptor_binding,by.x=1,by.y=1,sort=F)[,2]))
		y4=merge(y3,LR_manual,by.x=1,by.y=2,sort=F)
		y4=as.matrix(y4[,2:1])
		y5=as.matrix(merge(y1,y4,by.x=1,by.y=1,sort=F))
		if (length(y5)>0){
			y6=cbind(y2,y5[,2])
			Neu_EP_heterodimer[[i]]=rbind(Neu_EP_heterodimer[[i]],y6)
		}
	}
}
Neu_EP_heterodimer=lapply(Neu_EP_heterodimer,function(x){x=x[-1,]})

Neu_EP_pathway_select_LR_list=x
names(Neu_EP_heterodimer)=names(x)
Neu_EP_pathway_select_TF_list=KEGG_TF_select[Neu_EP_select]



############	output activated LR and TFs in Neu->EP paracrine 
Neu_EP_output=F # change "F" to "T" to output files
if (Neu_EP_output){

	for (i in 1:length(Neu_EP_select)){
		write(paste("$",names(Neu_EP_pathway_select_LR_list)[i],sep=""),"Neu_EP_Pathway_LR.xls",append=T,ncolumns=1)
		write.table(Neu_EP_pathway_select_LR_list[[i]],"D11CB_EP_Pathway_LR.xls",append=T,sep="\t",row.names=F,col.names=c("Ligand","Receptor"),quote=F)
	}
	for (i in 1:length(Neu_EP_select)){
		write(paste("$",names(Neu_EP_pathway_select_TF_list)[i],sep=""),"Neu_EP_Pathway_TF.xls",append=T,ncolumns=1)
		write.table(Neu_EP_pathway_select_TF_list[[i]],"Neu_EP_Pathway_TF.xls",append=T,sep="\t",row.names=F,col.names=F,quote=F)
	}
}




####################################################
#	find activated pathway branch in Neu->EP
####################################################

x=Neu_EP_select
y=KEGG_edge_symbol[x]

pathway_branch=list()
for (i in 1:length(y)){
	yy=y[[i]][,1:2]
	b=Neu_EP_pathway_select_LR_list[[i]]
	yy2=Neu_EP_heterodimer[[i]]
	if (!is.matrix(yy2)){yy2=t(as.matrix(yy2))}

	yyy=yy[yy[,2]%in%Receptor&(!yy[,2]%in%b[,2])&(!yy[,2]%in%as.vector(yy2)),2]
	yy=yy[!(yy[,2]%in%yyy|yy[,1]%in%yyy),]
	yy=yy[!(yy[,1]%in%Ligand|yy[,2]%in%Ligand),]
	yy=rbind(yy,b)

	yy=rbind(yy,yy2)
	yy=rbind(yy,yy2[,2:1])
	yy=yy[!duplicated(yy),]
	yy=graph.edgelist(yy)
	a=shortest.paths(yy,mode="out")
	b1=unique(b[,2])
	d=Neu_EP_pathway_select_TF_list[[i]]
	g=a[b1,]
	if (!is.matrix(g)){
		g=t(as.matrix(g))
		rownames(g)=b1
	}
	g1=apply(g,1,function(x){colnames(a)[x<50]})
	g1=unique(as.vector(unlist(g1)))
	g2=a[g1,]
	if (!is.matrix(g2)){
		g2=t(as.matrix(g2))
		rownames(g2)=g1
	}	
	g3=apply(g2,1,function(x){y=x[match(d,colnames(a))];y=names(y)[y<10000]})
	g4=lapply(g3,length)
	g5=names(g4)[g4>0]
	pathway_branch[[i]]=g5
}
names(pathway_branch)=x[1:length(pathway_branch)]



#########################################
##	find sub-networks for each branch
#########################################

x=pathway_branch
y=lapply(x,is.null)
x=x[!unlist(y)]
LR_x=Neu_EP_pathway_select_LR_list[names(x)]


pathway_sub_net=list()
	for (i in 1:length(x)){
	y=KEGG_edge_symbol[names(x)[i]][[1]]


	yy2=Neu_EP_heterodimer[names(x)][[i]]
	if (!is.matrix(yy2)){yy2=t(as.matrix(yy2))}

	yy=y[y[,2]%in%Receptor&(!y[,2]%in%LR_x[[i]][,2])&(!y[,2]%in%as.vector(yy2)),2]
	yy=y[!(y[,2]%in%yy|y[,1]%in%yy),]
	yy=yy[!(yy[,1]%in%Ligand|yy[,2]%in%Ligand),]
	yy=yy[!(yy[,2]%in%Receptor),]
	yy=yy[!duplicated(yy),]	
	y=yy

	y1=y[y[,1]%in%x[[i]]&y[,2]%in%x[[i]],]
	y2=LR_x[i][[1]]
	y2=cbind(y2,"directed","LR")
	y3=Neu_EP_heterodimer[names(x)][[i]]
	if (!is.matrix(y3)){y3=t(as.matrix(y3))}
	y3=cbind(y3,"directed","heterodimer")
	colnames(y2)=c("From","To","Direction","Interaction_type")
	pathway_sub_net[[i]]=rbind(y2,y3,y1)
}
names(pathway_sub_net)=names(x)



pathway_sub_node=list()
x=names(pathway_sub_net)
x1=Neu_EP_pathway_select_LR_list[x]
x2=Neu_EP_pathway_select_TF_list[x]
for (i in 1:length(x)){
	y=pathway_sub_net[[i]]
	y=unique(as.vector(y[,1:2]))
	y=cbind(y,"links")
	y[y[,1]%in%x2[[i]],2]="TF"
	y[y[,1]%in%x1[[i]][,2],2]="Receptor"
	y[y[,1]%in%x1[[i]][,1],2]="Ligand"
	colnames(y)=c("gene","gene_type")
	pathway_sub_node[[i]]=y
}

names(pathway_sub_node)=names(pathway_sub_net)


output_branch=F

if (output_branch){
	for (i in 1:length(pathway_sub_net)){
		write.table(pathway_sub_net[[i]],paste("Neu_EP_new_",x[i],"_branch.txt",sep=""),row.names=F,quote=F,sep="\t")
		write.table(pathway_sub_node[[i]],paste("Neu_EP_new_",x[i],"_nodes.txt",sep=""),row.names=F,quote=F,sep="\t")
	}
}


###################################################################
#	simplify network by connecting receptors to TFs directly
###################################################################

y=pathway_sub_net
pathway_branch_simplify=list()
for (i in 1:length(y)){
	yy=y[[i]]
	heter=yy[yy[,4]=="heterodimer",]
	if (!is.matrix(heter)){heter=t(as.matrix(heter))}
	a=yy[yy[,4]=="LR",]
	if (is.matrix(a)){b=unique(a[,2]);heter=heter[heter[,1]%in%a[,2]&heter[,2]%in%a[,2],]}
	else {b=a[2];heter=heter[heter[,1]%in%a[2]&heter[,2]%in%a[2],]}
	y2=graph.edgelist(yy[,1:2])
	d=shortest.paths(y2,mode="out")
	e=unlist(Neu_EP_pathway_select_TF_list[names(y)[i]])
	f=intersect(colnames(d),e)
	g=merge(TF_EP,f,by.x=1,by.y=1,sort=F)
	g=g[g[,2]%in%EP_up_human[,2],]

	g=cbind(g,"directed","TF_targets")
	g=as.matrix(g)
	for (j in 1:length(b)){
		for (k in 1:length(f)){
			if (d[b[j],f[k]]<1000){a=rbind(a,c(b[j],f[k],"directed","R_TF"))}
		}
	}
	a=cbind(a,a[,2])
	heter=cbind(heter,heter[,2])
	g=cbind(g,paste("EP_",g[,2],sep=""))
	pathway_branch_simplify[[i]]=rbind(a,g,heter)
	colnames(pathway_branch_simplify[[i]])[5]="node_name"
}
names(pathway_branch_simplify)=names(y)


pathway_branch_simplify_R=list()
for (i in 1:length(pathway_branch_simplify)){
	a=names(pathway_branch_simplify)[i]
	a=strsplit(a," signaling pathway")
	a=unlist(a)
	pathway_branch_simplify_R[[i]]=cbind(pathway_branch_simplify[[i]],a)
}
pathway_branch_simplify_R=do.call(rbind,pathway_branch_simplify_R)
colnames(pathway_branch_simplify_R)[6]="Signaling_name"



#################################################
#		fisher test for each branch
#################################################

x=pathway_branch
y=lapply(x,is.null)
x=x[!unlist(y)]
TF_x=Neu_EP_pathway_select_TF_list[names(x)]
TF_x=unique(unlist(TF_x))

fisher_test=function(gene_list,pathway,all_list)
	{
		a=length(intersect(gene_list,pathway))
		b=length(gene_list)-a
		c=length(pathway)-1
		d=length(all_list)-a-b-c
		matrix=matrix(c(a,c,b,d),nrow=2)
		fisher.test(matrix,alternative="greater")$p.value
	}
Pathway_fisher=c()
for (i in 1:length(x))
	{
		Pathway_fisher[i]=fisher_test(gene_list=x[[i]],pathway=unique(c(as.matrix(EP_up_human[,2]),TF_x)),all_list=as.matrix(EP_human[,2]))
	}
names(Pathway_fisher)=names(x)
Pathway_fisher=as.matrix(Pathway_fisher)
Pathway_fisher=Pathway_fisher[order(Pathway_fisher[,1]),]
#write.table(as.matrix(Pathway_fisher),"p value for Neu_EP pathway branches.xls",col.names="p value",quote=F,sep="\t")




#############################
# remove pathway with p<0.05
#############################

test1=pathway_branch_simplify_R
filter_test=names(Pathway_fisher)[Pathway_fisher>0.05]
filter_test=strsplit(filter_test," signaling")
filter_test=lapply(filter_test,function(x){x=x[1]})
filter_test=unlist(filter_test)
test2=test1[!test1[,6]%in%filter_test,]
pathway_branch_simplify_R2=test2



###########################
#	node attributes
###########################

a=pathway_branch_simplify_R2

tar=grep("EP_",a[,5])
t1=a[tar,]
t2=a[-tar,]


b1=t2[t2[,4]=="LR",1]#ligand
b1=cbind(unique(b1),"Ligand")
b2=t2[t2[,4]=="LR",2]#receptor
b2=cbind(unique(b2),"Receptor")
c1=t1[,1]#TF
c1=cbind(unique(c1),"TF")
c2=t1[,5]#TF targets
c2=cbind(unique(c2),"targets")
pathway_attributes=rbind(c2,c1,b2,b1)
x=strsplit(pathway_attributes[,1],"EP_")
for (i in 1:length(x)){if (length(x[[i]])>1){x[[i]]=x[[i]][2]}}
x=unlist(x)
pathway_attributes=cbind(pathway_attributes,x)
x=which(pathway_attributes[1:nrow(c2),3]%in%pathway_attributes[(nrow(c2)+1):(nrow(c2)+nrow(c1)),3])
pathway_attributes[x,2]="TF"
y=which(pathway_branch_simplify_R2[,5]%in%c2[x,1])
pathway_branch_simplify_R2[y,5]=substr(pathway_branch_simplify_R2[y,5],4,100)

colnames(pathway_attributes)=c("nodes","attributes","Gene_name")




write.simplify=T
if (write.simplify){
	write.table(pathway_branch_simplify_R2,"Neu_EP_simplified_network.txt",row.names=F,quote=F,sep="\t")
	write.table(pathway_attributes,"Neu_EP_simplified_network_node_attributes.txt",row.names=F,quote=F,sep="\t")	
}







###############################################
#	list all up-regulated TF targets
###############################################

x=Neu_EP_pathway_select_TF_list

x=do.call(c,x)
x=unique(x)
y=merge(TF_EP,x,by.x=1,by.y=1,sort=F)
y=y[y[,2]%in%EP_up_human[,2],]
colnames(y)=c("TF","Targtes")

#write.table(y,"activated TF and targets information in Neu_EP communications.txt",row.names=F,quote=F,sep="\t")


########################################
#		combine pathway branches
########################################

x=do.call(rbind,pathway_sub_net)
x=x[!duplicated(x[,1:2]),]
m=do.call(rbind,Neu_EP_pathway_select_LR_list)
n=do.call(c,Neu_EP_pathway_select_TF_list)
y=do.call(rbind,pathway_sub_node)
y=y[!duplicated(y[,1]),]
y[y[,1]%in%n,2]="TF"
y[y[,1]%in%m[,2],2]="Receptor"
y[y[,1]%in%m[,1],2]="Ligand"

#write.table(x,"Neu_EP_new_all_pathway_branch_combined.txt",row.names=F,quote=F,sep="\t")
#write.table(y,"Neu_EP_new_all_pathway_branch_node_attributes.txt",row.names=F,quote=F,sep="\t")

##############################################################################################################################################









