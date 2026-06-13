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
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_contact_u RESULT result.
    METHODS rba_address FOR READ
      IMPORTING keys_rba FOR READ zi_contact_u\_address FULL result_requested RESULT result LINK association_links.

    METHODS cba_address FOR MODIFY
      IMPORTING entities_cba FOR CREATE zi_contact_u\_address.

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

    DATA : ls_contact_in   TYPE zcl_aux_contact_u=>gty_contact_u,
           ls_contact_intx TYPE zjo_contact,
           ls_contact_out  TYPE zcl_aux_contact_u=>gty_contact_u,
           lt_message      TYPE zcl_aux_contact_u=>gtt_message.

    LOOP AT entities INTO DATA(ls_entities).

      ls_contact_in = CORRESPONDING #(
                  ls_entities MAPPING FROM ENTITY ).
      ls_contact_intx = CORRESPONDING #(
                  ls_entities MAPPING FROM ENTITY USING CONTROL ).

      zcl_aux_contact_u=>get_instance(  )->update_contact(
        EXPORTING
          is_contact  = ls_contact_in
          is_contactx = ls_contact_intx
        IMPORTING
          es_contact  = ls_contact_out
          et_message  = lt_message
      ).
      "process if any error.

      zcl_aux_contact_u=>get_instance(  )->process_messages(
        EXPORTING
          iv_cid        = ls_entities-%cid_ref
          iv_contact_id = ls_contact_out-contact_id
          it_messages   = lt_message
        IMPORTING
          ev_has_error  = DATA(lv_has_error)
        CHANGING
          ct_failed     = failed-zi_contact_u
          ct_report     = reported-zi_contact_u
      ).
*      IF lv_has_error = abap_false.
*        mapped-u_contact = VALUE #( BASE mapped-u_contact (
*                           %cid = ls_entities-%cid_ref
*                           contactid = ls_contact_out-contact_id
*                       ) ).
*      ENDIF.
    ENDLOOP.



  ENDMETHOD.

  METHOD delete.

    DATA : lt_contact_keys TYPE zcl_aux_contact_u=>gtt_contact_keys,
*           lt_contaddr_keys TYPE zcl_brt_data_contact=>gtt_contaddr_keys,
           lt_message      TYPE zcl_aux_contact_u=>gtt_message.

    lt_contact_keys = VALUE #(
                        FOR lwa_keys IN keys WHERE ( contactid IS NOT INITIAL )
                        ( contact_id = lwa_keys-contactid ) ).

    zcl_aux_contact_u=>get_instance(  )->delete_contact(
       EXPORTING
it_del_keys  = lt_contact_keys
*it_addr_keys = lt_contaddr_keys
IMPORTING
et_message   = lt_message
).
    IF lt_message IS INITIAL.

      mapped-zi_contact_u = VALUE #( BASE mapped-zi_contact_u
                 FOR lwa_keys IN keys ( %pky = lwa_keys-%pky
                    ) ).

    ENDIF.

  ENDMETHOD.

  METHOD read.

    DATA : lt_contact_keys TYPE zcl_aux_contact_u=>gtt_contact_keys.
*         lt_contact      type zcl_brt_data_contact=>gtt_contact_u.

    lt_contact_keys = VALUE #(
                      FOR lwa_keys IN keys
                      WHERE ( contactid IS NOT INITIAL )
                      ( contact_id = lwa_keys-contactid ) ).

    zcl_aux_contact_u=>get_instance(  )->read_contact(
      EXPORTING
        it_contact_keys = lt_contact_keys
      IMPORTING
        et_contact      = DATA(lt_contact)
    ).
    result = VALUE #(
           FOR lwa_contact IN lt_contact
           ( CORRESPONDING #( lwa_contact MAPPING TO ENTITY )  )
           ).

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.

    "read entries

    READ ENTITIES OF zi_contact_u IN LOCAL MODE
    ENTITY zi_contact_u
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_contact).

    result = VALUE #(
                FOR lwa_contact IN lt_contact (
                    %key = lwa_contact-%key
*                    %is_draft = lwa_contact-%is_draft
                    %features = VALUE #(
                                %update = COND #(
                                    WHEN lwa_contact-active = abap_true
                                    THEN if_abap_behv=>fc-o-enabled
                                    ELSE if_abap_behv=>fc-o-disabled
                                )
                                %delete = COND #(
                                     WHEN lwa_contact-active = abap_true
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled )
                                 )

*    %assoc-_address = COND #(
*       WHEN lwa_contact-active = abap_true
*       THEN if_abap_behv=>fc-o-enabled
*       ELSE if_abap_behv=>fc-o-disabled )
)
).

  ENDMETHOD.

  METHOD rba_Address.

    DATA : lt_contaddr_keys TYPE zcl_aux_contact_u=>gtt_contaddr_keys.

    lt_contaddr_keys = VALUE #(
                    FOR lwa_keys IN keys_rba
                    ( contact_id = lwa_keys-contactid ) ).

    zcl_aux_contact_u=>get_instance(  )->read_address(
      EXPORTING
        it_contaddr_keys = lt_contaddr_keys
      IMPORTING
        et_contaddr      = DATA(lt_contaddr)
*        et_message       =
    ).

    result = VALUE #(
        FOR lwa_contaddr IN lt_contaddr
        ( CORRESPONDING #( lwa_contaddr MAPPING TO ENTITY ) )
     ).


  ENDMETHOD.

  METHOD cba_Address.

    DATA : lt_address_cba TYPE zcl_aux_contact_u=>gtt_contaddr_u.

    lt_address_cba = VALUE #(
            FOR ls_entities_cba IN entities_cba
            FOR lwa_target_cba IN ls_entities_cba-%target
            LET lwa_target = CORRESPONDING zcl_aux_contact_u=>gty_contaddr_u(
                    lwa_target_cba MAPPING FROM ENTITY )
                    IN
           (
                contact_id = ls_entities_cba-contactid
                address_id = lwa_target-address_id
                address_sr = lwa_target-address_sr
                addr1 = lwa_target-addr1
                addr2 = lwa_target-addr2
                city = lwa_target-city
                state = lwa_target-state
                pincode = lwa_target-pincode

            ) ).

    CHECK lt_address_cba[] IS NOT INITIAL.
    DATA(ls_entities) = VALUE #( entities_cba[ 1 ] OPTIONAL ).

    zcl_aux_contact_u=>get_instance(  )->create_address(
      EXPORTING
        it_address        = lt_address_cba
*         iv_numbering_mode = gs_constants-numbering_mode-late
      IMPORTING
        et_address        = DATA(lt_address_out)
        et_message        = DATA(lt_message)
    ).

    "process the message.

    zcl_aux_contact_u=>get_instance(  )->process_message_address(
      EXPORTING
*         iv_cid        =
        iv_contact_id = VALUE #( lt_address_cba[ 1 ]-contact_id OPTIONAL )
        it_messages   = lt_message
      IMPORTING
        ev_has_error  = DATA(lv_has_error)
      CHANGING
        ct_failed     = failed-zi_address_u
        ct_report     = reported-zi_address_u
    ).
    IF lv_has_error = abap_false.
      mapped-zi_address_u = VALUE #( BASE mapped-zi_address_u
          FOR lwa_address IN lt_address_out
          ( %cid = ls_entities-%cid_ref
*            %is_draft = ls_entities-%is_draft
              contactid = lwa_address-contact_id
              addressid = lwa_address-address_id
              addresssr = lwa_address-address_sr
           )
      ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.
