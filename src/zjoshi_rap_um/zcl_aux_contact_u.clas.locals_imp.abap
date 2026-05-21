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


    CLASS-METHODS : get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer_contact.

    METHODS : copy_b2a_contact.

    METHODS : prepare_transaction_buffer
      IMPORTING it_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                it_contactx       TYPE zcl_aux_contact_u=>gtt_contact_intx
                iv_delete_check   TYPE abap_boolean OPTIONAL
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                et_message        TYPE zcl_aux_contact_u=>gtt_message.

  PRIVATE SECTION.
    CLASS-DATA : go_instance TYPE REF TO lcl_buffer_contact.

    METHODS : _create_contact
      IMPORTING it_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
                iv_numbering_mode TYPE c DEFAULT zcl_aux_contact_u=>gs_constants-numbering_mode-late
      EXPORTING et_contact        TYPE zcl_aux_contact_u=>gtt_contact_u
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

ENDCLASS.
