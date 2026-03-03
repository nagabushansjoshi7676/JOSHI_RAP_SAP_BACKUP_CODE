@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection_Booking'
@Metadata.ignorePropagatedAnnotations: true
define  view entity ZC_BOOKING_MA 
as projection on ZI_BOOKING_MA
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _Booking_Status,
    _Carrier,
    _Connection,
    _Customer,
    _Suppl : redirected to composition child ZC_BOOKINGSUPPL_MA,
    _Travel : redirected to parent ZC_TRAVEL_MA 
}
