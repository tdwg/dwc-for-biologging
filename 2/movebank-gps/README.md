# Movebank GPS data

Lossy transformation to Darwin Core of GPS tracking data formatted in the [Movebank Attribute Dictionary](https://www.movebank.org/node/2381), to enable indexing by GBIF/OBIS.

## Transformation

Data are mapped as an **Occurrence core**, with for each tracked animal a Human Observation (for the deployment start when the tag was attached) and a number of Machine Observations (sampled-down GPS positions). These records share the same `organismID` and `eventID` (i.e. the deployment). An Event core was not used, as there is no location or time information to group by, and all associated information applies to the individual when it was tagged (i.e. an occurrence).

- [`dwc_occurrence_deployment`](sql/dwc_occurrence_deployment.sql): This query transforms Movebank reference data to a Darwin Core Occurrence core (Human Observations). Only the deployment start (`deploy-on`) information is used, when life stage, etc. are often determined, not deployment end (`deploy-off`), which is often arbitrarily set to end a deployment. The `eventID` (`tag-id`/`animal-id`) allows to group deployment and gps occurrences as events.
- [`dwc_occurrence_gps`](sql/dwc_occurrence_gps.sql): This query transforms Movebank GPS data to a Darwin Core Occurrence core (Machine Observations). The data are subsampled, only keeping the first record for each hour (indicated in `dataGeneralizations`). Properties determined at the deployment start (`sex`, `lifeStage`) are not associated with these records, as they were not recorded by the tag and might change over time. The `eventID` (`tag-id`/`animal-id`) allows to group deployment and gps occurrences as events.

## Steps

1. Validate data package (optional):

```
$ frictionless validate data/raw/datapackage.json
```

2. Make output directories:

```
$ mkdir data/interim data/processed
```

3. Load data package into sqlite database:

```
$ f2sqlite data/raw/datapackage.json data/interim/movebank_gps.sqlite3
```

4. Test database connection (see [documentation](https://sqlite.org/cli.html)):

```
$ sqlite3
sqlite> .open data/interim/movebank_gps.sqlite3
sqlite> SELECT COUNT(*) FROM gps;
478274
```

5. Convert data to Darwin Core:

```
sqlite> .headers on
sqlite> .mode csv
sqlite> .once data/processed/dwc_occurrence_deployment.csv
sqlite> .read sql/dwc_occurrence_deployment.sql
sqlite> .once data/processed/dwc_occurrence_gps.csv
sqlite> .read sql/dwc_occurrence_gps.sql
```

## Example dataset

_LBBG_ZEEBRUGGE - Lesser black-backed gulls (Larus fuscus, Laridae) breeding at the southern North Sea coast (Belgium and the Netherlands)_ is a [bird tracking dataset published by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en). It contains reference, gps and acceleration data formatted in the [Movebank attribute dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/) and is available as open data on [Zenodo](https://doi.org/10.5281/zenodo.3540799).

- [`datapackage.json`](data/raw/datapackage.json): describes [dataset version 1](https://doi.org/10.5281/zenodo.3540800), but reduced to 2013 reference and gps data.
- [`datapackage.yaml`](data/raw/datapackage.yaml): describes a [dataset  version 2](https://doi.org/10.5281/zenodo.3968687), containing all reference, gps and acceleration data. Will fail because of [list of zipped csvs](https://github.com/frictionlessdata/frictionless-py/issues/444) issue. Note: has additional field `import-marked-outlier`.
- [data/processed](data/processed): resulting Darwin Core data.
