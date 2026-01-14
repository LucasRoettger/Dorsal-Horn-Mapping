# Script to project coordinates onto reference outlines
# By Lucas Röttger, 14.01.2026
# Requires: folder "ROIOUTLINES" and input .xls files starting with "Coordinates"

library(readxl)
library(ggplot2)
library(stringr)
library(gridExtra)
library(tools)

concatFigures <- TRUE
plotExcluded <- TRUE

# Function definitions -------------------------------------------------------

cleanUpFilename <- function(oldFileName, coordinateTable) {
  # Replace '.' and '-' in filenames
  newFileName <- gsub("\\.|-", "_", oldFileName)
  if (nchar(newFileName) == 1) {
    newFileName <- paste0("LR", newFileName)
  }
  mask <- startsWith(coordinateTable$Label, oldFileName)
  coordinateTable$Label[mask] <- paste0(newFileName, ".tif")
  list(newFileName = newFileName, coordinateTable = coordinateTable)
}

getColorArray <- function(groups) {
  # Map group numbers to RGB colors
  colors <- matrix(0, nrow = length(groups), ncol = 3)
  for (i in seq_along(groups)) {
    colors[i, ] <- switch(as.character(groups[i]),
                          "2" = c(0, 1, 0),     # green
                          "3" = c(1, 0, 0),     # red
                          "4" = c(0, 0, 1),     # blue
                          "5" = c(1, 1, 0),     # yellow
                          "6" = c(0, 1, 1),     # cyan
                          "7" = c(1, 0, 1),     # purple
                          "8" = c(0.5, 0, 0),   # dark red
                          "9" = c(0, 0.5, 0),   # dark green
                          c(0, 0, 0)            # black
    )
  }
  rgb(colors[,1], colors[,2], colors[,3])
}

# ---------------------------------------------------------------------------

inputDir <- choose.dir(caption = "Select transformation folder")
outlineDir <- choose.dir(caption = "Select ROIOUTLINES-folder")
files <- list.files(inputDir, pattern = "(?i)coordinates.*\\.xls$", full.names = TRUE)

# Read all coordinate sheets into one table
tempTable <- do.call(rbind, lapply(files, function(f) {
  as.data.frame(read_excel(f, sheet = "Cell_Data", skip = 1))
}))
colnames(tempTable)[1:8] <- c('Label', 'X', 'Y', 'Group', 'tX', 'tY', 'Lamina', 'Segment')

# Extract unique image base names
tempTable$Label <- sub(":.*", "", tempTable$Label)
uniqueLabels <- unique(tempTable$Label)
fileNames <- sapply(uniqueLabels, function(x) sub("\\.tif$", "", x))

coordinatesPerImage <- list()

for (fileName in fileNames) {
  if (str_detect(fileName, "\\.|-")) {
    result <- cleanUpFilename(fileName, tempTable)
    fileName <- result$newFileName
    tempTable <- result$coordinateTable
  }
  imgData <- tempTable[startsWith(tempTable$Label, fileName), ]
  coordinatesPerImage[[fileName]] <- imgData
}

# Plotting ------------------------------------------------------------

plot_list <- list()
fields <- names(coordinatesPerImage)

for (k in seq_along(fields)) {
  df <- coordinatesPerImage[[fields[k]]]
  segment <- df$Segment[1]
  outline_pattern <- paste0(outlineDir, segment, "_*")
  outline_files <- list.files(path = outlineDir, pattern = paste0(segment, "_.*"), full.names = TRUE)
  
  outlines <- lapply(outline_files, function(f) {
    o <- read.csv(f, header = TRUE)
    rbind(o, o[1, ]) # close loop
  })
  
  coords <- df[, c("tX", "tY")]
  colors <- getColorArray(df$Group)
  
  if (!plotExcluded) {
    keep <- df$Group != 0
    coords <- coords[keep, ]
    colors <- colors[keep]
  }
  
  # Build ggplot for each image
  p <- ggplot() +
    lapply(outlines, function(o) geom_path(data = o, aes(x = xpoints, y = ypoints), color = "black", linewidth = 0.5)) +
    geom_point(aes(x = coords$tX, y = coords$tY), color = colors, size = 1.8) +
    scale_y_reverse() +
    ggtitle(fields[k]) +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5, size = 10))
  
  plot_list[[k]] <- p
}

if (concatFigures) {
  # Combine by segment
  grid.arrange(grobs = plot_list)
} else {
  for (p in plot_list) print(p)

}
