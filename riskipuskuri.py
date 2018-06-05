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


def sortandsave(p, kk, v, sheet, cols=None, save_sheet=None):
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
    
    # Tallenna tulokset Excel-tiedostoon
    if save_sheet == None:
        sheet1 = sheet
    else:
        sheet1 = save_sheet
    df1.to_excel(writer, sheet_name=str(sheet1+"a"), na_rep="#N/A", index=False)
    print(sheet1 + "a tallennettu") 
    
def finmedian(sheet):
    """
    Piirrä annetusta välilehdestä aikasarja Suomen ja Euroopan mediaaniarvojen kehityksessä
    havaintojen keräämisen alusta alkaen.
    """
    ch1 = exread(sheet)
    df1b = ch1.filter(regex='(^date$|^Date$|^FI$|Finland|media.{1,4}|Media.{1,4})') # Etsi sarakkeet regular expressioneiden perusteella
    df1b = df1b.rename(columns=lambda x: re.sub(r'(Finland.{1,250}|FI)', 'Suomi',x))
    df1b = df1b.rename(columns=lambda x: re.sub(r'(mediaani|Painottamaton.{1,70}|painottamaton.{1,70}|painotettu.{1,70})', '- painottamaton mediaani',x))

    df1b.to_excel(writer, sheet_name=str(sheet+"b"), na_rep="#N/A", index=False)
    print(sheet +"b tallennettu")

# Kuvio 5:n piirtämiseen

def chart5(p, kk, v, lyh):
    """
    Käytä tätä funktiota Chart5:n piirtämiseen. Ideana on, että käyttäjä on ensin ladannut välilehdet Chart5, Chart5m, ja Chart5m2, joista piirretään lopullinen yhdistelmätaulu.
    """
    db5 = haepvm(ch5q, p, kk, v)
    db5m = haepvm(ch5m, p, kk, v)
    db5m2 = haepvm(ch5m2, p, kk, v)
    
    # Jokaista 3 taulukkoa pitää filtteröidä eri tavalla
    db5 = db5.filter(like=lyh, axis=1) 
    db5m = db5m.filter(like=dic1[lyh])
    db5m2 = db5m2.filter(like=dic1[lyh])
    
    for i in [db5, db5m, db5m2]:
        i.index = [0]

    # Nimeä sarakkeet uudestaan työnteon helpottamiseksi.
    db5.columns = ["var1", "var2"]
    db5m.columns = ["var3", "var4"]
    db5m2.columns = ["var5", "var6"]

    # Yhdistä taulukot.
    db = [db5, db5m, db5m2]
    db = pd.concat(db,axis=1)

    # Laske tunnusluku taulukon arvoista
    luku = 100*(db["var1"] + db["var3"] + db["var4"])/(db["var2"] + db["var5"] + db["var6"])
    sanakirja.update({dic1[lyh]: luku[0]})
    
    
# Kuvio 9:n piirtämiseen
    
def chart9(p, kk, v, lyh):
    """
    Käytä tätä funktiota pelkästään Chart9:n piirtämiseen. Ideana on, että kaikilla mailla on monta aikasarjaa, jotka pitää aggregoida lopullisen version
    tuottamiseksi.
    """
    # Tee tämä :ch9 = exread(sheet)
    db9 = haepvm(ch9,p,kk,v)
    db9 = db9.filter(like=lyh,axis=1) # Filtteröi taulukkoa s.e. vain 1 maa jää jäljelle
    try: # Koska kaikkia lyhenteellä haettavia maita ei löydy datasta, tapahtuu väistämättä virheitä
        db9.columns = ["var1", "var2", "var3", "var4", "var5", "var6"] # Nimeä sarakkeet uudestaan elämän helpottamiseksi
    except:
        pass
    else:
        db9.index = [0]
        luku = 100*(db9["var5"][0] + db9["var6"][0])/(db9["var1"][0]-db9["var2"][0]+db9["var3"][0]-db9["var4"][0]) # Varsinainen laskettava luku, joka siirretään Exceliin
        exceliin.update({dic1[lyh]: luku})

# Käytä tätä jakaaksesi taulukon 1. rivi sen 2. rivillä

def jako(x):
    """
    Jaa taulukon 1. rivi sen 2. rivillä
    """
    try:
        return x[0]/x[1]
    except:
        return x[0]
        
