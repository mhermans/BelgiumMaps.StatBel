# ############################################ #
# import and compare 2020 updated Statbel data #
# ############################################ #

library(sf)
library(here)
library(assertr)
library(dplyr)
library(janitor)
library(tmap)

# Beschrijving: vectorieel bestand met de statistische sectoren 2020
# https://statbel.fgov.be/nl/open-data/statistische-sectoren-2020
# https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_20200101.shp.zip
# 
# sh_statbel_statistical_sectors_20200101 bestaat uit de statistische sectoren van 
#  België op 01/01/2020. Dit bestand is geldig tot de volgende wijziging/verbetering 
#  van de gemeente grenzen. De versie van de gemeentegrenzen is degene van 2019. 
#  et verschilt met de versie van 2018 wegens de verbetering van de voorstelling 
#  van de gemeentegrenzen in het land door de Algemene Administratie van de 
#  Patrimonium Documentatie (AAPD) van de FOD Financiën, de fusie van 
#  een aantal gemeenten en de aanpassing van districtgrenzen in Antwerpen. 
#  Vanaf de toestand 01012019 kan de gemeente code niet meer uit de statistische 
#  sectorcode afgeleid worden.
# 
# Referentiesysteem: Belgische Lambert 1972 (EPSG : 31370)
# 
# Nauwkeurigheid: 1/10.000 

shp_dir <- unzip(
  zipfile = here::here('inst/extdata/sh_statbel_statistical_sectors_20200101.shp.zip'),
  exdir = tempdir() )

sectors_2020 <- st_read(
  file.path(tempdir(), 'sh_statbel_statistical_sectors_20200101.shp')) %>%
  verify(dim(.) == c(19794, 30)) %>%
  st_zm() %>% # drop Z-dimension
  clean_names()

stopifnot(st_crs(sectors_2020)$input == "Belge 1972 / Belgian Lambert 72")

# convert to WGS84 coordinates instead of Lambert
sectors_2020 <- st_transform(sectors_2020, crs = 4326)


# add area in km2


# make Brussels into a province



# Issue: arrondissement Verviers (REFNIS-code 63000) is verdeeld in 2 afzonderlijke NUTS: 
# BE335 => deze code heeft betrekking op de Franstalige gemeenten van het arrondissement Verviers
# BE335 => deze code heeft betrekking op de Duitstalige gemeenten van het arrondissement Verviers

sectors_2020 <- sectors_2020 %>%
  mutate(nuts3 = if_else(c_arrd == '63000', 'BE335/BE336', nuts3))


# Construct cleaned sector dataset (BE_ADMIN_SECTOR)
# --------------------------------------------------

sectors_2020 %>%
  mutate(id = cs01012020) %>%
  rename(
    label_nl = t_sec_nl,
    label_de = t_sec_de,
    label_fr = t_sec_fr)


# aggregate sectors to municipal level (BE_ADMIN_MUNTY)
# -----------------------------------------------------

# De REFNIS-codes werden in 2019 gewijzigd naar aanleiding van de fusie van 
# bepaalde gemeenten in Vlaanderen en de wijziging van de administratieve arrondissementen 
# in de provincie Henegouwen. In totaal hebben de wijzigingen betrekking op 26 gemeenten. 
# Door de fusies daalt het aantal gemeenten in België van 589 naar 581. 

MUNI <- sectors_2020 %>%
  group_by(cnis5_2020) %>%
  summarise(
    nuts0 = unique(c_country),
    nuts1 = unique(nuts1),
    nuts2 = unique(nuts2),
    nuts3 = unique(nuts3),
    label_nl = unique(t_mun_nl),
    label_fr = unique(t_mun_fr),
    label_de = unique(t_mun_de),
    area = sum(m_area_ha))%>%
  ungroup() %>%
  rename(refnis = cnis5_2020)  %>%
  verify(dim(.) == c(581, 9))


# aggregate sectors to district level (BE_ADMIN_DISTRICT) => CD_DSTR_REFNIS
# -------------------------------------------------------
# = arrondissment

DISTRICT <- sectors_2020 %>%
  group_by(c_arrd) %>%
  summarise(
    nuts0 = unique(c_country),
    nuts1 = unique(nuts1),
    nuts2 = unique(nuts2),
    nuts3 = unique(nuts3),
    label_nl = unique(t_arrd_nl),
    label_fr = unique(t_arrd_fr),
    label_de = unique(t_arrd_de),
    area = sum(m_area_ha))%>%
  ungroup() %>%
  rename(refnis = c_arrd) %>%
  verify(dim(.) == c(43, 10))

DISTRICT
qtm(DISTRICT)


# aggregate to provincial level (BE_ADMIN_PROVINCE) => CD_PROV_REFNIS
# -------------------------------------------------

PROV <- sectors_2020 %>%
  group_by(c_provi) %>%
  summarise(
    nuts0 = unique(c_country),
    nuts1 = unique(nuts1),
    nuts2 = unique(nuts2),
    label_nl = unique(t_provi_nl),
    label_fr = unique(t_provi_fr),
    label_de = unique(t_provi_de),
    area = sum(m_area_ha))%>%
  ungroup() %>%
  rename(refnis = c_provi)

qtm(PROV)
qtm(PROV %>% filter(nuts2 == 'BE10'))

# aggregate to regional level (BE_ADMIN_REGION) => 
# ---------------------------------------------

REGION <- sectors_2020 %>%
  group_by(c_regio) %>%
  summarise(
    nuts0 = unique(c_country),
    nuts1 = unique(nuts1),
    label_nl = unique(t_regio_nl),
    label_fr = unique(t_regio_fr),
    label_de = unique(t_regio_de),
    area = sum(m_area_ha))%>%
  ungroup() %>%
  rename(refnis = c_regio)

qtm(REGION)

id
label_nl / fr / de 

nis_municipality
nis_district
nis_province
nis_region

label_sector_nl / fr / de
label_municipality_nl
label_district_nl
label_province_nl
label_region_nl




# aggregate to national level (BE_ADMIN_BELGIUM)
# ----------------------------------------------

BE <- sectors_2020 %>%
  summarise(M_AREA_HA = sum(M_AREA_HA))

REGION


tm_shape(BE) + tm_polygons()

# save sf-objects in .rds files


library(BelgiumMaps.StatBel)
data('BE_ADMIN_REGION')
data('BE_ADMIN_BELGIUM')
data("BE_ADMIN_DISTRICT")
data("BE_ADMIN_MUNTY")
data("BE_ADMIN_AGGLOMERATIONS")
data("BE_ADMIN_SECTORS")
st_as_sf(BE_ADMIN_REGION)
st_as_sf(BE_ADMIN_BELGIUM)
st_as_sf(BE_ADMIN_AGGLOMERATIONS)
st_as_sf(BE_ADMIN_DISTRICT) %>%
  print(n=43)
st_as_sf(BE_ADMIN_MUNTY)
st_as_sf(BE_ADMIN_SECTORS)

qtm(BE_ADMIN_AGGLOMERATIONS)

https://statbel.fgov.be/nl/over-statbel/methodologie/classificaties/geografie

# * janitor::clean_names => consistent variable names (lower case, underscore, unicode)
# * NIS-codes are 5-digits, so prefix with 0's where needed
# be_sector be_municipality be_district be_province be_region be_nation 
