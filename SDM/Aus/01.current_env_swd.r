###################################################################################################
### Script to setup current files for MAXENT run trials

library(SDMTools) #define the libraries needed

### set up input data
hydro=read.csv("/home/jc246980/Hydrology.trials/Accumulated_reach/Output_futures/Qrun_accumulated2reach_1976to2005/Current_dynamic.csv") # read in accumulated flow
load("/home/jc246980/Hydrology.trials/Aggregate_reach/Output_futures/Qrun_aggregated2reach_1976to2005/Current_dynamic.Rdata") # read in runoff
bioclim=read.csv("/home/jc246980/Climate/5km/Future/Bioclim_reach/Current_bioclim_agg2reach_1976to2005.csv") # read in bioclim variables
dryseason.dir="/home/jc246980/DrySeason/DrySeason_reach/"
VOIS=c("num.month", "total.severity", "max.clust.length","clust.severity", "month.max.clust")

### Create annual means and fill in accumulated flow gaps

hydro$MeanAnnual=rowSums(hydro[,2:13])
Runoff$MeanAnnual=rowSums(Runoff[,2:13])
hydro_extra=Runoff[which(!(Runoff$SegmentNo %in% hydro$SegmentNo)),]   
HYDRO=hydro[,c(1,14)]
HYDRO_EXTRA=hydro_extra[, c(1,14)]
HYDROLOGY=rbind(HYDRO,HYDRO_EXTRA)

### Create current environmental data file

	for(voi in VOIS) { cat(voi,'\n') 	
			
		tdata=read.csv(paste(dryseason.dir,"Current_",voi,".csv", sep='')) 			# load data for each varable
		
		if (voi==VOIS[1]) Enviro_dat=tdata else Enviro_dat=cbind(Enviro_dat,tdata[,2])

	}

Enviro_dat=merge(bioclim,Enviro_dat, by='SegmentNo',all.x=TRUE)	

Enviro_dat=merge(Enviro_dat, HYDROLOGY, by="SegmentNo", all.x=TRUE)

### Create a fake lat/lon from SegmentNo - maxent demands lat/lon
	Enviro_dat=cbind(Enviro_dat[,1],Enviro_dat)

### LABEL the future env layers with the exact same column names as current layers.  IMPORTANT!
	tt=c('lat','long',paste('bioclim_',sprintf('%02i',c(1:19)),sep=""),"num.month", "total.severity", "max.clust.length","clust.severity", "month.max.clust", 'MeanAnnual')
	
	colnames(Enviro_dat)=tt

out.dir ="/home/jc148322/NARPfreshwater/SDM/Env_layers/"
write.csv(Enviro_dat,paste(out.dir,"current.csv",sep=''),row.names=F)

# also save it as Rdata
setwd(out.dir)
current=Enviro_dat
save(current,file='current.Rdata')
