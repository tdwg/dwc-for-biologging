/*
Created by Peter Desmet (INBO)

This query transforms Movebank GPS data to Darwin Core MachineObservation occurrence data. The data 
are subsampled, only keeping the first record for each hour (indicated in dataGeneralizations). The 
eventID (tag-id/animal-id) allows to group deployment and gps occurrences as events.

Static Darwin Core values are marked with FIXED VALUE.

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
individual-local-identifier             Y: as part of eventID
study-name                              Y

REFERENCE DATA (JOINED)

animal_nickname                         Y

*/

SELECT
-- occurrenceID                         Unique record ID for gps measurement in Movebank
  gps."event-id" AS "occurrenceID",

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
-- datasetName
  gps."study-name" AS "datasetName",
-- ownerInstitutionCode
-- basisOfRecord                        FIXED VALUE
  'MachineObservation' AS "basisOfRecord",
-- informationWithheld
-- dataGeneralizations
  'subsampled by hour: first of ' || gps."subsample-count" || ' records' AS "dataGeneralizations",
-- dynamicProperties

-- MATERIALSAMPLE
-- Not applicable

-- OCCURRENCE
-- occurrenceID                         Added as first field
-- catalogNumber
-- occurrenceRemarks
-- recordNumber
-- recordedBy
-- recordedByID
-- individualCount
-- organismQuantity
-- organismQuantityType
-- sex                                  Determined at deployment start, not extended to gps records
-- lifeStage                            Determined at deployment start, not extended to gps records
-- reproductiveCondition                Determined at deployment start, not extended to gps records
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
  ref."animal-id" AS "organismID",
-- organismName
  ref."animal-nickname" AS "organismName",
-- organismScope
-- associatedOccurrences
-- associatedOrganisms
-- previousIdentifications
-- organismRemarks

-- EVENT
-- eventID                              Combination of tag-id:animal-id
  ref."tag-id" ||  '-' || ref."animal-id" AS "eventID",
-- parentEventID
-- samplingProtocol
  gps."sensor-type" AS "samplingProtocol",
-- sampleSizeValue
-- sampleSizeUnit
-- samplingEffort
-- eventDate                            ISO-8601 in UTC
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', gps."timestamp") AS "eventDate",
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
  gps."height-above-msl" AS "minimumDistanceAboveSurfaceInMeters",
-- maximumDistanceAboveSurfaceInMeters  Same as minimumDistanceAboveSurfaceInMeters
-- locationAccordingTo
-- locationRemarks
-- verbatimCoordinates
-- verbatimLatitude
-- verbatimLongitude
-- verbatimCoordinateSystem
-- verbatimSRS
-- decimalLatitude
  gps."location-lat" AS "decimalLatitude",
-- decimalLongitude
  gps."location-long" AS "decimalLongitude",
-- geodeticDatum                        FIXED VALUE
  'WGS84' AS "geodeticDatum",
-- coordinateUncertaintyInMeters
  gps."location-error-numerical" AS "coordinateUncertaintyInMeters",
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
  ref."animal-taxon" AS "scientificName",
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
-- taxonRank                            Not in source data: could be species or subspecies
-- verbatimTaxonRank
-- scientificNameAuthorship
-- vernacularName
-- nomenclaturalCode
-- taxonomicStatus
-- nomenclaturalStatus
-- taxonRemarks

FROM
  (
    SELECT
      *,
      COUNT(*) AS "subsample-count"
    FROM gps
    WHERE
      visible = 1
      AND "import-marked-outlier" IS FALSE
      AND "manually-marked-outlier" IS FALSE
    GROUP BY
    -- Group by date+hour
      STRFTIME('%Y-%m-%dT%H', "timestamp")
    HAVING
    -- Take first record within group. timestamps are assumed to be ordered chronologically
      ROWID = MIN(ROWID)
  ) AS gps

  LEFT JOIN reference_data AS ref
  ON
    gps."tag-local-identifier" = ref."tag-id"
    AND gps."individual-local-identifier" = ref."animal-id"
