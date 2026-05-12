@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Contact'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_CONTACT
  provider contract transactional_query
  as projection on ZI_CONTACT_U
{
  key ContactId,
      FirstName,
      MiddleName,
      LastName,
      //      @ObjectModel.text.association: '_Gender'
      Gender,
      Dob,
      Age,
      Telephone,
      Email,
      Active,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Gender,
      _Address : redirected to composition child ZC_CONt_ADDRESS
}
