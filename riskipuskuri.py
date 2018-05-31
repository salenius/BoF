# -*- coding: utf-8 -*-
#!usr/bin/env python
###########################################
#### File: Järjestelmäriskipuskuritilastojen automatisointi 
#### Author: Tommi Salenius
#### Created: Ti, 29.5.2018
#### License: General Public License (2018)
###########################################

# Tämän tiedoston tarkoituksena on automatisoida tunnuslukujen laskeminen annetuista
# aikasarjoista ilman, että tarvittaisiin Patua ollenkaan. Vlookupeista pyritään
# pääsemään kokonaan eroon.

import time

start = time.time() # Aloita ajanotto

import pandas as pd

import re

chfile = "riskipuskuri.xlsx"
exfile = pd.ExcelFile(chfile)
# Kansio, johon kaikki kuvia varten tuotettavat datat tallennetaan 
writer = pd.ExcelWriter("kuvat.xlsx")

### Määritellään funktio, joka voi hakea suoraan tästä tiedostosta halutun sheetin

def exread(sheet,cols=None):
    """
    Hae exfile-muuttujan nimisestä Excel-tiedostosta haluttu välilehti. Koska aikasarjat on
    haettu suoraan Sarkasta, funktion täytyy tiputtaa 9 ensimmäistä riviä pois.
    """
    df = exfile.parse(sheet,usecols=cols,skiprows=[i for i in range(9)])
    return df

# Hae rivi pvm:n perusteella

def haepvm(df, p, kk, v):
    """
    Hae dataframesta rivi annetun päivämäärän perusteella, joka on date-sarakkeessa
    """
    pvm = str(p) + "." + str(kk) + "." + str(v)
    try:
        result = df.loc[df["date"] == pvm]
    except KeyError:
        result = df.loc[df["Date"] == pvm]
    finally:
        return result

def haequart(df, q, v):
    """
    Muuten kuten haepvm, mutta erikoistunut hakemaan kvartaaleja date-sarakkeesta
    """
    if q == 1:
        haepvm(df, 31, 3, v)
    elif q == 2:
        haepvm(df, 30, 6, v)
    elif q == 3:
        haepvm(df, 30, 9, v)
    elif q == 4:
        haepvm(df, 31, 12, v)
    else:
        raise ValueError

# Tähän tulee nämä
dic1 = dict(Austria = "AT",
            Belgium = "BE",
            Bulgaria = "BG",
            Czech = "CZ",
            Cyprus = "CY",
            Germany = "DE",
            Denmark = "DK",
            Estonia = "EE",
            Spain = "ES",
            Finland = "FI",
            France = "FR",
            Kingdom = "GB",
            Greece = "GR",
            Croatia = "HR",
            Hungary = "HU",
            Ireland = "IR",
            Italy = "IT",
            Lithuania = "LT",
            Latvia = "LV",
            Luxembourg = "LU",
            Malta = "MT",
            Netherlands = "NL",
            Poland = "PL",
            Portugal = "PT",
            Romania = "RO",
            Sweden = "SE",
            Slovenia = "SI",
            Slovakia = "SK",
            EU = "EU"
)
 

    
def maalyh(x):
    """
    Tämä käy läpi muuttujia/sarakkeiden nimiä ja muuttaa ne maalyhennemuotoon, jos niissä esiintyy tietty regex
    """
    result = x
    for key, val in dic1.items():
        if key in x:
            result = val
            break
        else:
            pass

    return result 


