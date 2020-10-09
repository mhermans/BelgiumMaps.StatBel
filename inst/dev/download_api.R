# install.packages('rappdirs')
library(rappdirs)
library(memoise)
library(sf)
library(assertr)

# download, extract and return path with Statbel SQlite sectors file
get_statbel_sectors <- function(url=NULL, extract = TRUE, cache = TRUE) {
  
  # url = 'https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_20200101.shp.zip'
  url = 'https://statbel.fgov.be/sites/default/files/files/opendata/Statistische%20sectoren/sh_statbel_statistical_sectors_20200101.sqlite.zip'
  fn_source = file.path(DIR_SOURCE, basename(url))
  unzip_path = file.path(DIR_PROCESSED, tools::file_path_sans_ext(basename(url)))
  
  if ( !dir.exists(DIR_CACHE) ) { 
    dir.create(DIR_CACHE, recursive = TRUE)
    dir.create(DIR_SOURCE, recursive = TRUE)
    dir.create(DIR_PROCESSED, recursive = TRUE)
    dir.create(DIR_INST, recursive = TRUE)
  }
  
  if ( !file.exists(fn_source) ) { download.file(url, fn_source) }
  
  if ( !dir.exists(unzip_path) ) { unzip(zipfile = fn_source, exdir = DIR_PROCESSED ) }

  sqlite_path = file.path(unzip_path, tools::file_path_sans_ext(basename(url)))
  
  if ( file.exists(sqlite_path ) ) { return(sqlite_path) }
  else { print('ERROR') }
  
}


# cross-platform standard permanent user cache dir
DIR_CACHE = rappdirs::user_cache_dir(appname = 'BelgiumMaps.StatBel', appauthor = 'R')
DIR_SOURCE = file.path(DIR_CACHE, 'data', 'source', 'statbel')
DIR_PROCESSED = file.path(DIR_CACHE, 'data', 'processed', 'statbel')
DIR_INST = file.path(DIR_CACHE, 'data', 'inst')

unlink(DIR_CACHE, recursive = TRUE)
fn_sectors_sqlite <- get_statbel_sectors()
sectors_2020 <- st_read(dsn = fn_sectors_sqlite) %>%
  verify(dim(.) == c(19794, 31)) %>%
  st_zm() # drop Z-dimension



process_statbel_sectors <- function(fn_sectors) {
  
  # derive aggregated levels
  
  # save to cached inst directory
  
}




get_boundaries(
  level = "municipality", # all | sector | arrondissement | ... => useful? Sectors needed anyway...
  clean_names = TRUE, 
  simplify_hierachy = TRUE, # Brussel as province, arrondissement Verviers
  projection = "4326", # original / WGS84 / Lambert / 
  version = "current", # long-term: requesting older versions?
  #format = "sf", # sf / sp => select format here, or only at load step?
  cache = TRUE) # check & load from cache if present


load_boundaries(level = "all", format = 'sf', projection = "4326")









# example of google tile caching in ggmap
# https://github.com/dkahle/ggmap/blob/master/R/get_googlemap.R#L430
# https://github.com/dkahle/ggmap/blob/master/R/file_drawer.R

# issue: can't read from a connection / without unzipping? => unzip
# con <- unz(description = here::here('inst/extdata/sh_statbel_statistical_sectors_20200101.sqlite.zip'),
#            filename = 'sh_statbel_statistical_sectors_20200101.sqlite', open = 'rb')
# read_sf(con)

# memoise more generic but also more opaque to deal with compared to path testing
# fs_cache = memoise::cache_filesystem(cache_path)
# get_statbel_m <- memoise(get_statbel_sectors)