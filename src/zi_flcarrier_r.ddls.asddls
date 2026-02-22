@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Refernece of Carrier'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_FLCARRIER_R
  as select from /dmo/carrier
{
  key carrier_id    as CarrierId,
      @Semantics.text: true //need to have connection in the fisrt cds view//
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8  // funzziness helps to search by starting single latter //
      name          as Name,
      currency_code as CurrencyCode
}
