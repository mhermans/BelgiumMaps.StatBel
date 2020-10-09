# ########################################################## #
# check 2019 muncipial merger & relation statistical sectors #
# ########################################################## #

# From: https://statbel.fgov.be/nl/over-statbel/methodologie/classificaties/geografie
# 15 Vlaamse gemeenten hebben formeel hun intentie kenbaar gemaakt om op 1 januari 2019 
# te fuseren. Statbel heeft aan deze nieuwe gemeenten nieuwe NIS-codes toegekend vanaf 01/01/2019.

# Meeuwen-Gruitrode en Opglabbeek: NIS 72042 (nieuwe naam: Oudsbergen)
# Neerpelt en Overpelt: NIS 72043 (nieuwe naam: Pelt)
# Kruishoutem en Zingem: NIS 45068 (nieuwe naam: Kruisem)
# Aalter en Knesselare: NIS 44084 (nieuwe naam: Aalter)
# Deinze en Nevele: NIS 44083 (nieuwe naam: Deinze)
# Puurs en Sint-Amands: NIS 12041 (nieuwe naam: Puurs-Sint-Amands)
# Waarschoot, Lovendegem & Zomergem: NIS 44085 (nieuwe naam: Lievegem)

nis_merged_munis <- c('45017', '45057', '44072', '44080', '44036', '72040',
                      '71047', '12030', '12034', '44011', '44049', '44001',
                      '44029', '72025', '72029')
nis_new_munis <- c('72042', '72043', '45068', '44084', '44083', '12041', '44085')

data("BE_ADMIN_MUNTY")
BE_ADMIN_MUNTY <- st_as_sf(BE_ADMIN_MUNTY)

merged_munis <- BE_ADMIN_MUNTY %>%
  filter(CD_MUNTY_REFNIS %in% nis_merged_munis) %>%
  verify(nrow(.) == 15) %>%
  mutate(color = 'blue')

new_munis <- MUNI %>%
  filter(refnis %in% nis_new_munis) %>%
  verify(nrow(.) == 7) %>%
  mutate(color = 'green')

library(mapview)
mapview(merged_munis, col.regions = 'red', alpha = 0.3, color.lines = 'black') + mapview(new_munis, col.regions = 'green')
