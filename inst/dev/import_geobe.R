



AdminVector is the vector data set of Belgian administrative and statistical units. 
It includes various classes. First class: Belgian statistic sectors as defined by the FPS Economy. 
Second class: municipal sections, with no unanimous definition. The five following classes 
correspond to official administrative units as managed by the FPS Finance. Other classes are 
added to these classes, like border markers or the Belgian maritime zone. The boundaries of 
the seven first classes are consolidated together in order to keep the topological 
cohrence of the objects. This data set can be freely downloaded.


https://www.geo.be/catalog/details/fb1e2993-2020-428c-9188-eb5f75e284b9?l=en
https://ac.ngi.be/remoteclient-open/ngi-standard-open/Vectordata/AdminVector/AdminVector_WGS84_shp.zip

url <- "https://ac.ngi.be/remoteclient-open/ngi-standard-open/Vectordata/AdminVector/AdminVector_WGS84_shp.zip"

temp <- tempfile()
download.file(url, temp)
unlink(temp)

shp_dir <- unzip(zipfile = temp, exdir = tempdir() )

library(sf)
library(assertr)
library(janitor)

sectors_2020 <- st_read(
  file.path(tempdir(), 'adminvectorwgs/'), layer = 'AD_0_StatisticSector') %>%
  verify(dim(.) == c(20448, 5)) %>%
  st_zm() %>% # drop Z-dimension
  clean_names()

plot(sectors_2020)
