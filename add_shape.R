library(ggplot2)
library(tidyverse)
library(sf)

# Public sequencing data
cog <- read.csv("data/input/cog_metadata_microreact_geocodes_only.csv")

# From https://www.iso.org/obp/ui/#iso:code:3166:GB
iso_3166_gb <- readODS::read_ods("data/input/iso_3166_gb.ods")
names(iso_3166_gb) <- c("TYPE_3", "iso_3166_code", "NAME_3")

# Just London
iso_3166_ldn <- iso_3166_gb %>%
  filter(TYPE_3 %in% c("London borough", "city corporation"))

nrow(iso_3166_ldn) # 32 boroughs and 1 city corporation

# Just sequences in London
cog_ldn <- cog %>%
  filter(iso_3166_code %in% iso_3166_ldn$iso_3166_code)

gadm36_GBR_3_sf <- readRDS("data/input/gadm36_GBR_3_sf.rds")

gadm36_GBR_3_sf_ldn <- gadm36_GBR_3_sf %>%
  filter(NAME_3 %in% iso_3166_ldn$NAME_3) %>%
  merge(iso_3166_ldn, by = "NAME_3")

# Checking that it looks right
ggplot(data = gadm36_GBR_3_sf_ldn) +
  geom_sf()

cog_ldn_sf <- cog_ldn %>%
  left_join(gadm36_GBR_3_sf_ldn, by = "iso_3166_code")

saveRDS(cog_ldn_sf, "data/output/cog_metadata_microreact_geocodes_only_sf.rds")

# Merging to regions
la_to_regions <- read.csv("data/input/la_to_regions_website_updated.csv")
iso_3166_gb_region <- merge(iso_3166_gb, la_to_regions, by.x = c("NAME_3"), by.y = c("Area_name"), fill = NA)

# How many are in UK?
cog_uk <- cog %>%
  filter(adm1 %in% c("UK-ENG", "UK-WLS", "UK-SCT", "UK-NIR"))
dim(cog_uk)

# How many are in England?
cog_eng <- cog %>%
  filter(adm1 %in% c("UK-ENG"))
dim(cog_eng)

# Showing that some of the GB-SWA rows are in UK-WLS, UK-ENG and UK-SCT (!)
cog %>% filter(iso_3166_code == "GB-SWA") %>% select(adm1) %>% unique()

cog_merged_all <- merge(cog, iso_3166_gb_region, by = "iso_3166_code", fill = NA)
dim(cog_merged_all)

cog_merged_uk <- merge(cog_uk, iso_3166_gb_region, by = "iso_3166_code", fill = NA)
dim(cog_merged_uk)

cog_merged_eng <- merge(cog_eng, iso_3166_gb_region, by = "iso_3166_code", fill = NA)
dim(cog_merged_eng)

# Missing ISOs
missing_iso <- cog_eng$iso_3166_code[!(cog_eng$iso_3166_code %in% iso_3166_gb$iso_3166_code)]
unique(missing_iso)

missing_iso_region <- cog_eng$iso_3166_code[!(cog_eng$iso_3166_code %in% iso_3166_gb_region$iso_3166_code)]
unique(missing_iso_region) # These are missing because they don't have a regional matching from iso_3166_gb.ods