def sortandsave(p, kk, v, sheet, cols=None):
    """
    Käytä tätä funktiota tallentamaan poikkileikkauskuvaajat järjestelmäriskipuskurista
    annettuna päivämääränä ja järjestämään havainnot suuruusjärjestykseen suurimmasta pienimpään.
    Ideana on kirjoittaa päivämäärä ensin erilaisina argumentteina,
    sitten valitaan välilehti (sheet) mistä data haetaan, ja cols-argumentti määrää
    mitkä sarakkeet otetaan ylipäätään mukaan analyysiin.
    """
    ch1 = exread(sheet, cols)
    df1 = haepvm(ch1, p, kk, v)

    # Koska taulukko transponoidaan, indeksistä tulee uusi sarakkeen nimi, joten se pitää vaihtaa
    # johonkin standardisoidumpaan, jotta koodi ei hajoa. Vaihdetaan indeksi "value" nimelle
    # seuraavan kautta:
    
    df1.reset_index(inplace=True)
    df1 = df1.assign(value="value") # Jos olisi vain laittanut df1 ["value"], niin ohjelma sylkisi SettingWithCopyWarningia; tämä tapa pitää sen hiljaa
    df1.drop("index", axis=1, inplace=True)
    df1.set_index("value",inplace=True)
    
    # Business as usual tästä eteenpäin
    
    df1 = df1.transpose()
    df1["maa"] = df1.index

    for i in range(len(df1.index)):
        df1["maa"][i]  = maalyh(df1["maa"][i])
    
    # Nyt päästään viimein järjestämään maat oikeaan järjestykseen valuen perusteella
    df1.index = [i for i in range(len(df1["value"]))]
    df1 = df1[1:] 
    df1 = df1.sort_values(by="value",ascending=False)
    print(df1.head())
    
    # Tallenna tulokset Excel-tiedostoon
    df1.to_excel(writer, sheet_name=str(sheet+"a"), na_rep="#N/A", index=False)
    writer.save()
    print(sheet + "a tallennettu") 
    
def finmedian(sheet):
    """
    Piirrä annetusta välilehdestä aikasarja Suomen ja Euroopan mediaaniarvojen kehityksessä
    havaintojen keräämisen alusta alkaen.
    """
    ch1 = exread(sheet)
    df1b = ch1.filter(regex='(^date$|^Date$|^FI$|Finland|media.{1,4}|Media.{1,4})') # Etsi sarakkeet regular expressioneiden perusteella
    df1b = df1b.rename(columns=lambda x: re.sub(r'(Finland.{1,250}|FI)', 'Suomi',x))
    df1b = df1b.rename(columns=lambda x: re.sub(r'(mediaani|Painottamaton.{1,70}|painottamaton.{1,70})', '- painottamaton mediaani',x))

    print(df1b.head())

    df1b.to_excel(writer, sheet_name=str(sheet+"b"), na_rep="#N/A", index=False)
    writer.save()
    print(sheet +"b tallennettu") 


#######################
## Kuvio 1a
#######################

sortandsave(31,3,2018,"Chart1","B,D:AF")

#######################
## Kuvio 1b
#######################

finmedian("Chart1")

#######################
## Kuvio 3a
#######################

sortandsave(31,3,2018,"Chart3","A,DK:EL,FO")

#######################
## Kuvio 3b
#######################

finmedian("Chart3")

#######################
## Kuvio 4a
#######################

sortandsave(31,12,2016,"Chart4","A,C:AD,AM")

#######################
## Kuvio 4b
#######################

<<<<<<< HEAD
finmedian("Chart4")
=======
# Nyt päästään viimein järjestämään maat oikeaan järjestykseen valuen perusteella
df1.index = [i for i in range(len(df1["value"]))]
df1 = df1[3:] 
df1 = df1.sort_values(by="value",ascending=False)

# Tallenna tulokset
writer = pd.ExcelWriter("kuvat.xlsx")
df1.to_excel(writer, sheet_name="Chart1a", na_rep="#N/A", index=False, )
writer.save()
>>>>>>> c0db68b2217cb19acbcd1b4f838c03b9f27da4c6

#######################
## Kuvio 6a
#######################



#######################
## Kuvio 6b
#######################

finmedian("Chart6")

#######################
## Kuvio 7a
#######################

#######################
## Kuvio 7b
#######################



end = time.time()

ero = end - start

print("Aikaa kului " + str(ero) + " sekuntia")

