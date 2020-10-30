/*
Created by Peter Desmet (INBO)

This query transforms camtrap-dp observation data to a Darwin Core Occurrence core (Machine 
Observations). This allows to link occurrences to images in a Multimedia extension, which would not 
be possible if there already was an Event core. As a result, deployment start/end information is 
not included.

Static Darwin Core values are marked with FIXED VALUE.

DEPLOYMENTS

deployment_id                           Y
location_id                             Y
location_name                           Y
longitude                               Y
latitude                                Y
start                                   N: Observation timestamp is used instead
end                                     N: Observation timestamp is used instead
setup_by                                N
camera_id                               N
camera_model                            N
camera_interval                         N
camera_height                           N
tags                                    Y
comments                                Y

OBSERVATIONS

observation_id                          Y
deployment_id                           Y
sequence_id                             N: Only deployments are retained as Events in Darwin Core
media_id                                N
timestamp                               Y
observation_type                        Y: as filter
scientific_name                         Y
vernacular_name                         Y
count                                   Y
age                                     Y
sex                                     Y
individual_id                           Y
classification_method                   Y
classified_by                           Y
classification_date                     Y
classification_confidence               Y
comments                                Y

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
-- samplingProtocol                     FIXED VALUE
  'camera trap' AS "samplingProtocol",
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
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', obs."classification_date") AS "dateIdentified",
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
-- taxonID
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
-- kingdom                              FIXED VALUE: assumed 'Animalia' for all data
  'Animalia' AS "kingdom",
-- phylum
-- class
-- order
-- family
-- genus
-- subgenus
-- specificEpithet
-- infraspecificEpithet
-- taxonRank                            Not in source data: could be species or subspecies
-- verbatimTaxonRank
-- scientificNameAuthorship
-- vernacularName
  obs."vernacular_name" AS "vernacularName"
-- nomenclaturalCode
-- taxonomicStatus
-- nomenclaturalStatus
-- taxonRemarks

FROM
  observations AS obs

  LEFT JOIN deployments AS dep
  ON
    obs."deployment_id" = dep."deployment_id"

WHERE
  -- Select biological observations only (excluding observations marked as human, empty, vehicle)
  -- Same filter should be used in dwc_multimedia.sql!
  obs."observation_type" = 'animal'
