#!usr/bin/env Rscript
####################
### Author: Tommi Salenius
### Email: tommisalenius@gmail.com
### Created: Ma 21 05 18
### License: General Public License (2018)
###################

# I use this file to calculate the standard deviation for several time series

std <- function(vec){
  output = sqrt(var(vec,na.rm=TRUE))
  return(output)
}

xlsxload <- function(file){
  df = xlsx::read.xlsx(file,sheetName="Taul1")
  df = subset(df,!is.na(df[,1]))
}

# Lataa tiedostot
# setwd("C:\\Users\\saleniusto\\Desktop\\Kehitystyö\\Financial indicators")
# OMX Helsinki
omx <- xlsxload("omxhelsinki.xlsx")

# Laske OMX Helsingin yleisindeksin std.dev 2013-2017
print(std(omx[,2]))
# 1055.507

# Euribor 12kk
eur12 <- xlsxload("euribor12.xlsx")

# 12kk euriborin std.dev 2013-2017
print(std(eur12[,2]))
# 0.2801994

# Euribor 3kk
eur3 <- xlsxload("euribor3.xlsx")
      
# Euribor 1kk
eur1 <- xlsxload("euribor1.xlsx")

# Laske standardipoikkeamat näille
print(std(eur3[,2]))
# 0.2396108
print(std(eur1[,2]))
# 0.228293

# Valtion 10v lainojen tuotto
dpv10 <- xlsxload("valtion10v.xlsx")
print(std(dpv10[,2]))
# 0.6251164

intspr <- xlsx::read.xlsx("saksanordic10ybondyield.xlsx",sheetName="Taul1")

bond10y <- merge(dpv10,intspr,by.x=1,by.y=1)
colnames(bond10y) = c("date","FI","DE","SE","DK","NO","IS")

################################################
# lasketaan kuukausittaiset keskiarvot ja standardipoikkeamat

spread <- as.matrix(bond10y[,3:7])

# Laske spreadit suht. Suomen korkoon

for(i in 1:nrow(spread)) {
  
  for(j in 1:5) {
    
    spread[i,j] = bond10y[i,2] - spread[i,j]
    
  }
  
}

# Vaihda muiden maiden absoluuttiset korot Suomen vastaavaan

bond10y[,3:7] <- spread

#################################
library(dplyr)

bond10y$month <- strftime(bond10y$date,format="%m")
bond10y$year <- strftime(bond10y$date,format="%y")

bond10mean <- aggregate(x=bond10y[,2:7],by=bond10y[,8:9],FUN=mean,na.rm=T)
bond10std <- aggregate(x=bond10y[,2:7],by=bond10y[,8:9],FUN=std)

bond10mean$year <- paste("20",bond10mean$year,sep="")
bond10std$year <- paste("20",bond10std$year,sep="")

bond10mean$date <- paste("01",bond10mean$month,bond10mean$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")
bond10std$date <- paste("01",bond10std$month,bond10std$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")

xlsx::write.xlsx(bond10mean[,3:ncol(bond10mean)],"valtionlainat_kkmean.xlsx",sheetName="Kk keskiarvot",row.names = FALSE)
xlsx::write.xlsx(bond10std[,3:ncol(bond10std)],"valtionlainat_kkstdev.xlsx",sheetName="Kk keskipoikkeamat",row.names = FALSE)

#### Euriborit ja OMX ####

eur1$month <- strftime(eur1$date,format="%m")
eur1$year <- strftime(eur1$date,format="%y")

eur1mean <- aggregate(x=eur1[,2],by=eur1[,3:4],FUN=mean,na.rm=T)
eur1std <- aggregate(x=eur1[,2],by=eur1[,3:4],FUN=std)

eur1mean$year <- paste("20",eur1mean$year,sep="")
eur1std$year <- paste("20",eur1std$year,sep="")

eur1mean$date <- paste("01",eur1mean$month,eur1mean$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")
eur1std$date <- paste("01",eur1std$month,eur1std$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")

xlsx::write.xlsx(eur1mean[,3:ncol(eur1mean)],"euribor1_kkmean.xlsx",sheetName="Kk keskiarvot",row.names = FALSE)
xlsx::write.xlsx(eur1std[,3:ncol(eur1std)],"euribor1_kkstdev.xlsx",sheetName="Kk keskipoikkeamat",row.names = FALSE)

### Eur3 ####

eur3$month <- strftime(eur3$date,format="%m")
eur3$year <- strftime(eur3$date,format="%y")

eur3mean <- aggregate(x=eur3[,2],by=eur3[,3:4],FUN=mean,na.rm=T)
eur3std <- aggregate(x=eur3[,2],by=eur3[,3:4],FUN=std)

eur3mean$year <- paste("20",eur3mean$year,sep="")
eur3std$year <- paste("20",eur3std$year,sep="")

eur3mean$date <- paste("01",eur3mean$month,eur3mean$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")
eur3std$date <- paste("01",eur3std$month,eur3std$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")

xlsx::write.xlsx(eur3mean[,3:ncol(eur3mean)],"euribor3_kkmean.xlsx",sheetName="Kk keskiarvot",row.names = FALSE)
xlsx::write.xlsx(eur3std[,3:ncol(eur3std)],"euribor3_kkstdev.xlsx",sheetName="Kk keskipoikkeamat",row.names = FALSE)

# Eur12 ##
eur12$month <- strftime(eur12$date,format="%m")
eur12$year <- strftime(eur12$date,format="%y")

eur12mean <- aggregate(x=eur12[,2],by=eur12[,3:4],FUN=mean,na.rm=T)
eur12std <- aggregate(x=eur12[,2],by=eur12[,3:4],FUN=std)

eur12mean$year <- paste("20",eur12mean$year,sep="")
eur12std$year <- paste("20",eur12std$year,sep="")

eur12mean$date <- paste("01",eur12mean$month,eur12mean$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")
eur12std$date <- paste("01",eur12std$month,eur12std$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")

xlsx::write.xlsx(eur12mean[,3:ncol(eur12mean)],"euribor12_kkmean.xlsx",sheetName="Kk keskiarvot",row.names = FALSE)
xlsx::write.xlsx(eur12std[,3:ncol(eur12std)],"euribor12_kkstdev.xlsx",sheetName="Kk keskipoikkeamat",row.names = FALSE)

# OMX Helsinki #
omx$month <- strftime(omx$date,format="%m")
omx$year <- strftime(omx$date,format="%y")

omxmean <- aggregate(x=omx[,2],by=omx[,3:4],FUN=mean,na.rm=T)
omxstd <- aggregate(x=omx[,2],by=omx[,3:4],FUN=std)

omxmean$year <- paste("20",omxmean$year,sep="")
omxstd$year <- paste("20",omxstd$year,sep="")

omxmean$date <- paste("01",omxmean$month,omxmean$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")
omxstd$date <- paste("01",omxstd$month,omxstd$year,sep="-") %>% as.Date(.,format="%d-%m-%Y")

xlsx::write.xlsx(omxmean[,3:ncol(omxmean)],"omxhelsinki_kkmean.xlsx",sheetName="Kk keskiarvot",row.names = FALSE)
xlsx::write.xlsx(omxstd[,3:ncol(omxstd)],"omxhelsinki_kkstdev.xlsx",sheetName="Kk keskipoikkeamat",row.names = FALSE)


