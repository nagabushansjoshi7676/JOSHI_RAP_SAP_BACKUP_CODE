@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Address projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_CONt_ADDRESS
  as projection on ZI_Address_U
{
  key ContactId,
  key AddressId,
  key AddressSr,
      Addr1,
      Addr2,
      City,
      State,
      Pincode,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Contact : redirected to parent ZC_CONTACT
}
