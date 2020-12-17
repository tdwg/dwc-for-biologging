/*
Created by Peter Desmet (INBO)

Based on https://rs.gbif.org/core/dwc_occurrence_2020-07-15.xml
Static Darwin Core values are marked with FIXED VALUE.

REFERENCE DATA

tag-id                                  Y: as part of eventID
animal-id                               Y
animal-taxon                            Y
deploy-on-date                          Y
deploy-off-date                         N
animal-comments                         Y
animal-death-comments
animal-exact-date-of-birth
animal-latest-date-born
animal-life-stage                       Y
animal-mass                             N
animal-nickname                         Y
animal-reproductive-condition
animal-ring-id                          N
animal-sex                              Y
animal-taxon-detail
attachment-type                         N
behavior-according-to
data-processing-software
deploy-off-latitude
deploy-off-longitude
deploy-off-person
deploy-on-latitude                      Y
deploy-on-longitude                     Y
deploy-on-person
deployment-comments                     Y
deployment-end-comments
deployment-end-type                     N
deployment-id                           Y
duty-cycle
geolocator-calibration
geolocator-light-threshold
geolocator-sensor-comments
geolocator-sun-elevation-angle
habitat-according-to
location-accuracy-comments              N: is regarding the sensor data
manipulation-comments
manipulation-type                       N
study-site                              N
tag-beacon-frequency
tag-comments
tag-failure-comments
tag-manufacturer-name                   N
tag-mass                                N
tag-model
tag-processing-type
tag-production-date
tag-readout-method                      N
tag-serial-no                           N

GPS (JOINED)

study-name                              Y

*/

SELECT
-- occurrenceID                         Unique record ID for deployment in Movebank
  ref."deployment-id" AS "occurrenceID",

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
  gps."study-name" AS "datasetName",
-- ownerInstitutionCode
-- basisOfRecord                        FIXED VALUE
  'HumanObservation' AS "basisOfRecord",
-- dataGeneralizations
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
-- sex
  CASE
    WHEN ref."animal-sex" = "f" THEN "female"
    WHEN ref."animal-sex" = "m" THEN "male"
    ELSE ref."animal-sex"
  END AS "sex",
-- lifeStage
  ref."animal-life-stage" AS "lifeStage",
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
  ref."animal-id" AS "organismID",
-- organismName
  ref."animal-nickname" AS "organismName",
-- organismScope
-- associatedOccurrences
-- associatedOrganisms
-- previousIdentifications
-- organismRemarks
  ref."animal-comments" AS "organismRemarks",

-- EVENT
-- eventID                              Combination of tag-id:animal-id
  ref."tag-id" ||  '-' || ref."animal-id" AS "eventID",
-- parentEventID
-- samplingProtocol                     FIXED VALUE
  'tag deployment' AS "samplingProtocol",
-- sampleSizeValue
-- sampleSizeUnit
-- samplingEffort
-- eventDate                            ISO-8601 in UTC
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', ref."deploy-on-date") AS "eventDate",
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
  ref."deployment-comments" AS eventRemarks,

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
-- maximumDistanceAboveSurfaceInMeters
-- locationAccordingTo
-- locationRemarks
-- verbatimCoordinates
-- verbatimLatitude
-- verbatimLongitude
-- verbatimCoordinateSystem
-- verbatimSRS
-- decimalLatitude
  ref."deploy-on-latitude" AS "decimalLatitude",
-- decimalLongitude
  ref."deploy-on-longitude" AS "decimalLongitude",
-- geodeticDatum                        FIXED VALUE
  'WGS84' AS "geodeticDatum",
-- coordinateUncertaintyInMeters        Not available for deployment lat/long
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
-- taxonRank                            Could be species or subspecies
-- verbatimTaxonRank
-- scientificNameAuthorship
-- vernacularName
-- nomenclaturalCode
-- taxonomicStatus
-- nomenclaturalStatus
-- taxonRemarks

FROM
  reference_data AS ref

  LEFT JOIN (
    SELECT
      *
    FROM gps
    GROUP BY
      "tag-local-identifier",
      "individual-local-identifier"
    HAVING
    -- Take first record within group (only 0 or 1 expected)
      ROWID = MIN(ROWID)
  ) AS gps
    ON ref."tag-id" = gps."tag-local-identifier"
    AND ref."animal-id" = gps."individual-local-identifier"
