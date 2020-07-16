"""
freely copied from @vincentsarago
"""

# TODO: this colormap does not completely match all the byte values in provided the {Country}/LC.tif layers

import rasterio
# http://due.esrin.esa.int/files/GLOBCOVER2009_Validation_Report_2.2.pdf
cmap = {
    0: (0, 0, 0, 0),  # Nodata
    11: (192, 240, 239, 255),  # Post-flooding or irrigated croplands
    14: (255, 255, 112, 255),  # Rainfed croplands
    20: (225, 239, 111, 255),  # Mosaic Cropland (50-70%) / Vegetation (grassland, shrubland, forest) (20-50%)
    30: (204, 204, 108, 255),  # Mosaic Vegetation (grassland, shrubland, forest) (50-70%) / Cropland (20-50%)
    40: (56, 100, 24, 255),  # Closed to open (>15%) broadleaved evergreen and/or semi-deciduous forest (>5m)
    50: (89, 158, 37, 255),  # Closed (>40%) broadleaved deciduous forest (>5m)
    60: (178, 198, 46, 255),  # Open (15-40%) broadleaved deciduous forest (>5m)
    70: (35, 62, 14, 255),  # Closed (>40%) needleleaved evergreen forest (>5m)
    90: (66, 100, 23, 255),  # Open (15-40%) needleleaved deciduous or evergreen forest (>5m)
    100: (122, 130, 31, 255),  # Closed to open (>15%) mixed broadleaved and needleleaved forest (>5m)
    110: (145, 159, 37, 255),  # Mosaic Forest/Shrubland (50-70%) / Grassland (20-50%)
    120: (178, 149, 35, 255),  # Mosaic Grassland (50-70%) / Forest/Shrubland (20-50%)
    130: (127, 100, 23, 255),  # Closed to open (>15%) shrubland (<5m)
    140: (236, 178, 65, 255),  # Closed to open (>15%) grassland
    150: (249, 234, 176, 255),  # Sparse (>15%) vegetation (woody vegetation, shrubs, grassland)
    160: (67, 119, 92, 255),  # Closed (>40%) broadleaved forest regularly flooded - Fresh water
    170: (84, 148, 120, 255),  # Closed (>40%) broadleaved semi-deciduous and/or evergreen forest regularly flooded - Saline water
    180: (124, 219, 135, 255),  # Closed to open (>15%) vegetation (grassland, shrubland, woody vegetation) on regularly flooded or waterlogged soil - Fresh, brackish or saline water
    190: (167, 27, 8, 255),  # Artificial surfaces and associated areas (urban areas >50%)
    200: (252, 245, 215, 255),  # Bare areas
    210: (41, 72, 196, 255),  # Water bodies
    220: (255, 255, 255, 255),  # Permanent snow and ice
    230: (0, 0, 0, 0),  # Nodata
}
with rasterio.open("lc.tif", "r+") as src_dst:
    src_dst.write_colormap(1, cmap)
