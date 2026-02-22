@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Connection Cds View Model'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo : {
   typeName: 'Connection',
   typeNamePlural: 'Connections' }
@Search.searchable: true // add search bar on top of report//

define view entity ZI_FLCONNECTION
  as select from /dmo/connection as Connection
  association [1..*] to ZI_FLIGHTINFO_R as _Flight  on  $projection.CarrierId    = _Flight.CarrierId
                                                    and $projection.ConnectionId = _Flight.ConnectionId

  association [1]    to ZI_FLCARRIER_R  as _Airline on  $projection.CarrierId = _Airline.CarrierId
{
      @UI.facet: [{ id : 'Connection',
                    purpose: #STANDARD,
                    type: #IDENTIFICATION_REFERENCE,
                    position: 10,
                    label: 'Connection_Details'},
                    { id : 'Flight',
                    purpose: #STANDARD,
                    type: #LINEITEM_REFERENCE,
                    position: 20,
                    label: 'Flight',
                    targetElement: '_Flight'
      }]
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10, label: 'Airline'}]
      //      @ObjectModel.text.element: [ 'ArrivalTime' ] // provide name for field to get understood by user , element used when field
      //    should be there within cds //
      @ObjectModel.text.association: '_Airline' //if field is in association that time use association and need to assigin semntic
      // annotaion for the name field in that association cds view //
      @Search.defaultSearchElement: true // search hep will be applicable for the particular field//
  key carrier_id      as CarrierId,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @Search.defaultSearchElement: true
  key connection_id   as ConnectionId,
      @UI.selectionField: [{ position: 10  }]
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @Search.defaultSearchElement: true
      airport_from_id as AirportFromId,
      @UI.selectionField: [{ position: 20  }]
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      @Search.defaultSearchElement: true
      airport_to_id   as AirportToId,
      @UI.lineItem: [{ position: 50, label: 'DepartureTime'}]
      @UI.identification: [{ position: 50 }]
      @Search.defaultSearchElement: true
      departure_time  as DepartureTime,
      @UI.lineItem: [{ position: 60, label: 'ArrivalTime' }]
      @UI.identification: [{ position: 60 }]
      @Search.defaultSearchElement: true
      arrival_time    as ArrivalTime,
      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      @UI.identification: [{ position: 70 }]
      @Search.defaultSearchElement: true
      distance        as Distance,
      distance_unit   as DistanceUnit,
      // Association
      @Search.defaultSearchElement: true
      _Flight,
      @Search.defaultSearchElement: true
      _Airline

}
