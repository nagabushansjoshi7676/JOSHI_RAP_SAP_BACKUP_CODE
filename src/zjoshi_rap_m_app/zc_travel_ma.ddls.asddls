@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection_travel'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_TRAVEL_MA
  provider contract transactional_query
  as projection on ZI_TRAVEL_MA

{
  key TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_MA,
      _Currency,
      _Customer,
      _Status
}
