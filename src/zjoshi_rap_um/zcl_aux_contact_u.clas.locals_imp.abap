*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


CLASS lcl_buffer_contact DEFINITION FINAL CREATE PRIVATE.

  PUBLIC SECTION.

*  inteRFACES if_oo_adt_classrun.

    DATA : mt_b4c_contact TYPE zcl_aux_contact_u=>gtt_contact_u,
           mt_b4u_contact TYPE zcl_aux_contact_u=>gtt_contact_u,
           mt_b4d_contact TYPE zcl_aux_contact_u=>gtt_contact_u.

    DATA : mt_a4c_contact TYPE zcl_aux_contact_u=>gtt_contact_u,
           mt_a4u_contact TYPE zcl_aux_contact_u=>gtt_contact_u,
           mt_a4d_contact TYPE zcl_aux_contact_u=>gtt_contact_u.

    DATA : mt_b4c_address TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           mt_b4u_address TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           mt_b4d_address TYPE zcl_aux_contact_u=>gtt_contaddr_u.

    DATA : mt_a4c_address TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           mt_a4u_address TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           mt_a4d_address TYPE zcl_aux_contact_u=>gtt_contaddr_u.

    DATA : ls_addressx TYPE zcl_aux_contact_u=>gtt_contaddr_intx.


    CLASS-METHODS : get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer_contact.

    METHODS : adjust_number_contact
      RETURNING VALUE(rt_contact_mapping) TYPE zcl_aux_contact_u=>gtt_contact_mapping.

    METHODS : finalize_contact, save_contact, initialize_contact.

    METHODS : check_before_save_contact
      EXPORTING et_message TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : _calculate_age
      IMPORTING iv_dob TYPE zjo_contact-dob
      CHANGING  cv_age TYPE zjo_contact-age.

    METHODS : copy_b2a_contact.

    METHODS : prepare_transaction_buffer
      IMPORTING it_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                it_contactx       TYPE zcl_aux_contact_u=>gtt_contact_intx
                iv_delete_check   TYPE abap_boolean OPTIONAL
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : _read_contact
      IMPORTING it_contact_keys TYPE zcl_aux_contact_u=>gtt_contact_keys
*                iv_include_buffer TYPE abap_boolean
      EXPORTING et_contact      TYPE zcl_aux_contact_u=>gtt_contact_u.

    "addrsss"
    METHODS : read_address
      IMPORTING it_contaddr_keys TYPE zcl_aux_contact_u=>gtt_contaddr_keys
      EXPORTING et_contaddr      TYPE zcl_aux_contact_u=>gtt_contaddr_u
                et_message       TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : prepare_tran_buf_address
      IMPORTING it_contaddr       TYPE zcl_aux_contact_u=>gtt_contaddr_u
                it_contaddrx      TYPE zcl_aux_contact_u=>gtt_contaddr_intx
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contaddr       TYPE zcl_aux_contact_u=>gtt_contaddr_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : adjust_number_address
      RETURNING VALUE(rt_contaddr_mapping) TYPE zcl_aux_contact_u=>gtt_contaddr_mapping.

    METHODS : copy_b2a_address, save_address, initialize_address.


  PRIVATE SECTION.
    CLASS-DATA : go_instance TYPE REF TO lcl_buffer_contact.


    METHODS : _create_contact
      IMPORTING it_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : _update_contact
      IMPORTING it_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                it_contactx       TYPE zcl_aux_contact_u=>gtt_contact_intx
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : _delete_contact
      IMPORTING it_contact TYPE zcl_aux_contact_u=>gtt_contact_u
      EXPORTING et_message TYPE zcl_aux_contact_u=>gtt_message.

    "start address change
    METHODS : _create_address
      IMPORTING it_contaddr       TYPE zcl_aux_contact_u=>gtt_contaddr_u
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contaddr       TYPE zcl_aux_contact_u=>gtt_contaddr_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : _update_address
      IMPORTING it_address        TYPE zcl_aux_contact_u=>gtt_contaddr_u
                it_addressx       TYPE zcl_aux_contact_u=>gtt_contaddr_intx
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_address        TYPE zcl_aux_contact_u=>gtt_contaddr_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.


