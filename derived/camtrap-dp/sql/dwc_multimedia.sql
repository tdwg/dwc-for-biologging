/*
Created by Peter Desmet (INBO)

Based on https://rs.gbif.org/extension/gbif/1.0/multimedia.xml
Static Darwin Core values are marked with FIXED VALUE.

MEDIA

multimedia_id                           Y: as link to observation
deployment_id                           N: included at observation level
sequence_id                             Y: as link to observation
timestamp                               Y
file_path                               Y
file_name                               N
file_mediatype                          Y
exif_data                               N
favourite                               N
comments                                N
_id                                     N

*/

-- Observations can be based on sequences (sequence_id) or individual files (multimedia_id)
-- Make two joins and union to capture both cases
WITH obs_multimedia AS (
-- Sequence based observations
  SELECT
    obs."observation_id",
    mm.*
  FROM
    observations AS obs
    LEFT JOIN
      multimedia AS mm
      ON obs."sequence_id" = mm."sequence_id"
  WHERE
    obs."multimedia_id" IS NULL
    AND obs."observation_type" = 'animal'
  UNION
-- Multimedia based observations
  SELECT
    obs."observation_id",
    mm.*
  FROM
    observations AS obs
    LEFT JOIN
      multimedia AS mm
      ON obs."multimedia_id" = mm."multimedia_id"
  WHERE
    obs."multimedia_id" IS NOT NULL
    AND obs."observation_type" = 'animal'
)

SELECT
-- occurrenceID
  obs_mm."observation_id" AS "occurrenceID",
-- type
  CASE
    WHEN obs_mm."file_mediatype" LIKE '%video%' THEN 'MovingImage'
    ELSE 'StillImage'
  END AS "type",
-- format
  obs_mm."file_mediatype" AS "format",
-- identifier
  obs_mm."file_path" AS "identifier",
-- references
-- title
-- description
-- created
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', obs_mm."timestamp") AS "created"
-- creator
-- contributor
-- publisher
-- audience
-- source
-- license                              Only available in dataset metadata
-- rightsHolder                         Only available in dataset metadata
-- datasetID                            Only available in dataset metadata

FROM
  obs_multimedia AS obs_mm

ORDER BY
-- Order is not retained in obs_multimedia, so important to sort
  obs_mm."observation_id",
  obs_mm."timestamp",
  obs_mm."file_name"
