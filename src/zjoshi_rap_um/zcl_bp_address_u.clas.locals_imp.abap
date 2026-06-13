CLASS lhc_ZI_Address_U DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE ZI_Address_U.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE ZI_Address_U.

    METHODS read FOR READ
      IMPORTING keys FOR READ ZI_Address_U RESULT result.

    METHODS rba_Contact FOR READ
      IMPORTING keys_rba FOR READ ZI_Address_U\_Contact FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_ZI_Address_U IMPLEMENTATION.

  METHOD update.

    DATA : lt_address  TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           lt_addressx TYPE zcl_aux_contact_u=>gtt_contaddr_intx.

    lt_address = VALUE #(
        FOR lwa_entities IN entities
        LET lwa_address = CORRESPONDING zcl_aux_contact_u=>gty_contaddr_u(
                lwa_entities MAPPING FROM ENTITY )
                IN ( lwa_address ) ).

    CHECK lt_address[] IS NOT INITIAL.

    lt_addressx = VALUE #(
        FOR lwa_entitiesx IN entities
        LET lwa_addressx = VALUE zcl_aux_contact_u=>gty_contaddr_intx(
            contact_id = lwa_entitiesx-contactid
            address_id = lwa_entitiesx-addressid
            address_sr = lwa_entitiesx-addresssr
            action_code = zcl_aux_contact_u=>gs_constants-operation_action-update
            _intx = CORRESPONDING zjo_s_address(
                lwa_entitiesx MAPPING FROM ENTITY USING CONTROL ) )
                IN ( CORRESPONDING #( lwa_entitiesx ) ) ).

    DATA(ls_entities) = VALUE #( entities[ 1 ] OPTIONAL ).

    zcl_aux_contact_u=>get_instance(  )->update_address(
      EXPORTING
        it_address  = lt_address
        it_addressx = lt_addressx
      IMPORTING
        et_address  = DATA(lt_address_out)
        et_message  = DATA(lt_message)
    ).

    zcl_aux_contact_u=>get_instance(  )->process_message_address(
      EXPORTING
        iv_cid        = ls_entities-%cid_ref
        iv_contact_id = ls_entities-contactid
        it_messages   = lt_message
      IMPORTING
        ev_has_error  = DATA(lv_has_error)
      CHANGING
        ct_failed     = failed-zi_address_u
        ct_report     = reported-zi_address_u
    ).

    IF lv_has_error = abap_false.
      mapped-zi_address_u = VALUE #(
          FOR lwa_address_out IN lt_address_out
          ( %cid = ls_entities-%cid_ref
*            %is_draft = ls_entities-%is_draft
             contactid = lwa_address_out-contact_id
             addressid = lwa_address_out-address_id
             addresssr = lwa_address_out-address_sr ) ).
    ENDIF.

  ENDMETHOD.

  METHOD delete.

    DATA : lt_address  TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           lt_addressx TYPE zcl_aux_contact_u=>gtt_contaddr_intx,
           lt_message  TYPE zcl_aux_contact_u=>gtt_message.

    lt_address = VALUE #(
       FOR lwa_keys IN keys
       ( contact_id = lwa_keys-contactid
         address_id = lwa_keys-addressid
         address_sr = lwa_keys-addresssr ) ).

    lt_addressx = VALUE #(
       FOR lwa_keysx IN keys
       ( contact_id = lwa_keysx-contactid
         address_id = lwa_keysx-addressid
         address_sr = lwa_keysx-addresssr
         action_code = zcl_aux_contact_u=>gs_constants-operation_action-delete ) ).

    zcl_aux_contact_u=>get_instance(  )->delete_address(
      EXPORTING
        it_address  = lt_address
        it_addressx = lt_addressx
      IMPORTING
        et_message  = lt_message
    ).

    DATA(ls_keys) = VALUE #( keys[ 1 ] OPTIONAL ).

    zcl_aux_contact_u=>get_instance(  )->process_message_address(
      EXPORTING
        iv_cid        = ls_keys-%cid_ref
        iv_contact_id = ls_keys-contactid
        it_messages   = lt_message
      IMPORTING
        ev_has_error  = DATA(lv_has_error)
      CHANGING
        ct_failed     = failed-zi_address_u
        ct_report     = reported-zi_address_u
    ).
    IF lv_has_error = abap_false.

      mapped-zi_address_u = VALUE #(
          FOR lwa_address_out IN lt_address
          ( %cid = ls_keys-%cid_ref
            contactid = lwa_address_out-contact_id
            addressid = lwa_address_out-address_id
            addresssr = lwa_address_out-address_sr )
       ).

    ENDIF.


  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Contact.
  ENDMETHOD.

ENDCLASS.
