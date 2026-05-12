@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Conatct Address'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_Address_U as select from zjo_cont_address
 association to parent ZI_CONTACT_U as _Contact 
  on $projection.ContactId = _Contact.ContactId
{
    key contact_id as ContactId,
    key address_id as AddressId,
    key address_sr as AddressSr,
    addr1 as Addr1,
    addr2 as Addr2,
    city as City,
    state as State,
    pincode as Pincode,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt,
    _Contact
}
