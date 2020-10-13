# Movebank GPS data

## Rationale

Lossy transformation of GPS data formatted in the [Movebank Attribute Dictionary](https://www.movebank.org/node/2381) to Darwin Core that can be indexed by GBIF.

## Example dataset

_LBBG_ZEEBRUGGE - Lesser black-backed gulls (Larus fuscus, Laridae) breeding at the southern North Sea coast (Belgium and the Netherlands)_ is a [bird tracking dataset published by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en). It contains reference, gps and acceleration data formatted in the [Movebank attribute dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/) and is available as open data on [Zenodo](https://doi.org/10.5281/zenodo.3540799).

Important files:

- [`datapackage.json`](data/raw/datapackage.json): describes [dataset version 1](https://doi.org/10.5281/zenodo.3540800), but reduced to 2013 reference and gps data.
- [`datapackage.yaml`](data/raw/datapackage.yaml): describes a [dataset  version 2](https://doi.org/10.5281/zenodo.3968687), containing all reference, gps and acceleration data. Will fail because of [list of zipped csvs](https://github.com/frictionlessdata/frictionless-py/issues/444) issue. Note: has additional field `import-marked-outlier`.
- [sql](sql): documented transformations to Darwin Core.

## Transformation

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

5. Convert GPS data to Darwin Core

```
sqlite> .headers on
sqlite> .mode csv
sqlite> .once data/processed/occurrence_gps.csv
sqlite> .read sql/dwc_occurrence_gps.sql
```
