# Visualize data in a map

library(rgdal)
library(sf)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(viridis)
library(raster)
library(rgeos)
library(tmap)
library("RColorBrewer")
library(ratlas)
source("FonctionsToPlot.R")
library(SpaColExt)

extract_taxa <- get_taxa(scientific_name = "aves") # Load taxons
species <- unique(extract_taxa$valid_scientific_name) # Extract all cientific names
species_test = c("Vireo philadelphicus","Dolichonyx oryzivorus") # Small test, to delete
s= "Cathartes aura"
t_start = 1970
t_end = 2040

sequence = t_end - t_start + 1



Spatial_boundary = st_read("/home/clara/Documents/PhD/Project/RealDataTesting/RawData/CADRE_ECO_QUEBEC.shp") # Spatial data
# Spatial_boundary = Spatial_boundary[which(!Spatial_boundary$NOM == "Estuaire et golfe du Saint-Laurent"),]
Spatial_boundary$FID = as.factor(Spatial_boundary$FID) # Use FID as factor


sightings_fid = readRDS("/home/clara/Documents/PhD/Project/RealDataTesting/output/sightings/sightings_fid_Niv_1_Cathartes aura.rds")


Create_extinction_map_solow = function(Spatial_boundary, sightings_fid, t_start,t_end ) {

  extant_prob = matrix(NA,nrow=length(sightings_fid), ncol= sequence)


  for (i in 1:length(sightings_fid)){

    extant_prob[i,] = c(posterior_probability_extinction_varying_end_year(sightings_fid[[i]], t_start, t_end ))


    extant_prob = data.frame(extant_prob)

  }

  extant_prob$FID <- as.factor(c(names(sightings_fid)))
  colnames(extant_prob) <- c(seq(t_start,t_end, by = 1), "FID")


  extant_probability = tidyr::gather(extant_prob, "year", "Extant_probability", 1:all_of(sequence))
  saveRDS(extant_probability, paste("extant_probability_",s,"_Niveau1_Solow.RDS", sep = ""))
  ggplot(extant_probability, aes(x=as.numeric(year), y=Extant_probability, group = FID)) +
    geom_line(aes(colour = FID)) +
    ggtitle("Extant probability") +
    theme_bw() +
    facet_wrap(~FID)

  Spatial_boundary = full_join(Spatial_boundary, extant_prob, by = "FID" )

  Spatial_boundary = subset(Spatial_boundary, LAYER == "CR_NIV_01_S")
  # Spatial_boundary_year = subset(Spatial_boundary, year== c(2000,2010,2020,2030))

  # # Spatial_boundary_id = Spatial_boundary[,c("FID")]
  # year = c(2000,2010,2020,2030)
  #
  # plots_extant_prob = list(NULL)
  # for ( y in year) {
  #
  Plot_Polygons_with_extinction_2000 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2000`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )


  Plot_Polygons_with_extinction_2010 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2010`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )


  Plot_Polygons_with_extinction_2020 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2020`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )


  Plot_Polygons_with_extinction_2022 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2022`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )

  # }

  # figure <- ggarrange(Plot_Polygons_with_extinction_2010 + rremove("xlab"),
  #                     Plot_Polygons_with_extinction_2020 + rremove("xlab"),Plot_Polygons_with_extinction_2022,
  #                     ncol = 1, nrow = 3,   common.legend = TRUE, legend="right" )
  # print(figure)
  # ggsave(figure, file=paste0("output/tests/Plot_Polygons_with_extinction_", s,".png"), width = 14, height = 10, units = "cm")

  ggplot(extant_probability, aes(x=as.numeric(year), y=Extant_probability, group = factor(FID))) +
    geom_line(aes(colour = factor(FID))) +
    ggtitle("Extant probability") +
    theme_bw()
  }

