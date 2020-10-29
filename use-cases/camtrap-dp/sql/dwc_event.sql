/*
Created by Peter Desmet (INBO)

This query transforms camtrap-dp deployment data to Darwin Core event data, as an Event core.

Static Darwin Core values are marked with FIXED VALUE.

DEPLOYMENTS

deployment_id                           Y
location_id                             Y
location_name                           Y
longitude                               Y
latitude                                Y
start                                   Y
end                                     Y
setup_by                                N
camera_id                               N
camera_model                            N
camera_interval                         N
camera_height                           N
tags                                    Y
comments                                Y

*/

SELECT
-- eventID
  dep."deployment_id" AS "eventID",

-- RECORD-LEVEL
-- type                                 FIXED VALUE
  'Event' AS "type",
-- modified
-- language
-- license                              Only available in dataset metadata
-- rightsHolder                         Only available in dataset metadata
-- accessRights
-- bibliographicCitation
-- references
-- institutionID
-- collectionID
-- datasetID                            Only available in dataset metadata
-- institutionCode
-- datasetName                          Only available in dataset metadata
-- ownerInstitutionCode
-- dataGeneralizations
-- dynamicProperties

-- EVENT
-- eventID                              Added as first field
-- parentEventID
-- samplingProtocol                     FIXED VALUE
  'camera trap' AS "samplingProtocol",
-- sampleSizeValue
-- sampleSizeUnit
-- samplingEffort
-- eventDate                            Deployment start/end in ISO-8601 UTC
  CASE
    WHEN "end" IS NOT NULL THEN STRFTIME('%Y-%m-%dT%H:%M:%SZ', dep."start") || "/" || STRFTIME('%Y-%m-%dT%H:%M:%SZ', dep."end")
    ELSE STRFTIME('%Y-%m-%dT%H:%M:%SZ', dep."start")
  END AS "eventDate",
-- eventTime                            Included in eventDate
-- startDayOfYear
-- endDayOfYear
-- year
-- month
-- day
-- verbatimEventDate
-- habitat
-- fieldNumber
-- fieldNotes
-- eventRemarks
  CASE
    WHEN dep."comments" IS NOT NULL AND dep."tags" IS NOT NULL THEN dep."comments" || ' | tags: ' || dep."tags"
    WHEN dep."tags" IS NOT NULL THEN 'tags: ' || dep."tags"
    ELSE dep."comments"
  END AS "eventRemarks",
-- LOCATION
-- locationID
  dep."location_id" AS "locationID",
-- higherGeographyID
-- higherGeography
-- continent
-- waterBody
-- islandGroup
-- island
-- country
-- countryCode
-- stateProvince
-- county
-- municipality
-- locality
  dep."location_name" AS "locality",
-- verbatimLocality
-- verbatimElevation
-- minimumElevationInMeters
-- maximumElevationInMeters
-- verbatimDepth
-- minimumDepthInMeters
-- maximumDepthInMeters
-- minimumDistanceAboveSurfaceInMeters
-- maximumDistanceAboveSurfaceInMeters
-- locationAccordingTo
-- locationRemarks
-- verbatimCoordinates
-- verbatimLatitude
-- verbatimLongitude
-- verbatimCoordinateSystem
-- verbatimSRS
-- decimalLatitude
  dep."latitude" AS "decimalLatitude",
-- decimalLongitude
  dep."longitude" AS "decimalLongitude",
-- geodeticDatum                        FIXED VALUE
  'WGS84' AS "geodeticDatum"
-- coordinateUncertaintyInMeters
-- coordinatePrecision
-- pointRadiusSpatialFit
-- footprintWKT
-- footprintSRS
-- footprintSpatialFit
-- georeferencedBy
-- georeferencedDate
-- georeferenceProtocol
-- georeferenceSources
-- georeferenceVerificationStatus
-- georeferenceRemarks

-- GEOLOGICAL CONTEXT
-- Not applicable

FROM
  deployments AS dep
