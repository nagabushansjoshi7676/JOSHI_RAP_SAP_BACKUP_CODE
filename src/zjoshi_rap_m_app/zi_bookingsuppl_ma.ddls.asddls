@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BookingSupplement'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKINGSUPPL_MA
  as select from zjbooking_supp_m
  //association with some master cds view //
  association [1..1] to /DMO/I_Supplement     as _Supplement     on $projection.SupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText as _Supplementtext on $projection.SupplementId = _Supplementtext.SupplementID

{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      last_changed_at       as LastChangedAt,
      _Supplement,
      _Supplementtext
}
