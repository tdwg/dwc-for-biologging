/*
Created by Peter Desmet (INBO)

Based on https://rs.gbif.org/core/dwc_occurrence_2020-07-15.xml
Static Darwin Core values are marked with FIXED VALUE.

DEPLOYMENTS

deployment_id                           Y
location_id                             Y
location_name                           Y
longitude                               Y
latitude                                Y
start                                   N: observation timestamp is used instead
end                                     N: observation timestamp is used instead
setup_by                                N
camera_id                               N
camera_model                            N
camera_interval                         N
camera_height                           N
camera_tilt                             N
camera_heading                          N
timestamp_issues                        N
bait_use                                Y
session                                 N: sessions events (grouping deployments) are not retained
array                                   N
feature_type                            Y
habitat                                 ENABLE
tags                                    Y
comments                                Y
_id                                     N

OBSERVATIONS

observation_id                          Y
deployment_id                           Y
sequence_id                             N: link is made in dwc_multimedia
multimedia_id                           N: link is made in dwc_multimedia
timestamp                               Y
observation_type                        Y: as filter
sensor_method                           Y
camera_setup                            N
scientific_name                         Y
taxon_id                                Y
count                                   Y
count_new                               N: difficult to express
age                                     Y
sex                                     Y
behaviour                               Y
individual_id                           Y
classification_method                   Y
classified_by                           Y
classification_timestamp                Y
classification_confidence               Y
comments                                Y
_id                                     N

*/

SELECT
-- occurrenceID
  obs."observation_id" AS "occurrenceID",

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
-- collectionCode
-- datasetName                          Only available in dataset metadata
-- ownerInstitutionCode
-- basisOfRecord                        FIXED VALUE
  'MachineObservation' AS "basisOfRecord",
-- informationWithheld
-- dataGeneralizations
-- dynamicProperties

-- MATERIALSAMPLE
-- Not applicable

-- OCCURRENCE
-- occurrenceID                         Added as first field
-- catalogNumber
-- occurrenceRemarks
  obs."comments" AS "occurrenceRemarks",
-- recordNumber
-- recordedBy
-- recordedByID
-- individualCount
  obs."count" AS "individualCount",
-- organismQuantity
-- organismQuantityType
-- sex
  obs."sex" AS "sex",
-- lifeStage
  obs."age" AS "lifeStage",
-- reproductiveCondition
-- behavior
  obs."behaviour" AS "behavior",
-- establishmentMeans
-- occurrenceStatus                     FIXED VALUE
  'present' AS "occurrenceStatus",
-- preparations
-- disposition
-- otherCatalogNumbers
-- associatedMedia
-- associatedReferences
-- associatedSequences
-- associatedTaxa

-- ORGANISM
-- organismID
  obs."individual_id" AS "organismID",
-- organismName
-- organismScope
-- associatedOccurrences
-- associatedOrganisms
-- previousIdentifications
-- organismRemarks

-- EVENT
-- eventID
  obs."deployment_id" AS "eventID",
-- parentEventID
-- samplingProtocol
  'camera trap' ||
  CASE
    WHEN obs."sensor_method" IS NOT NULL THEN ' (' || obs."sensor_method" || ')'
    ELSE ''
  END ||
  CASE
    WHEN dep."bait_use" IS 'none' THEN ' without bait'
    WHEN dep."bait_use" IS NOT NULL THEN ' with ' || dep."bait_use" || ' bait'
    ELSE ''
  END AS "samplingProtocol",
-- sampleSizeValue
-- sampleSizeUnit
-- samplingEffort
-- eventDate                            ISO-8601 in UTC
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', obs."timestamp") AS "eventDate",
-- eventTime                            Included in eventDate
-- startDayOfYear
-- endDayOfYear
-- year
-- month
-- day
-- verbatimEventDate
-- habitat
--  dep."habitat" AS habitat,
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
-- countryCode                          Not in source data
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
  dep."feature_type" AS "locationRemarks",
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
  'WGS84' AS "geodeticDatum",
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

-- IDENTIFICATION
-- identificationID
-- identifiedBy
  obs."classified_by" AS "identifiedBy",
-- identifiedByID
-- dateIdentified                       ISO-8601 in UTC
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', obs."classification_timestamp") AS "dateIdentified",
-- identificationReferences
-- identificationRemarks
  CASE
    WHEN obs."classification_method" IS NOT NULL THEN 'classification method: ' || obs."classification_method"
  END AS "identificationRemarks",
-- identificationQualifier
-- identificationVerificationStatus
  obs."classification_confidence" AS "identificationVerificationStatus",
-- typeStatus

-- TAXON
-- taxonID                              The refence for the taxon_ids is only available in dataset metadata
  obs."taxon_id" AS "taxonID",
-- scientificNameID
-- acceptedNameUsageID
-- parentNameUsageID
-- originalNameUsageID
-- nameAccordingToID
-- namePublishedInID
-- taxonConceptID
-- scientificName
  obs."scientific_name" AS "scientificName",
-- acceptedNameUsage
-- parentNameUsage
-- originalNameUsage
-- nameAccordingTo
-- namePublishedIn
-- namePublishedInYear
-- higherClassification
-- kingdom                              FIXED VALUE: in almost all use cases, it is safe to assume all observations are animals, see https://gitlab.com/oscf/camtrap-dp/-/issues/67
  'Animalia' AS "kingdom"
-- phylum
-- class
-- order
-- family
-- genus
-- subgenus
-- specificEpithet
-- infraspecificEpithet
-- taxonRank                            Only available in dataset metadata
-- verbatimTaxonRank
-- scientificNameAuthorship
-- vernacularName                       Only available in dataset metadata
-- nomenclaturalCode
-- taxonomicStatus
-- nomenclaturalStatus
-- taxonRemarks

FROM
  observations AS obs

  LEFT JOIN deployments AS dep
    ON obs."deployment_id" = dep."deployment_id"

WHERE
  -- Select biological observations only (excluding observations marked as human, empty, vehicle)
  -- Same filter should be used in dwc_multimedia.sql!
  obs."observation_type" = 'animal'

ORDER BY
  obs."observation_id"
