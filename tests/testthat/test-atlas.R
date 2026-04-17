parcels <- c(100, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
atlas_names_7 <- paste0("yan7_", parcels)
atlas_names_17 <- paste0("yan17_", parcels)

for (nm in c(atlas_names_7, atlas_names_17)) {
  atlas <- do.call(nm, list())

  describe(paste(nm, "atlas"), {
    it("is a ggseg_atlas", {
      expect_s3_class(atlas, "ggseg_atlas")
      expect_s3_class(atlas, "cortical_atlas")
    })

    it("is valid", {
      expect_true(ggseg.formats::is_ggseg_atlas(atlas))
    })
  })
}

describe("yan7_400 atlas rendering", {
  it("renders with ggseg", {
    p <- ggplot2::ggplot() +
      ggseg::geom_brain(
        atlas = yan7_400(),
        mapping = ggplot2::aes(fill = label),
        position = ggseg::position_brain(hemi ~ view),
        show.legend = FALSE
      ) +
      ggplot2::scale_fill_manual(
        values = yan7_400()$palette,
        na.value = "grey"
      ) +
      ggplot2::theme_void()
    vdiffr::expect_doppelganger("yan7_400-2d", p)
  })

  it("renders with ggseg3d", {
    skip_if_not_installed("ggseg.meshes")
    p <- ggseg3d::ggseg3d(atlas = yan7_400())
    expect_s3_class(p, c("plotly", "htmlwidget"))
  })
})
