# Camera trap data

## Rationale

Lossy transformation of camera trap data formatted as a [Camtrap Data Package](https://gitlab.com/oscf/camtrap-package-schemas) to Darwin Core that can be indexed by GBIF.

## Example dataset

_Agouti export for Monitoring Faunabeheerzone 8_ is a camera trap dataset created by the [Research Institute for Nature and Forest (INBO)](https://www.inbo.be/en). It contains deployments, media and observations data formatted as a [Camtrap Data Package](https://gitlab.com/oscf/camtrap-package-schemas) and a small sample is [deposited in this repository](data/raw).

Data package that describes the data:

- [`datapackage.json`](data/raw/datapackage.json): follows the [Camtrap DP schema](https://gitlab.com/oscf/camtrap-package-schemas/-/blob/master/camtrap-package-profile.json).

## Transformation

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
1367
```
