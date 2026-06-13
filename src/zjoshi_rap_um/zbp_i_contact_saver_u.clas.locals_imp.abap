CLASS lsc_ZI_CONTACT_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_CONTACT_U IMPLEMENTATION.

  METHOD finalize.
    zcl_aux_contact_u=>get_instance(  )->finalize_contact(  ).
  ENDMETHOD.

  METHOD check_before_save.

    "perform validations before saving contact data

    DATA : ls_reported LIKE LINE OF reported-zi_contact_u.

    zcl_aux_contact_u=>get_instance(  )->check_before_save_contact(
      IMPORTING
        et_message = DATA(lt_message)
    ).

    "send error message to front end

    reported-zi_contact_u = VALUE #( ( %state_area = 'ST_ERROR' ) ).

    LOOP AT lt_message INTO DATA(ls_message).

      failed-zi_contact_u = VALUE #( BASE failed-zi_contact_u
                                    ( contactid = ls_message-msgv2 ) ).
      CLEAR : ls_reported.
      ls_reported-%state_area = 'ST_ERROR'.

      CASE ls_message-msgv1.
        WHEN 'FirstName'.
          ls_reported-%element-firstname = if_abap_behv=>mk-on.
        WHEN 'LastName'.
          ls_reported-%element-lastname = if_abap_behv=>mk-on.
        WHEN 'Telephone'.
          ls_reported-%element-telephone = if_abap_behv=>mk-on.
      ENDCASE.

      ls_reported-contactid = ls_message-msgv2.
      ls_reported-%msg = new_message_with_text(
                           severity = if_abap_behv_message=>severity-error
                           text     = ls_message-msgv3
                         ).
      reported-zi_contact_u = VALUE #( BASE reported-zi_contact_u ( ls_reported ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD adjust_numbers.

    zcl_aux_contact_u=>get_instance(  )->adjust_number_contact(
        RECEIVING
          rt_contact_mapping = DATA(lt_contact_mapping)
      ).
    mapped-zi_contact_u = VALUE #( FOR lwa_contact_mapping IN lt_contact_mapping
                              ( %tmp = VALUE #( contactid = lwa_contact_mapping-preliminary-contact_id )
                                ContactId = lwa_contact_mapping-final-contact_id )
                               ).

    zcl_aux_contact_u=>get_instance(  )->adjust_number_address(
      IMPORTING
        rt_contaddr_mapping = DATA(lt_contaddr_mapping)
  ).

    mapped-zi_address_u = VALUE #( FOR lwa_contaddr_mapping IN lt_contaddr_mapping
                             ( %tmp = VALUE #( ContactId = lwa_contaddr_mapping-preliminary-contact_id
                                   AddressId = lwa_contaddr_mapping-preliminary-address_id
                                   AddressSr = lwa_contaddr_mapping-preliminary-address_sr )

                                   ContactId = lwa_contaddr_mapping-final-contact_id
                                   AddressId = lwa_contaddr_mapping-final-address_id
                                   AddressSr = lwa_contaddr_mapping-final-address_sr
                                )
                              ).


  ENDMETHOD.

  METHOD save.
    zcl_aux_contact_u=>get_instance( )->save_contact( ).
    zcl_aux_contact_u=>get_instance( )->save_address( ).

  ENDMETHOD.

  METHOD cleanup.
    zcl_aux_contact_u=>get_instance( )->initialize_contact( ).
    zcl_aux_contact_u=>get_instance( )->initialize_address(  ).
  ENDMETHOD.

  METHOD cleanup_finalize.

    zcl_aux_contact_u=>get_instance( )->initialize_contact( ).
    zcl_aux_contact_u=>get_instance( )->initialize_address(  ).

  ENDMETHOD.

ENDCLASS.