ENDCLASS.


CLASS lcl_buffer_contact IMPLEMENTATION.

  METHOD get_instance.

    go_instance = COND #(
            WHEN go_instance IS BOUND
            THEN go_instance ELSE NEW #(  ) ).
    ro_instance = go_instance.

  ENDMETHOD.

  METHOD copy_b2a_contact.


    mt_a4c_contact = VALUE #( BASE mt_a4c_contact FOR lwa_b4c IN mt_b4c_contact ( lwa_b4c ) ).
    mt_a4u_contact = VALUE #( BASE mt_a4u_contact FOR lwa_b4u IN mt_b4u_contact ( lwa_b4u ) ).
    mt_a4d_contact = VALUE #( BASE mt_a4d_contact FOR lwa_b4d IN mt_b4d_contact ( lwa_b4d ) ).
    CLEAR : mt_b4c_contact, mt_b4u_contact, mt_b4d_contact.


  ENDMETHOD.


  METHOD prepare_transaction_buffer.

    DATA : lt_b4c  TYPE zcl_aux_contact_u=>gtt_contact_u,
           lt_b4u  TYPE zcl_aux_contact_u=>gtt_contact_u,
           lt_b4d  TYPE zcl_aux_contact_u=>gtt_contact_u,
           lt_b4ux TYPE zcl_aux_contact_u=>gtt_contact_intx.

    CLEAR et_message.
    CHECK it_contact IS NOT INITIAL.

    LOOP AT it_contact INTO DATA(ls_contact).

      DATA(ls_contactx) = VALUE #( it_contactx[ contact_id = ls_contact-contact_id ] OPTIONAL ).
      IF ls_contactx IS INITIAL.
        et_message = VALUE #( BASE et_message (
                                msgid = zcl_aux_contact_u=>gs_constants-message_id
                                msgno = '001'
                                msgty = if_abap_behv_message=>severity-error
                                msgv1 = ls_contact-contact_id
                                ) ).
        RETURN.
      ENDIF.

      CASE ls_contactx-action_code.

        WHEN zcl_aux_contact_u=>gs_constants-operation_action-create.
          APPEND ls_contact TO lt_b4c.
        WHEN zcl_aux_contact_u=>gs_constants-operation_action-update.
          APPEND ls_contact TO lt_b4u.
          APPEND ls_contactx TO lt_b4ux.
        WHEN zcl_aux_contact_u=>gs_constants-operation_action-delete.
          APPEND ls_contact TO lt_b4d.

      ENDCASE.
    ENDLOOP.

    _create_contact(
      EXPORTING
        it_contact        = lt_b4c
*         iv_numbering_mode = zcl_brt_data_contact=>gs_constants-numbering_mode-late
      IMPORTING
        et_contact        = et_contact
        et_message        = et_message
    ).

    _update_contact(
      EXPORTING
        it_contact        = lt_b4u
        it_contactx       = lt_b4ux
      IMPORTING
        et_contact        = DATA(lt_contact)
        et_message        = DATA(lt_message)
    ).

    _delete_contact(
      EXPORTING
        it_contact = lt_b4d
      IMPORTING
        et_message = lt_message
    ).

  ENDMETHOD.

  METHOD _read_contact.

    CHECK it_contact_keys IS NOT INITIAL.

    SELECT * FROM zjo_contact
        FOR ALL ENTRIES IN @it_contact_keys
        WHERE contact_id = @it_contact_keys-contact_id
        INTO TABLE @et_contact.

  ENDMETHOD.

  METHOD _create_contact.

    CLEAR : et_message, et_contact.
    CHECK it_contact IS NOT INITIAL.

    "Validation to be done here
    "get numbering generated in case of late numbering.

    LOOP AT it_contact INTO DATA(ls_contact).

      IF iv_numbering_mode = zcl_aux_contact_u=>gs_constants-numbering_mode-late.

        ls_contact-created_by = 'LATE'.
      ELSE.
        TRY.
            ls_contact-contact_id = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
        ls_contact-created_by = cl_abap_context_info=>get_user_technical_name(  ).

      ENDIF.

      GET TIME STAMP FIELD ls_contact-created_at.
      ls_contact-last_changed_at = ls_contact-created_at.
      ls_contact-last_changed_by = ls_contact-created_by.

      APPEND ls_contact TO mt_b4c_contact.

    ENDLOOP.
    et_contact = mt_b4c_contact.
  ENDMETHOD.

  METHOD _update_contact.

    CLEAR : et_message, et_contact.
    CHECK it_contact IS NOT INITIAL.

    SELECT * FROM zjo_contact
    FOR ALL ENTRIES IN @it_contact
    WHERE contact_id = @it_contact-contact_id
    INTO TABLE @DATA(lt_exist).

    LOOP AT it_contact INTO DATA(ls_update_contact).

      ASSIGN lt_exist[ contact_id = ls_update_contact-contact_id ] TO FIELD-SYMBOL(<lfs_exist>).
      CHECK <lfs_exist> IS ASSIGNED.
      INSERT <lfs_exist> INTO TABLE mt_b4u_contact ASSIGNING FIELD-SYMBOL(<lfs_b4u_contact>).
      CHECK <lfs_b4u_contact> IS ASSIGNED.

      "get control stucture for values to be updated

      DATA(ls_contactx) = VALUE #( it_contactx[
                              contact_id = ls_update_contact-contact_id
                              action_code = zcl_aux_contact_u=>gs_constants-operation_action-update
                              ] OPTIONAL ).
      CHECK ls_contactx IS NOT INITIAL.

      "update modified field and save it to buffer

      DATA(lv_field_number) = 2.
      DO.

        ASSIGN COMPONENT lv_field_number OF STRUCTURE ls_contactx-_intx TO FIELD-SYMBOL(<lv_changed_flag>).
        IF sy-subrc IS NOT INITIAL.
          EXIT.
        ENDIF.

        IF <lv_changed_flag> = abap_true.
          ASSIGN COMPONENT lv_field_number OF STRUCTURE ls_update_contact TO FIELD-SYMBOL(<lv_field_new>).
          CHECK sy-subrc IS INITIAL.
          ASSIGN COMPONENT lv_field_number OF STRUCTURE <lfs_b4u_contact> TO FIELD-SYMBOL(<lv_field_old>).
          CHECK sy-subrc IS INITIAL.
          <lv_field_old> = <lv_field_new>.
        ENDIF.
        lv_field_number += 1.
      ENDDO.

      "other determination

      <lfs_b4u_contact>-last_changed_by = cl_abap_context_info=>get_user_technical_name(  ).
      GET TIME STAMP FIELD <lfs_b4u_contact>-last_changed_at.
      UNASSIGN : <lfs_exist>, <lfs_b4u_contact>.
      CLEAR : ls_contactx.

    ENDLOOP.
    et_contact = mt_b4u_contact.


  ENDMETHOD.

  METHOD _delete_contact.

    CLEAR : et_message.
    CHECK it_contact IS NOT INITIAL.

    mt_b4d_contact = VALUE #( BASE mt_b4d_contact ( LINES OF it_contact ) ).

  ENDMETHOD.

  METHOD adjust_number_contact.

    DATA : lt_a4c_contact TYPE zcl_aux_contact_u=>gtt_contact_u.

    "buffer must be empty

    CHECK mt_b4c_contact IS INITIAL.
    CHECK mt_b4u_contact IS INITIAL.
    CHECK mt_b4d_contact IS INITIAL.

    "at least one contact should be requested to create.
    CHECK mt_a4c_contact IS NOT INITIAL.

    LOOP AT mt_a4c_contact INTO DATA(ls_a4c_contact).

      IF ls_a4c_contact-created_by+0(4) = 'LATE'.
        TRY.
            DATA(lv_contact_id) = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
            CONTINUE.
        ENDTRY.
        ls_a4c_contact-created_by = cl_abap_context_info=>get_user_technical_name(  ).
        ls_a4c_contact-last_changed_by = ls_a4c_contact-created_by.
      ELSE.
        lv_contact_id = ls_a4c_contact-contact_id.
      ENDIF.
      APPEND VALUE #(
                    preliminary-contact_id = ls_a4c_contact-contact_id
                    final-contact_id       = lv_contact_id
       ) TO rt_contact_mapping.
      ls_a4c_contact-contact_id = lv_contact_id.
      APPEND ls_a4c_contact TO lt_a4c_contact.

    ENDLOOP.

    mt_a4c_contact = lt_a4c_contact.


  ENDMETHOD.

  METHOD initialize_contact.

    CLEAR : mt_a4c_contact, mt_a4u_contact, mt_a4d_contact.

  ENDMETHOD.

  METHOD save_contact.

    CHECK mt_b4c_contact IS INITIAL.
    CHECK mt_b4u_contact IS INITIAL.
    CHECK mt_b4d_contact IS INITIAL.

    IF mt_a4c_contact IS NOT INITIAL.
      INSERT zjo_contact FROM TABLE @mt_a4c_contact.
    ENDIF.

    IF mt_a4u_contact IS NOT INITIAL.
      UPDATE zjo_contact FROM TABLE @mt_a4u_contact.
    ENDIF.

    IF mt_a4d_contact IS NOT INITIAL.
      DELETE zjo_contact FROM TABLE @mt_a4d_contact.
    ENDIF.

  ENDMETHOD.

  METHOD finalize_contact.

    LOOP AT mt_a4c_contact ASSIGNING FIELD-SYMBOL(<lfs_a4c_contact>).
