@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection_Booking'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_MA
  as projection on ZI_BOOKING_MA
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'Customername' ]
      CustomerId,
      _Customer.LastName         as Customername,
      @ObjectModel.text.element: [ 'Carriername' ] // merge both id and name //
      CarrierId,
      _Carrier.Name              as Carriername,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'Bookingstatustext' ]
      BookingStatus,
      _Booking_Status._Text.Text as Bookingstatustext : localized,
      LastChangedAt,
      /* Associations */
      _Booking_Status,
      _Carrier,
      _Connection,
      _Customer,
      _Suppl  : redirected to composition child ZC_BOOKINGSUPPL_MA,
      _Travel : redirected to parent ZC_TRAVEL_MA
}
