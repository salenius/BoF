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
# 0.2307024

# Valtion 10v lainojen tuotto
dpv10 <- xlsxload("valtion10v.xlsx")
print(std(dpv10[,2]))
# 0.606155
