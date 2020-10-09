# Movebank GPS data

## Rationale

Lossy transformation of GPS data formatted in the [Movebank Attribute Dictionary](https://www.movebank.org/node/2381) to Darwin Core that can be indexed by GBIF.

## Example dataset

_LBBG_ZEEBRUGGE - Lesser black-backed gulls (Larus fuscus, Laridae) breeding at the southern North Sea coast (Belgium and the Netherlands)_ is a [bird tracking dataset published by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en). It contains reference, gps and acceleration data formatted in the [Movebank attribute dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/) and is available as open data on [Zenodo](https://doi.org/10.5281/zenodo.3540799).

Two data packages were made to describe the data:

- [`datapackage.json`](data/raw/datapackage.json): test data package, containing 2013 reference and gps data (without `import-marked-outlier`) for [dataset v1](https://doi.org/10.5281/zenodo.3540800).
- [`datapackage.yaml`](data/raw/datapackage.yaml): production data package containing all reference, gps and acceleration data for [dataset v2](https://doi.org/10.5281/zenodo.3968687). Will fail because of [list of zipped csvs](https://github.com/frictionlessdata/frictionless-py/issues/444) issue.


Goal:

1. Make the dataset a valid [Frictionless Tabular Data Package](https://specs.frictionlessdata.io/tabular-data-package/) by adding a `datapackage.json`. As long as this is a work in progress, the file will be added to this repository rather than it being part of the dataset.
2. Read the dataset as a Data Package.
3. Write code/documentation to convert the dataset to Darwin Core. This conversion will be lossy: losing columns (e.g. deployment & tag fields) and rows (e.g. subsampling by hour). The original data remains available on Zenodo.
4. Save the converted data as a staging dataset that can be reviewed/indexed as Darwin Core by GBIF and others. This staging dataset will also be a Data Package.
5. Review the conversion by members of the Machine Observation group and adapt where necessary.
