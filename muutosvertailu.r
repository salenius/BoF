##################
### Pvm-seuranta
### Author: Tommi Salenius
### Email: tommi.salenius@bof.fi
### License: MIT (2018)
##################

# Tämän tiedoston tarkoituksena on, että markkinaseurantaa varten voidaan katsoa lukuja

muutos <- function(x){

  pvm <- format(Sys.Date(), "%Y-%m")
  pvm <- as.Date(paste0(pvm,"-","01"))
  
  month1 <- seq(pvm,length=2,by="-1 month")
  month3 <- seq(pvm,length=2,by="-3 months")
  month12 <- seq(pvm,length=2,by="-12 months")
  month24 <- seq(pvm,length=2,by="-24 months")
  
  seuranta <- c(pvm, month1[2], month3[2], month12[2], month24[2])
  if(x == 0){return(seuranta[1])}
  else if(x == 1){return(seuranta[2])}
  else if(x == 3){return(seuranta[3])}
  else if(x == 12){return(seuranta[4])}
  else if(x == 24){return(seuranta[5])}
  else {stop("Mahdollisuus katsoa vain 0, 1, 3, 12 tai 24kk takaperin")}
  
}