Create_extinction_map_kodicara = function(Spatial_boundary, sightings_fid, t_start,t_end ) {

  extant_prob = matrix(NA,nrow=length(sightings_fid), ncol= sequence)


  for (i in 1:length(sightings_fid)){
    extant_prob[i,] = c(posterior_probability_extinction_non_homogeneos_varying_end_year(sightings_fid[[i]], t_start, t_end ))

    extant_prob = data.frame(extant_prob)

  }

  extant_prob$FID <- as.factor(c(names(sightings_fid)))
  colnames(extant_prob) <- c(seq(t_start,t_end, by = 1), "FID")


  extant_probability = tidyr::gather(extant_prob, "year", "Extant_probability", 1:all_of(sequence))
  write.csv(extant_probability,paste("output/tests/extant_probability_kodikara_",s, ".csv", sep = ""),row.names = FALSE)
  extant_probability = read.csv(paste("output/tests/extant_probability_kodikara_",s, ".csv", sep = ""))
  Spatial_boundary = full_join(Spatial_boundary, extant_prob, by = "FID" )
  Spatial_boundary = subset(Spatial_boundary, LAYER == "CR_NIV_01_S")

  # Spatial_boundary_year = subset(Spatial_boundary, year== c(2000,2010,2020,2030)| is.na(year))
  # Spatial_boundary_year = subset(Spatial_boundary, year== c(2000,2010,2020,2030))

  # # Spatial_boundary_id = Spatial_boundary[,c("FID")]
  # year = c(2000,2010,2020,2030)
  #
  # plots_extant_prob = list(NULL)
  # for ( y in year) {
  #
  Plot_Polygons_with_extinction_2000 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2000`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )


  Plot_Polygons_with_extinction_2010 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2010`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )


  Plot_Polygons_with_extinction_2020 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2020`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )


  Plot_Polygons_with_extinction_2022 = ggplot(Spatial_boundary)+
    geom_sf( aes(fill = `2022`),
             lwd = 0.01
    )+
    theme_bw() +
    scale_fill_gradient(low ="#ff0d0d",
                        high ="#69B34C",
                        limits = c(0, 1),
                        breaks = c(0, 0.2, 0.4, 0.6,0.8,1),
                        na.value = "#FAFAFA")+
    theme(text = element_text(size = 5)) +
    guides(fill=guide_legend(title="Extant Prob"))
  # facet_grid(~ LAYER )

  # }

  # figure <- ggarrange(Plot_Polygons_with_extinction_2010 + rremove("xlab"),
  #                     Plot_Polygons_with_extinction_2020 + rremove("xlab"),Plot_Polygons_with_extinction_2022,
  #                     ncol = 1, nrow = 3,   common.legend = TRUE, legend="right" )
  # ggsave(figure, file=paste0("output/tests/Plot_Polygons_kodicara_with_extinction_", s,".png"), width = 14, height = 10, units = "cm")

  ggplot(extant_probability, aes(x=as.numeric(year), y=Extant_probability, group = factor(FID))) +
    geom_line(aes(colour = factor(FID))) +
    ggtitle("Extant probability") +
    theme_bw()
}



for (s in species) {
  # taxa <- get_taxa(scientific_name = s )
  # data <- get_gen('ecozones_taxa_year_obs_count', id_taxa_obs=taxa$id_taxa_obs, .schema = 'public_api',niv=1)
  # data$valid_scientific_name =  s
  #    if(length(data) <= 4) next
  # sightings_fid = sightings_by_fid(data)
  #
  # saveRDS(sightings_fid, file=paste0("output/sightings/sightings_fid_Niv_1_",s,".rds"))
  sightings_fid = readRDS("/home/clara/Documents/PhD/Project/RealDataTesting/output/sightings/sightings_fid_Niv_1_Cathartes aura.rds")
  # Create_map(Spatial_boundary,sightings_fid)

  Create_extinction_map_solow(Spatial_boundary, sightings_fid, t_start,t_end )
  Create_extinction_map_kodicara(Spatial_boundary, sightings_fid, t_start,t_end )

}
