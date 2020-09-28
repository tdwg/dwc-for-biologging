## Movebank use case: LBBG_ZEEBRUGGE

_LBBG_ZEEBRUGGE - Lesser black-backed gulls (Larus fuscus, Laridae) breeding at the southern North Sea coast (Belgium and the Netherlands)_ is a bird tracking dataset published by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en). It contains reference, gps and acceleration data formatted in the [Movebank attribute dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/) and is available as open data on Zenodo.

- Dataset: <https://doi.org/10.5281/zenodo.3540799>
- datapackage.json: [datapackage.json](datapackage.json)

Goal:

1. Make the dataset a valid [Frictionless Tabular Data Package](https://specs.frictionlessdata.io/tabular-data-package/) by adding a `datapackage.json`. As long as this is a work in progress, the file will be added to this repository rather than it being part of the dataset.
2. Read the dataset as a Data Package.
3. Write code/documentation to convert the dataset to Darwin Core. This conversion will be lossy: losing columns (e.g. deployment & tag fields) and rows (e.g. subsampling by hour). The original data remains available on Zenodo.
4. Save the converted data as a staging dataset that can be reviewed/indexed as Darwin Core by GBIF and others. This staging dataset will also be a Data Package.
5. Review the conversion by members of the Machine Observation group and adapt where necessary.
