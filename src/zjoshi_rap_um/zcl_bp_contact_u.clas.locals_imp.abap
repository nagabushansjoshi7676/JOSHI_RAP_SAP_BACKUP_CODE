CLASS lhc_ZI_CONTACT_U DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_contact_u RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_contact_u RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_contact_u.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_contact_u.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_contact_u.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_contact_u RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_contact_u.

ENDCLASS.

CLASS lhc_ZI_CONTACT_U IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA : ls_contact_in  TYPE zcl_aux_contact_u=>gty_contact_u,
           ls_contact_out TYPE zcl_aux_contact_u=>gty_contact_u,
           lt_message     TYPE zcl_aux_contact_u=>gtt_message.

    LOOP AT entities INTO DATA(ls_entities).

      ls_contact_in = CORRESPONDING #(
                  ls_entities MAPPING FROM ENTITY USING CONTROL ).

      zcl_aux_contact_u=>get_instance(  )->create_contact(
        EXPORTING
          is_contact        = ls_contact_in
*            iv_numbering_mode = gs_constants-numbering_mode-late
        IMPORTING
          es_contact        = ls_contact_out
          et_message        = lt_message
      ).

    ENDLOOP.

    "process the error message..

    zcl_aux_contact_u=>get_instance(  )->process_messages(
      EXPORTING
        iv_cid       = ls_entities-%cid
        it_messages  = lt_message
      IMPORTING
        ev_has_error = DATA(lv_has_error)
      CHANGING
        ct_failed    = failed-zi_contact_u
        ct_report    = reported-zi_contact_u
    ).

    IF lv_has_error IS INITIAL.
      "no error - return back created data

      mapped-zi_contact_u = VALUE #( BASE mapped-zi_contact_u
                 (  %cid = ls_entities-%cid
*                 %is_draft = ls_entities-%is_draft
                  contactid = ls_contact_out-contact_id

                   )
      ).
    ENDIF.


  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.
