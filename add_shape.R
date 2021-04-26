library(ggplot2)
library(tidyverse)

# Public sequencing data
cog <- read.csv("data/input/cog_metadata_microreact_geocodes_only.csv")

# From https://www.iso.org/obp/ui/#iso:code:3166:GB
iso_3166_gb <- readODS::read_ods("data/input/iso_3166_gb.ods")

# Just London
iso_3166_ldn <- iso_3166_gb %>%
  filter(`Subdivision category` %in% c("London borough", "city corporation"))

# Rename to match columns of the GADM data
names(iso_3166_ldn) <- c("TYPE_3", "iso_3166_code", "NAME_3")

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
