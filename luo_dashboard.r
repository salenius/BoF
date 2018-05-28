####################################
###### Dashboardin kokoamisskripti
###### Tekijä/Author: Tommi Salenius
###### Lisenssi: MIT (2018)
####################################

# Ajamalla tämän skriptin läpi kokonaisuudessaan, käyttäjä voi piirtää haluamiaan kuvioita
# toiveensa mukaan.

source("Funktiot/csvreading.r")
source("Funktiot/bof_plot.r")

##################
# Määrittele csv-tiedosto, josta data haetaan

filename = "Testaus/data_cds.csv"
metadatasheet = "Sheet1"

########################

source("Funktiot/metadatareader.r")

########################

dataframe <- luecsv(filename)

dataframe <- filtering(dataframe, metad)



#################
# Määrittele halutut filtteröinnit aineistolle.
#'
#' BOF_plot toimii seuraavalla parametrisoinnilla:
#' dataframe = määritä taulukko, johon kuuluvasta datasta kuvaaja rakennetaan
#' xwhich = x-akselin muuttuja (aikasarjoissa ts. date)
#' ywhich = y-akselin muuttuja
#' zwhich = y-akselin muuttujan nimi, joka tulee kuvaajan legendiin
#' plottype = jokin joukosta line, bar1, bar2 tai area (katso Funktiot/bof_plot.r tarkemman tiedon varalta)
#' title = Kuvan otsikko, oletuksena jätetään tyhjäksi
#' save = TRUE tai FALSE, jos TRUE niin kuvaaja tallennetaan sekä png- ja svg-tiedostoina työkansioon, muussa tapauksessa ei

# 
# 
# df2 <- dataframe %>% filter(.,ticker %in% "SNRFIN CDSI GEN 5Y CORP")
# BOF_plot(dataframe = df2,
#          xwhich = date,
#          ywhich = value,
#          zwich = "SNRFIN CDSI GEN 5Y CORP",
#          plottype = "bar2",
#          title = "5 vuoden bondit",
#          save = TRUE)



################
# Kuvat tallentuvat, plotit luonnistuvat ja tiedostot latautuvat kuten pitää.
# Ainoa mikä puuttuu on dashboardin luominen
