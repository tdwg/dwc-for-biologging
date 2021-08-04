# Camera trap data

Lossy transformation to Darwin Core of camera trap data formatted as a [Camera Trap Data Package](https://tdwg.github.io/camtrap-dp/), to enable indexing by GBIF/OBIS.

## Transformation

Data are mapped as an **Occurrence core** and a **Simple Multimedia extension**. This is also the format recommended by [Cadman & González-Talaván (2014) Publishing Camera Trap Data: A Best Practice Guide](http://www.gbif.org/orc/?doc_id=6045) (see [template file](http://links.gbif.org/dcsmst)). Although this does not allow to capture the deployment date range, it does allow to share all relevant information about the source of the observations (i.e. the images), which is considered more worthwhile for primary occurrence data (see also [this discussion](https://github.com/tdwg/dwc-for-biologging/pull/35)).

- [`dwc_occurrence.sql`](sql/dwc_occurrence.sql): This query transforms camtrap-dp observation data to a Darwin Core Occurrence core (Machine Observations). This allows to link occurrences to images in a Multimedia extension, which would not be possible if there already was an Event core. As a result, deployment start/end information is not included. However, by including an `eventID` in the Occurrence core for each deployment, GBIF will present occurrences grouped by [deployment](https://www.gbif.org/dataset/8a5cbaec-2839-4471-9e1d-98df301095dd/event/3b94f935-020f-49d8-bd59-1736f8a266c4).
- [`dwc_multimedia.sql`](sql/dwc_multimedia.sql): This query transforms camtrap-dp image data to a Darwin Core Simple Multimedia extension. Sets of images will appear multiple times if these are used for multiple occurrences.

## Steps

1. Validate data package (optional)

```
$ frictionless validate data/raw/datapackage.json
```

2. Make output directories:

```
$ mkdir data/interim data/processed
```

3. Load data package into sqlite database:

```
$ f2sqlite data/raw/datapackage.json data/interim/camtrap_dp.sqlite3
```

4. Test database connection (see [documentation](https://sqlite.org/cli.html)):

```
$ sqlite3
sqlite> .open data/interim/camtrap_dp.sqlite3
sqlite> SELECT COUNT(*) FROM observations;
828
```

5. Convert data to Darwin Core:

```
sqlite> .headers on
sqlite> .mode csv
sqlite> .once data/processed/dwc_occurrence.csv
sqlite> .read sql/dwc_occurrence.sql
sqlite> .once data/processed/dwc_multimedia.csv
sqlite> .read sql/dwc_multimedia.sql
```

## Example dataset

_MICA - Muskrat and Coypu_ is a camera trap dataset created by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en) and published on Zenodo (Cartuyvels et al. 2021, https://doi.org/10.5281/zenodo.4893243). It contains deployments, media and observations data formatted as a [Camtrap DP](https://tdwg.github.io/camtrap-dp/). A small sample of the dataset is [deposited in this repository](data/raw) to showcase the transformation.

- [`datapackage.json`](data/raw/datapackage.json): describes the dataset and follows the [Camtrap DP metadata schema](https://tdwg.github.io/camtrap-dp/metadata/).
- [data/processed](data/processed): resulting Darwin Core data.

This dataset is published to GBIF at <https://doi.org/10.15468/5tb6ze>. It uses the conversion presented above, to then add/change some Darwin Core terms in [this R Markdown script](https://github.com/inbo/mica-occurrences/blob/master/datasets/mica-agouti-occurrences/src/dwc_mapping.Rmd).
