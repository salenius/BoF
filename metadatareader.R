#!usr/bin/env Rscript
####################
### Author: Tommi Salenius
### Email: tommi.salenius@bof.fi
### Created: Pe 18 05 18
### License: General Public License (2018)
###################

#' Tämän funktion tarkoitus on ladata metadata.xlsx-tiedostosta tarvittavat parametrit ja rakentaa
#' niiden pohjalta kuva.
#'
#' Vaadittava paketti on xlsx
#' 

lue.metadata <- function(sheet) {

  df1 <- xlsx::read.xlsx("metadata.xlsx",sheetName=sheet) 

  for(i in df1$Chart){
    if(!(i %in% c("line","bar","area","yield"))){
      stop(paste("Tunnistamaton parametri tiedostossa metadata.xlsx välilehdellä ", sheet, ". Tarkista
                 että kaikki Chart-sarakkeen muuttujat ovat joukossa 'line', 'bar', 'area' tai 'yield'.", sep=""))
    }
  }
  
  #rownames(df1) = apply(df1, 1, function(x) paste0(x[1], " ", x[2]))
  
  df1$Ticker <- as.character(df1$Ticker)
  df1$Field <- as.character(df1$Field)
  
  # Jos yield-parametria on käytetty Chart-sarakkeessa, lisää taulukkoon uusi sarake, jossa
  # on kyseistä parametria käyttävän assetin maturiteetti. Oikean maturiteetin asettaa yieldcurve.r
  
  if("yield" %in% levels(df1$Chart)){
    df1$Maturity <- numeric(nrow(df1))
    source("Funktiot/yieldcurve.r")
    for(i in 1:nrow(df1)){
      
      if(df1$Chart[i] == "yield"){ df1$Maturity[i] = maturitycheck(i,df1) }
      
      
    }
  }
  
  return(df1)

}

metad <- lue.metadata("Sheet1")
metad


