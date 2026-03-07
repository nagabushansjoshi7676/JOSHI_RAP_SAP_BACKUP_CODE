@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection_travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_MA
  provider contract transactional_query
  as projection on ZI_TRAVEL_MA

{
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ] // it is abap annotation can't use in metedata ext provide full name with id ex : JD(101).//
      AgencyId,
      _Agency.Name                      as AgencyName,
      @ObjectModel.text.element: [ 'Customername' ]
      CustomerId,
      _Customer.LastName                as Customername,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'overalltext' ]
      OverallStatus,
      _Status._OverallStatus._Text.Text as overalltext : localized, // so it will consider our lanaguege which we have used
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
