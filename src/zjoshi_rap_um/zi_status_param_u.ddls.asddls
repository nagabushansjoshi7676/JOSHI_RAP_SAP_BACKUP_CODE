@EndUserText.label: 'Parameter'
@Metadata.allowExtensions: true
define abstract entity ZI_STATUS_PARAM_U
{

  @UI.defaultValue: 'X'
  @EndUserText.label: 'Active'
  active    : abap_boolean;

  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCE_ENTITY : Telephone' )
  @EndUserText.label: 'Telephone'
  telephone : abap.numc(10);

}
