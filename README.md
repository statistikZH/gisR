# gisR
Introduction to GIS with R / Presentation and use case for the Canton of Zurich


# Scripts
Run the scripts before knitting the presentation. Some files that are downloaded/calculated within the scripts are used by the quarto.

```
├── 01_dlFromSTAC.R
├── 02_getGeodata.R
├── 03_loadSaveRasters.R
├── 04_calculateNDVI.R
├── 05_statistics.R
└── functions.R
```

- `01_dlFromSTAC`  
Download Band 2-4 & 8 of the Sentinel-2 scene `S2B_MSIL2A_20230613T102609_R108_T32TMT_20230613T173356`

- `02_getGeodata`  
Download Layers from a WFS Server
  - Landwirtschaftliche Nutzflächen
  - Bezirke
  - Gemeindegrenzen 
  - Kantonsgrenze Kt. ZH

- `03_loadSaveRasters`  
Combine 4 Bands to a single 4-band Raster, project it to EPSG:2056 and save to file.


- `04_calculateNDVI`  
    Load a 4 Band tif file, calculate the NDVI according to:  
    $$NDVI = \frac{(NIR - RED)}{(NIR + RED)}$$  
    and save it to file.

- `05_statistics`  
From the NDVI raster and a polygon layer, calculate the mean NDVI per feature, indicating vegetation health per parcel.


