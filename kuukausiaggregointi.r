#!usr/bin/env Rscript
####################
### Author: Tommi Salenius
### Email: tommi.salenius@bof.fi
### Created: Ke 23 05 18
### License: General Public License (2018)
###################

# Tämän skriptin tarkoituksena on tehdä helpoksi päivädatan saattaminen kuukausidatamuotoon.
# Skripti laskee aikasarjalle kuukausittaisen keskiarvon, varianssin ja mahdollisesti myös vinouden.

#### Lue csv-tiedosto ####

aggregoi <- function(file){

		df1 <- read.csv(file,sep=",")

		#df1 <- df1[,c("date", colnames(df1)[colnames(df1) != "date"])] # Vaihda date-muuttuja ensimmäiseksi sarakkeeksi
		
		df1$month <- strftime(df1$date, format="%m")
		df1$year <- strftime(df1$date, format="%Y")
		print(head(df1))
		
		keskiarvo <- aggregate(x=list(value=df1$value), by=list(year=df1$year, month=df1$month, ticker=df1$ticker, field=df1$field), FUN=mean,na.rm=TRUE)
		
		stdpoikkeama <- aggregate(x=list(value=df1$value), by=list(year=df1$year, month=df1$month, ticker=df1$ticker, field=df1$field), FUN=sd,na.rm=TRUE)
		
		# Yhdistä month ja year yhdeksi
		keskiarvo <- tidyr::unite(keskiarvo, date, c(year, month), remove=TRUE, sep="-")
		stdpoikkeama <- tidyr::unite(stdpoikkeama, date, c(year, month), remove=TRUE, sep="-")
		
		# Muuta uudet date-sarakkeet varsinaisiksi pvm-objekteiksi
		keskiarvo$date <- as.Date(paste0(keskiarvo$date, "-", "01"))
		stdpoikkeama$date <- as.Date(paste0(stdpoikkeama$date, "-", "01"))

		return(list(mean=keskiarvo,stdev=stdpoikkeama))

}

aggregoi("Testaus/data_cds.csv")
