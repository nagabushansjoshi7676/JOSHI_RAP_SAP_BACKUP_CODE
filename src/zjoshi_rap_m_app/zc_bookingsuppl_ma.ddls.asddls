@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection_BookingSupplement'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKINGSUPPL_MA
  as projection on ZI_BOOKINGSUPPL_MA
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplementDesc' ]
      SupplementId,
      _Supplementtext.Description as SupplementDesc : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZC_BOOKING_MA,
      _Supplement,
      _Supplementtext,
      _Travel  : redirected to ZC_TRAVEL_MA
}
