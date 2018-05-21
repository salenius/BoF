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

# Lataa tiedosto
# setwd("C:\\Users\\saleniusto\\Desktop\\Kehitystyö\\Financial indicators")
omx <- xlsx::read.xlsx("omxhelsinki.xlsx",sheetName="Taul1")
