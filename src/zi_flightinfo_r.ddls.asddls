@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Information'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_FLIGHTINFO_R
  as select from /dmo/flight
  association [1] to ZI_FLCARRIER_R as _Airline on $projection.CarrierId = _Airline.CarrierId
{
      @UI.lineItem: [{ position: 10 }] 
      @ObjectModel.text.association: '_Airline'
      @Search.defaultSearchElement: true
  key carrier_id     as CarrierId,
      @UI.lineItem: [{ position: 20 }]
      @Search.defaultSearchElement: true
  key connection_id  as ConnectionId,
      @UI.lineItem: [{ position: 30 }]
      @Search.defaultSearchElement: true
  key flight_date    as FlightDate,
      @UI.lineItem: [{ position: 40 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @Search.defaultSearchElement: true
      price          as Price,
      @UI.lineItem: [{ position: 50 }]
      @Search.defaultSearchElement: true
      currency_code  as CurrencyCode,
      @UI.lineItem: [{ position: 60 }]
      @Search.defaultSearchElement: true
      plane_type_id  as PlaneTypeId,
      @UI.lineItem: [{ position: 70 }]
      @Search.defaultSearchElement: true
      seats_max      as SeatsMax,
      @UI.lineItem: [{ position: 80 }]
      @Search.defaultSearchElement: true
      seats_occupied as SeatsOccupied,
      //Association
      _Airline
}
