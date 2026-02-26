@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for airport id'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_FIAIRPORT_VH
  as select from /dmo/airport
{
      @Search.defaultSearchElement: true // provide search bar to acces all fields//
  key airport_id as AirportId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      name       as Name,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      city       as City,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      country    as Country
}
