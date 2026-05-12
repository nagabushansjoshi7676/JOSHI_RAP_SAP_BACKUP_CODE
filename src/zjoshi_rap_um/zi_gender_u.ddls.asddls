@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gender'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_GENDER_U
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name:'ZJO_DO_GENDER' )
{
  key domain_name,
  key value_position,
      @Semantics.language: true
  key language,
      @ObjectModel.text.element: [ 'GenderText' ]
      value_low as GenderCode,
      text      as GenderText
}