*
      _calculate_age(
        EXPORTING
          iv_dob = <lfs_a4c_contact>-dob
        CHANGING
          cv_age = <lfs_a4c_contact>-age
      ).

    ENDLOOP.

    LOOP AT mt_a4u_contact ASSIGNING FIELD-SYMBOL(<lfs_a4u_contact>).

      _calculate_age(
        EXPORTING
          iv_dob = <lfs_a4u_contact>-dob
        CHANGING
          cv_age = <lfs_a4u_contact>-age
      ).

    ENDLOOP.

  ENDMETHOD.

  METHOD _calculate_age.

    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_age) = COND #(
                WHEN iv_dob IS INITIAL THEN 0
                ELSE lv_today(4) - iv_dob(4)
     ).

    IF lv_today+4(4) < iv_dob+4(4).
      lv_age -= 1.
    ENDIF.
*    lv_age += 20.
    cv_age = lv_age.

  ENDMETHOD.

  METHOD check_before_save_contact.

    DATA : lt_contact TYPE zcl_aux_contact_u=>gtt_contact_u,
           lv_str_tel TYPE c LENGTH 10.

    " get the entries either from create or update

    lt_contact = VALUE #( BASE lt_contact ( LINES OF mt_a4c_contact ) ).
    lt_contact = VALUE #( BASE lt_contact ( LINES OF mt_a4u_contact ) ).

    CLEAR et_message.


    LOOP AT lt_contact REFERENCE INTO DATA(lo_contact).

      "validate first name

      IF lo_contact->first_name IS INITIAL.
        et_message = VALUE #( BASE et_message (
                               msgid = zcl_aux_contact_u=>gs_constants-message_id
                               msgv1 = 'FirstName'
                               msgv2 = lo_contact->contact_id
                               msgv3 = 'First Name is mandatory'
                               ) ).
      ENDIF.

      "validate last name

      IF lo_contact->last_name IS INITIAL.
        et_message = VALUE #( BASE et_message (
                               msgid = zcl_aux_contact_u=>gs_constants-message_id
                               msgv1 = 'LastName'
                               msgv2 = lo_contact->contact_id
                               msgv3 = 'Last Name is mandatory'
                               ) ).
      ENDIF.

      "validate telephone number

      IF lo_contact->telephone IS NOT INITIAL.
        lv_str_tel = |{ lo_contact->telephone ALPHA = OUT }|.
        DATA(lv_len) = strlen( lv_str_tel ).
        IF lv_len <> 10.
          et_message = VALUE #( BASE et_message (
                                 msgid = zcl_aux_contact_u=>gs_constants-message_id
                                 msgv1 = 'Telephone'
                                 msgv2 = lo_contact->contact_id
                                 msgv3 = 'Telephone number must be 10 digits'
                                 ) ).
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD adjust_number_address.

    DATA : lt_a4c_address TYPE zcl_aux_contact_u=>gtt_contaddr_u.
    "buffer must be empty.

    CHECK mt_b4c_address IS INITIAL.
    CHECK mt_b4u_address IS INITIAL.
    CHECK mt_b4d_address IS INITIAL.

    "at least one address must be requested for create.
    CHECK mt_a4c_address IS NOT INITIAL.

    DATA(lv_current_contact_id) = VALUE #( mt_a4c_address[ 1 ]-contact_id OPTIONAL ).

    "get existing address entries (for next serial number).

    SELECT contact_id, address_id, address_sr
        FROM zjo_cont_address
        WHERE contact_id = @lv_current_contact_id
        INTO TABLE @DATA(lt_existing).

    SORT lt_existing BY contact_id ASCENDING address_sr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_existing COMPARING contact_id.

    DATA(ls_existing) = VALUE #( lt_existing[
        contact_id = lv_current_contact_id ] OPTIONAL ).

    DATA(lv_last_serial) = ls_existing-address_sr.
    lv_last_serial += 1.

    LOOP AT mt_a4c_address INTO DATA(ls_a4c_address).
      "if late numbering used.

      IF ls_a4c_address-created_by+0(4) = 'LATE'.
        TRY.
            DATA(lv_address_id) = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
            CONTINUE.
        ENDTRY.
        ls_a4c_address-created_by = cl_abap_context_info=>get_user_technical_name(  ).
        ls_a4c_address-last_changed_by = ls_a4c_address-created_by.
      ELSE.
        lv_address_id = ls_a4c_address-address_id.
        lv_last_serial = ls_a4c_address-address_sr.
      ENDIF.

      APPEND VALUE zcl_aux_contact_u=>ls_contaddr_mapping(
              preliminary = VALUE #( contact_id = ls_a4c_address-contact_id
                                     address_id = ls_a4c_address-address_id
                                     address_sr = ls_a4c_address-address_sr )

              final =      VALUE #( contact_id = ls_a4c_address-contact_id
                                     address_id = lv_address_id
                                     address_sr = lv_last_serial ) )
                       TO rt_contaddr_mapping.

      ls_a4c_address-address_id = lv_address_id.
      ls_a4c_address-address_sr = lv_last_serial.
      APPEND ls_a4c_address TO lt_a4c_address.

    ENDLOOP.

    mt_a4c_address[] = lt_a4c_address[].


  ENDMETHOD.

  METHOD copy_b2a_address.

    mt_a4c_address = VALUE #( BASE mt_a4c_address
                       FOR lwa_b4c_address IN mt_b4c_address ( lwa_b4c_address )
       ).
    mt_a4u_address = VALUE #( BASE mt_a4u_address
                    FOR lwa_b4u_address IN mt_b4u_address ( lwa_b4u_address )
    ).
    mt_a4d_address = VALUE #( BASE mt_a4d_address
                    FOR lwa_b4d_address IN mt_b4d_address ( lwa_b4d_address )
    ).
    CLEAR : mt_b4c_address, mt_b4u_address, mt_b4d_address.

  ENDMETHOD.

  METHOD initialize_address.

    CLEAR : mt_a4c_address, mt_a4u_address, mt_a4d_address.

  ENDMETHOD.

  METHOD prepare_tran_buf_address.

    DATA : lt_b4c_address  TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           lt_b4u_address  TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           lt_b4d_address  TYPE zcl_aux_contact_u=>gtt_contaddr_u,
           lt_b4u_addressx TYPE zcl_aux_contact_u=>gtt_contaddr_intx.

    CLEAR : et_contaddr, et_message.
    CHECK it_contaddr IS NOT INITIAL.

    LOOP AT it_contaddr INTO DATA(ls_address).
        data(ls_addressx) = VALUE #( it_contaddrx[
          contact_id = ls_address-contact_id
          address_id = ls_address-address_id
          address_sr = ls_address-address_sr ] ).

      IF ls_addressx IS INITIAL.
        et_message = VALUE #( BASE et_message (
                msgid = zcl_aux_contact_u=>gs_constants-message_id
                msgno = '001'
                msgty = if_abap_behv_message=>severity-error
                msgv1 = ls_address-contact_id
         ) ).
        RETURN.
      ENDIF.

      CASE ls_addressx-action_code.
        WHEN zcl_aux_contact_u=>gs_constants-operation_action-create.
          APPEND ls_address TO lt_b4c_address.
        WHEN zcl_aux_contact_u=>gs_constants-operation_action-update.
          APPEND ls_address TO lt_b4u_address.
          APPEND ls_addressx TO lt_b4u_addressx.
        WHEN zcl_aux_contact_u=>gs_constants-operation_action-delete.
          APPEND ls_address TO mt_b4d_address.
      ENDCASE.

    ENDLOOP.

    _create_address(
      EXPORTING
        it_contaddr       = lt_b4c_address
        iv_numbering_mode = iv_numbering_mode
      IMPORTING
        et_contaddr       = et_contaddr
        et_message        = et_message
    ).

    _update_address(
      EXPORTING
        it_address        = lt_b4u_address
        it_addressx       = lt_b4u_addressx
        iv_numbering_mode = iv_numbering_mode
      IMPORTING
        et_address        = et_contaddr
        et_message        = et_message
    ).


  ENDMETHOD.

  METHOD read_address.

    CLEAR : et_contaddr, et_message.
    CHECK : it_contaddr_keys[] IS NOT INITIAL.


  ENDMETHOD.

  METHOD save_address.

    DATA : lv_last_late_number TYPE c LENGTH 16.

    CHECK mt_b4c_address IS INITIAL.
    CHECK mt_b4u_address IS INITIAL.
    CHECK mt_b4d_address IS INITIAL.

    IF mt_a4c_address IS NOT INITIAL.
      INSERT zjo_cont_address FROM TABLE @mt_a4c_address.
    ENDIF.
    IF mt_a4u_address IS NOT INITIAL.
      UPDATE zjo_cont_address FROM TABLE @mt_a4u_address.
    ENDIF.
    IF mt_a4d_address IS NOT INITIAL.
      DELETE zjo_cont_address FROM TABLE @mt_a4d_address.
    ENDIF.


  ENDMETHOD.

  METHOD _create_address.

    DATA : lt_contact_group TYPE zcl_aux_contact_u=>gtt_contact_u,
           lt_address_curr  TYPE zcl_aux_contact_u=>gtt_contaddr_u.

    CLEAR : et_contaddr, et_message.
    CHECK it_contaddr IS NOT INITIAL.

    "get the extsting address.

    IF iv_numbering_mode = zcl_aux_contact_u=>gs_constants-numbering_mode-early.

      SELECT contact_id, address_id, address_sr
        FROM zjo_cont_address
        FOR ALL ENTRIES IN @it_contaddr
        WHERE contact_id = @it_contaddr-contact_id
        INTO TABLE @DATA(lt_existing).

      SORT lt_existing BY contact_id ASCENDING address_sr DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_existing COMPARING contact_id.
    ENDIF.

    "get unique contact id

    LOOP AT it_contaddr INTO DATA(ls_grp)
        GROUP BY ( contact_id = ls_grp-contact_id )
        ASCENDING REFERENCE INTO DATA(lo_grp).
      lt_contact_group = VALUE #( BASE lt_contact_group
              ( contact_id = lo_grp->contact_id )
      ).
    ENDLOOP.

    "get the number generated.

    LOOP AT lt_contact_group INTO DATA(ls_address).
      lt_address_curr = VALUE #(
              FOR lwa_address IN it_contaddr
              WHERE ( contact_id = ls_address-contact_id )
              ( lwa_address )
      ).
      LOOP AT lt_address_curr INTO DATA(ls_address_curr).
        ls_address_curr-contact_id = ls_address-contact_id.
        IF iv_numbering_mode = zcl_aux_contact_u=>gs_constants-numbering_mode-late.
          ls_address_curr-created_by = |LATE|.
        ELSE.
          TRY.
              ls_address_curr-address_id = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.

          "create next address serial

          DATA(ls_existing) = VALUE #( lt_existing[
              contact_id = ls_address-contact_id ] OPTIONAL ).
          DATA(lv_last_serial) = ls_existing-address_sr.
          lv_last_serial += 1.
          ls_address_curr-address_sr = lv_last_serial.
          ls_address_curr-created_by = cl_abap_context_info=>get_user_technical_name(  ).
        ENDIF.

        "other determination

        GET TIME STAMP FIELD ls_address-created_at.
        ls_address_curr-last_changed_by = ls_address_curr-created_by.
        ls_address_curr-last_changed_at = ls_address_curr-created_at.
        INSERT ls_address_curr INTO TABLE mt_b4c_address.

      ENDLOOP.
    ENDLOOP.
    et_contaddr = mt_b4c_address.

  ENDMETHOD.

  METHOD _update_address.

    CLEAR : et_address, et_message.
    CHECK : it_address IS NOT INITIAL.

    SELECT * FROM zjo_cont_address
        FOR ALL ENTRIES IN @it_address
        WHERE contact_id = @it_address-contact_id
        AND address_id = @it_address-address_id
        AND address_sr = @it_address-address_sr
     INTO TABLE @DATA(lt_exist).

    LOOP AT it_address INTO DATA(ls_update_address).

      ASSIGN lt_exist[
          contact_id = ls_update_address-contact_id
          address_id = ls_update_address-address_id
          address_sr = ls_update_address-address_sr ]
       TO FIELD-SYMBOL(<lfs_exist>).

      CHECK <lfs_exist> IS ASSIGNED.

      INSERT <lfs_exist> INTO TABLE mt_b4u_address
      ASSIGNING FIELD-SYMBOL(<lfs_b4u_address>).
      CHECK <lfs_b4u_address> IS ASSIGNED.

      DATA(ls_addressx) = VALUE #( it_addressx[
           contact_id = ls_update_address-contact_id
           address_id = ls_update_address-address_id
           address_sr = ls_update_address-address_sr
           action_code = zcl_aux_contact_u=>gs_constants-operation_action-update ] OPTIONAL ).

      CHECK ls_addressx IS NOT INITIAL.

      "update modify field and save to buffer..

      DATA(lv_field_number) = 4.
      DO.
        ASSIGN COMPONENT lv_field_number
        OF STRUCTURE ls_addressx-_intx
        TO FIELD-SYMBOL(<lv_change_flag>).

        IF sy-subrc IS NOT INITIAL.
          EXIT.
        ENDIF.

        IF <lv_change_flag> = abap_true.
          ASSIGN COMPONENT lv_field_number + 1
          OF STRUCTURE ls_update_address
          TO FIELD-SYMBOL(<lv_field_new>).

          CHECK sy-subrc IS INITIAL.

          ASSIGN COMPONENT lv_field_number + 1
          OF STRUCTURE <lfs_b4u_address>
          TO FIELD-SYMBOL(<lv_field_old>).

          CHECK sy-subrc IS INITIAL.
          <lv_field_old>  = <lv_field_new>.
        ENDIF.
        lv_field_number += 1.
      ENDDO.

      "other determination

      <lfs_b4u_address>-last_changed_by = cl_abap_context_info=>get_user_technical_name(  ).

      GET TIME STAMP FIELD <lfs_b4u_address>-last_changed_at.
      UNASSIGN: <lfs_exist>, <lfs_b4u_address>.
      CLEAR ls_addressx.

    ENDLOOP.

    et_address = mt_b4u_address.


  ENDMETHOD.

ENDCLASS.
