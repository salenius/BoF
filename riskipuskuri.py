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

import pandas as pd


chfile = "riskipuskuri.xlsx"
exfile = pd.ExcelFile(chfile)

### Määritellään funktio, joka voi hakea suoraan tästä tiedostosta halutun sheetin

def exread(sheet):
    """
    Hae exfile-muuttujan nimisestä Excel-tiedostosta haluttu välilehti. Koska aikasarjat on
    haettu suoraan Sarkasta, funktion täytyy tiputtaa 9 ensimmäistä riviä pois.
    """
    df = exfile.parse(sheet,skiprows=[i for i in range(9)])
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
    result = x
    for key, val in dic1.items():
        if key in x:
            result = val
            break
        else:
            pass

    return result 


#######################
## Kuvio 1a
#######################

ch1 = exread("Chart1")
df1 = haepvm(ch1, 31, 3, 2018)

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
df1 = df1[3:] 
df1 = df1.sort_values(by="value",ascending=False)
print(df1)

#######################
## Kuvio 1b
#######################






