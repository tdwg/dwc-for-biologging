/*
Created by Peter Desmet (INBO)

This query transforms Movebank GPS data to Darwin Core MachineObservation occurrence data.
Data is subsampled, only keeping the first record for each hour. The tag-id-animal-id combination is 
used as eventID for an optional event core. Static Darwin Core values are marked with FIXED VALUE.

GPS
  
event-id                                Y
visible                                 Y: as filter
timestamp                               Y
location-long                           Y
location-lat                            Y
bar:barometric-pressure                 N
external-temperature                    N
gps:dop                                 N
gps:satellite-count                     N
gps-time-to-fix                         N
ground-speed                            N
heading                                 N
height-above-msl                        Y
import-marked-outlier                   Y: as filter
location-error-numerical                Y
manually-marked-outlier                 Y: as filter
vertical-error-numerical                Y
sensor-type                             Y
individual-taxon-canonical-name         Y
tag-local-identifier                    Y
individual-local-identifier             Y
study-name                              Y

*/

SELECT
-- id                                   Unique record id
  "event-id" AS "id",

-- RECORD-LEVEL
-- type                                 FIXED VALUE
  'Event' AS "type",
-- modified
-- language                             FIXED VALUE
  'en' AS "language",
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
-- datasetName
  "study-name" AS "datasetName",
-- ownerInstitutionCode
-- basisOfRecord                        FIXED VALUE
  'MachineObservation' AS "basisOfRecord",
-- informationWithheld
-- dataGeneralizations
  'subsampled by hour: first of ' || count(*) || ' records' AS "dataGeneralizations",
-- dynamicProperties

-- MATERIALSAMPLE
-- Not applicable

-- OCCURRENCE
-- occurrenceID                         Same as id
  "event-id" AS "occurrenceID",
-- catalogNumber
-- occurrenceRemarks
-- recordNumber
-- recordedBy
-- recordedByID
-- individualCount
-- organismQuantity
-- organismQuantityType
-- sex
-- lifeStage
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
  "individual-local-identifier" AS "organismID",
-- organismName
-- organismScope
-- associatedOccurrences
-- associatedOrganisms
-- previousIdentifications
-- organismRemarks

-- EVENT
-- eventID                              Combination of tag-id:animal-id
  "tag-local-identifier" ||  '-' || "individual-local-identifier" AS "eventID",
-- parentEventID
-- samplingProtocol
  "sensor-type" AS "samplingProtocol",
-- sampleSizeValue
-- sampleSizeUnit
-- samplingEffort
-- eventDate                            ISO-8601 in UTC
  STRFTIME('%Y-%m-%dT%H%M%SZ', "timestamp") AS "eventDate",
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

-- LOCATION
-- locationID
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
-- verbatimLocality
-- verbatimElevation
-- minimumElevationInMeters
-- maximumElevationInMeters
-- verbatimDepth
-- minimumDepthInMeters
-- maximumDepthInMeters
-- minimumDistanceAboveSurfaceInMeters
  "height-above-msl" AS "minimumDistanceAboveSurfaceInMeters",
-- maximumDistanceAboveSurfaceInMeters
-- locationAccordingTo
-- locationRemarks
-- verbatimCoordinates
-- verbatimLatitude
-- verbatimLongitude
-- verbatimCoordinateSystem
-- verbatimSRS
-- decimalLatitude
  "location-lat" AS "decimalLatitude",
-- decimalLongitude
  "location-long" AS "decimalLongitude",
-- geodeticDatum                        FIXED VALUE
  'WGS84' AS "geodeticDatum",
-- coordinateUncertaintyInMeters
  "location-error-numerical" AS "coordinateUncertaintyInMeters",
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
-- identifiedByID
-- dateIdentified
-- identificationReferences
-- identificationRemarks
-- identificationQualifier
-- identificationVerificationStatus
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
  "individual-taxon-canonical-name" AS "scientificName",
-- acceptedNameUsage
-- parentNameUsage
-- originalNameUsage
-- nameAccordingTo
-- namePublishedIn
-- namePublishedInYear
-- higherClassification
-- kingdom                              FIXED VALUE: assumed 'Animalia' for all data
  'Animalia' AS "kingdom"
-- phylum
-- class
-- order
-- family
-- genus
-- subgenus
-- specificEpithet
-- infraspecificEpithet
-- taxonRank                            Could be species or subspecies
-- verbatimTaxonRank
-- scientificNameAuthorship
-- vernacularName
-- nomenclaturalCode
-- taxonomicStatus
-- nomenclaturalStatus
-- taxonRemarks

FROM
  gps

WHERE
  visible = 1
  AND "import-marked-outlier" IS FALSE
  AND "manually-marked-outlier" IS FALSE

GROUP BY
-- Group by date+hour
  STRFTIME('%Y-%m-%dT%H', "timestamp")

HAVING
-- Take first row within group. timestamps are assumed to be ordered chronologically
  ROWID = MIN(ROWID)