def chart11(p, kk, v):
    """
    Käytä tätä funktiota Chart11:n piirtämiseen.
    """
    ch11i = exread("Chart11i", "B,BD:CC")
    ch11b = exread("Chart11b", "B,AD:BC")
    df11i = haepvm(ch11i, p, kk, v)
    df11b = haepvm(ch11b, p, kk, v)

    # Yhdistä taulukot ja tee sarakekohtaiset jakolaskut
    df = pd.concat([df11i, df11b],axis=0)
    df = df.drop(columns=["Date"])
    df.index = [0,1]
    df.loc["value"] = 100*df.loc[0]/df.loc[1]
    df.loc["maa"] = df.columns
    df = df.transpose()
    # Luo uusi indeksi, ota maat ja arvot talteen, ja transponoi:

    df = df[["value", "maa"]]
    df.columns = ["value", "maa"]
    df = df.sort_values(by="value", axis=0, ascending=False)
    df.to_excel(writer, sheet_name="Chart11a", na_rep="#N/A", index=False)
    print("Chart11a tallenttu")
    

#######################
## Kuvio 1a
#######################

sortandsave(31, 3, 2018, "Chart1", "B,D:AF")

#######################
## Kuvio 1b
#######################

finmedian("Chart1")

#######################
## Kuvio 3a
#######################

sortandsave(31, 3, 2018, "Chart3", "A, DK:EL,FO")

#######################
## Kuvio 3b
#######################

finmedian("Chart3")

#######################
## Kuvio 4a
#######################

sortandsave(31, 12, 2016, "Chart4", "A,C:AD,AM")

#######################
## Kuvio 4b
#######################

finmedian("Chart4")

#######################
## Kuvio 5
#######################
# Tarvitaan vähän edistyneempiä kikkoja, datat 3 eri välilehdeltä ja osin sekä kuukausi- että kvartaalidatasta.
sanakirja = dict()
ch5q = exread("Chart5", "A,C:BH")
ch5m = exread("Chart5m", "B,EJ:GO")
ch5m2 = exread("Chart5m2", "B,DZ:GE")
for key, val in dic1.items():
    try:
        chart5(31, 12, 2017, key)
    except:
        pass
db5 = pd.DataFrame(list(sanakirja.items()))
db5.columns = ["maa", "value"]

# Lisää EU-mediaani
# Ongelmana on, että EU-mediaanin laskutapa ei täsmää siihen, millä
# Patu-kansiossa lasku on tehty. Hae EU-mediaani Patusta!
med5 = db5["value"].mean()
db5 = db5.append([{"maa": "EU", "value": med5}])
print(db5.tail()) 

# Sorttaa ja tallenna Exceliin
db5 = db5.sort_values(by="value", ascending=False)
db5.to_excel(writer, sheet_name="Chart5a", na_rep="#N/A", index=False)
print("Chart5a tallennettu onnistuneesti")

#######################
## Kuvio 5b
#######################



#######################
## Kuvio 6a
#######################

sortandsave(30, 9, 2017, "Chart6", "A,AE:BG")

#######################
## Kuvio 6b
#######################

finmedian("Chart6")

#######################
## Kuvio 7a
#######################
# Koska Kuvio 7:n data haetaan Kuvio 6:n sheetistä, tässä tarvitaan vähän oveluutta.
# Tämä ei vielä tallenna oikeaa sarjaa, vaan pitäisi summata Chartit 6 ja 7
# tämä testaa vain toimiiko uusi funktion argumentti
sortandsave(30, 9, 2017, "Chart6", "A,C:AD,BH", "Chart7")

#######################
## Kuvio 7b
#######################



#######################
## Kuvio 8a
#######################

sortandsave(31, 12, 2017, "Chart8", "A,C:AE")

#######################
## Kuvio 8b
#######################

finmedian("Chart8")

#######################
## Kuvio 9a
#######################

exceliin = dict()
ch9 = exread("Chart9")

chart9(30, 9, 2017, "Czech")

for key, val in dic1.items():
    chart9(30,9,2017,key)
df9 = pd.DataFrame(list(exceliin.items()))
df9.columns = ["maa", "value"]
df9 = df9.sort_values(by="value",ascending=False)
df9.to_excel(writer, sheet_name="Chart9a", na_rep="#N/A", index=False)
print("Chart9a tallennettu")

#######################
## Kuvio 11a
#######################

chart11(30, 9, 2017)


#######################
## Kuvio 11b
#######################



writer.save()
writer.close()

end = time.time()

ero = end - start

print("Aikaa kului " + str(ero) + " sekuntia")

