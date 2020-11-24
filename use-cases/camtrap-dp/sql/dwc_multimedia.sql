/*
Created by Peter Desmet (INBO)

Based on https://rs.gbif.org/extension/gbif/1.0/multimedia.xml
Static Darwin Core values are marked with FIXED VALUE.

MEDIA

media_id                                TODO: add as link to observation for non-sequenced based
deployment_id                           N: included at observation level
sequence_id                             Y: as link to observation
timestamp                               Y
file_path                               Y
file_mediatype                          Y

*/

SELECT
-- occurrenceID
  obs."observation_id" AS "occurrenceID",
-- type
  CASE
    WHEN media."file_mediatype" LIKE '%video%' THEN 'MovingImage'
    ELSE 'StillImage'
  END AS "type",
-- format
  media."file_mediatype" AS "format",
-- identifier
  media."file_path" AS "identifier",
-- references
-- title
-- description
-- created
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', media."timestamp") AS "created"
-- creator
-- contributor
-- publisher
-- audience
-- source
-- license                              Only available in dataset metadata
-- rightsHolder                         Only available in dataset metadata
-- datasetID                            Only available in dataset metadata

FROM
  observations AS obs
  LEFT JOIN media as media
  ON
    obs."sequence_id" = media."sequence_id"

WHERE
  obs."observation_type" = 'animal'
