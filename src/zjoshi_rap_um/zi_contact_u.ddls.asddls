@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface contact'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CONTACT_U
  as select from zjo_contact
  composition [1..*] of ZI_Address_U as _Address
  association [1..*] to ZI_GENDER_U  as _Gender on $projection.Gender = _Gender.GenderCode
{
  key contact_id      as ContactId,
      first_name      as FirstName,
      middle_name     as MiddleName,
      last_name       as LastName,
      gender          as Gender,
      dob             as Dob,
      age             as Age,
      telephone       as Telephone,
      email           as Email,
      active          as Active,
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,
      _Address,
      _Gender
}
