# Movebank GPS data

## Rationale

Lossy transformation of GPS data formatted in the [Movebank Attribute Dictionary](https://www.movebank.org/node/2381) to Darwin Core that can be indexed by GBIF.

## Example dataset

_LBBG_ZEEBRUGGE - Lesser black-backed gulls (Larus fuscus, Laridae) breeding at the southern North Sea coast (Belgium and the Netherlands)_ is a [bird tracking dataset published by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en). It contains reference, gps and acceleration data formatted in the [Movebank attribute dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/) and is available as open data on [Zenodo](https://doi.org/10.5281/zenodo.3540799).

Two data packages were made to describe the data:

- [`datapackage.json`](data/raw/datapackage.json): test data package, containing 2013 reference and gps data (without `import-marked-outlier`) for [dataset v1](https://doi.org/10.5281/zenodo.3540800).
- [`datapackage.yaml`](data/raw/datapackage.yaml): production data package containing all reference, gps and acceleration data for [dataset v2](https://doi.org/10.5281/zenodo.3968687). Will fail because of [list of zipped csvs](https://github.com/frictionlessdata/frictionless-py/issues/444) issue.

## Transformation

1. Validate data package (optional)

```
$ frictionless validate data/raw/datapackage.json
```

2. Load data package into sqlite database:

```
$ f2sqlite data/raw/datapackage.json data/interim/movebank_gps.sqlite3
```

3. Test database connection (see [documentation](https://sqlite.org/cli.html)):

```
$ sqlite3
sqlite> .open data/interim/movebank_gps.sqlite3
sqlite> SELECT COUNT(*) FROM gps;
478274
```

4. Convert GPS data to Darwin Core

```
sqlite> .headers on
sqlite> .mode csv
sqlite> .once data/processed/occurrence_gps.csv
sqlite> .read sql/dwc_occurrence_gps.sql
```
