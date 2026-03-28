# Create Yan 2023 Homotopic Cortical Atlases
#
# Parcellations at 100-1000 parcels with Yeo 7-network and 17-network labels.
#
# Reference: Yan X, et al. (2023). NeuroImage, 273:120010.
#
# Run with: Rscript data-raw/create-atlas.R

library(ggseg.extra)
library(ggseg.formats)

Sys.setenv(FREESURFER_HOME = "/Applications/freesurfer/7.4.1")

# ── Download annotation files from CBIG repo ─────────────────────
cbig_base <- paste0(
  "https://raw.githubusercontent.com/ThomasYeoLab/CBIG/master/",
  "stable_projects/brain_parcellation/Yan2023_homotopic/parcellations/",
  "FreeSurfer/fsaverage5/label"
)

annot_dir <- here::here("data-raw", "fsaverage5")
parcels <- seq(100, 1000, by = 100)
networks <- list(
  yeo7 = "Yeo2011_7Networks",
  yeo17 = "Yeo2011_17Networks"
)

for (net_key in names(networks)) {
  net_label <- networks[[net_key]]
  net_dir <- file.path(annot_dir, net_key)
  dir.create(net_dir, showWarnings = FALSE, recursive = TRUE)

  for (res in parcels) {
    for (hemi in c("lh", "rh")) {
      fname <- sprintf("%s.%dParcels_%s.annot", hemi, res, net_label)
      dest <- file.path(net_dir, fname)
      if (!file.exists(dest)) {
        url <- file.path(cbig_base, net_key, fname)
        cli::cli_alert_info("Downloading {.file {fname}}")
        download.file(url, dest, mode = "wb", quiet = TRUE)
      }
    }
  }
}

# ── Build each atlas variant ─────────────────────────────────────
all_atlases <- list()

for (net_key in names(networks)) {
  net_label <- networks[[net_key]]
  net_dir <- file.path(annot_dir, net_key)
  net_num <- gsub("yeo", "", net_key)

  for (res in parcels) {
    atlas_name <- sprintf("yan%s_%d", net_num, res)

    annot_files <- file.path(
      net_dir,
      sprintf(
        c("lh.%dParcels_%s.annot", "rh.%dParcels_%s.annot"),
        res, net_label
      )
    )

    if (!all(file.exists(annot_files))) next

    atlas_raw <- create_cortical_from_annotation(
      input_annot = annot_files,
      atlas_name = atlas_name,
      output_dir = file.path("data-raw", atlas_name),
      skip_existing = TRUE,
      cleanup = FALSE
    ) |>
      atlas_region_contextual("unknown|Background", "label")

    all_atlases[[atlas_name]] <- atlas_raw
    print(atlas_raw)
    plot(atlas_raw)
  }
}

# ── Save all atlases as internal data ─────────────────────────────
sysdata_env <- new.env(parent = emptyenv())
for (nm in names(all_atlases)) {
  sysdata_env[[paste0(".", nm)]] <- all_atlases[[nm]]
}
save(
  list = ls(sysdata_env, all.names = TRUE),
  envir = sysdata_env,
  file = here::here("R", "sysdata.rda"),
  compress = "xz"
)
