CLASS zcl_aux_contact_u DEFINITION
  PUBLIC
  FINAL
   CREATE PUBLIC INHERITING FROM cl_abap_behv.

  PUBLIC SECTION.

    TYPES : BEGIN OF ls_contact_key,
              contact_id TYPE zjo_contact-contact_id,
            END OF ls_contact_key.

    TYPES : BEGIN OF ls_contact_mapping,
              preliminary TYPE ls_contact_key,
              final       TYPE ls_contact_key,
            END OF ls_contact_mapping.

    TYPES : gtt_contact_mapping TYPE STANDARD TABLE OF ls_contact_mapping WITH DEFAULT KEY.

    TYPES : BEGIN OF lty_contact_intx,

              contact_id  TYPE zjo_contact-contact_id,
              action_code TYPE c LENGTH 1,
              _intx       TYPE zjo_s_contact,

            END OF lty_contact_intx.

    TYPES : BEGIN OF ls_contaddr_key,
              contact_id TYPE zjo_cont_address-contact_id,
              address_id TYPE zjo_cont_address-address_id,
              address_sr TYPE zjo_cont_address-address_sr,
            END OF ls_contaddr_key.

    TYPES : BEGIN OF ls_contaddr_mapping,
              preliminary TYPE ls_contaddr_key,
              final       TYPE ls_contaddr_key,
            END OF ls_contaddr_mapping.

    TYPES : gty_contact_u    TYPE zjo_contact,
            gtt_contact_u    TYPE TABLE OF zjo_contact,
            gtt_contact_intx TYPE TABLE OF lty_contact_intx,
            gtt_contact_keys TYPE TABLE OF ls_contact_key,
            gtt_message      TYPE TABLE OF symsg.

    TYPES : gtt_failed_contact   TYPE TABLE FOR FAILED EARLY zi_contact_u\\zi_contact_u,
            gtt_reported_contact TYPE TABLE FOR REPORTED EARLY zi_contact_u\\zi_contact_u,
            gtt_failed_address   TYPE TABLE FOR FAILED EARLY zi_contact_u\\ZI_Address_U,
            gtt_reported_address TYPE TABLE FOR REPORTED EARLY zi_contact_u\\ZI_Address_U.

    "start of address change

    TYPES : gtt_contaddr_keys    TYPE STANDARD TABLE OF ls_contaddr_key,
            gtt_contaddr_mapping TYPE STANDARD TABLE OF ls_contaddr_mapping WITH DEFAULT KEY.

    TYPES : gty_contaddr_u TYPE zjo_cont_address,
            gtt_contaddr_u TYPE TABLE OF zjo_cont_address.

    TYPES : BEGIN OF ls_contaddr_intx,
              contact_id  TYPE zjo_cont_address-contact_id,
              address_id  TYPE zjo_cont_address-address_id,
              address_sr  TYPE zjo_cont_address-address_sr,
              action_code TYPE c LENGTH 1,
              _intx       TYPE zjo_s_address,
            END OF ls_contaddr_intx.

    CONSTANTS : BEGIN OF gs_constants,
                  BEGIN OF numbering_mode,
                    early TYPE c VALUE 'E',
                    late  TYPE c VALUE 'L',
                  END OF numbering_mode,

                  BEGIN OF operation_action,
                    create TYPE c VALUE 'C',
                    update TYPE c VALUE 'U',
                    delete TYPE c VALUE 'D',
                  END OF operation_action,

                  message_id TYPE symsg-msgid VALUE 'ZCL_MESSAGE_CONTACT',
                END OF gs_constants.

    TYPES : gty_contaddr_intx TYPE ls_contaddr_intx,
            gtt_contaddr_intx TYPE STANDARD TABLE OF ls_contaddr_intx WITH DEFAULT KEY.

    METHODS : read_contact
      IMPORTING it_contact_keys TYPE gtt_contact_keys
*                iv_include_buffer TYPE abap_boolean
      EXPORTING et_contact      TYPE gtt_contact_u.
*                et_contaddr     TYPE gtt_contaddr_u.

    METHODS : create_contact
      IMPORTING is_contact        TYPE gty_contact_u
                iv_numbering_mode TYPE c DEFAULT gs_constants-numbering_mode-late
      EXPORTING es_contact        TYPE gty_contact_u
                et_message        TYPE gtt_message.

    METHODS : update_contact
      IMPORTING is_contact  TYPE gty_contact_u
                is_contactx TYPE zjo_contact
      EXPORTING es_contact  TYPE gty_contact_u
                et_message  TYPE gtt_message.

    METHODS : delete_contact
      IMPORTING it_del_keys TYPE gtt_contact_keys
*                it_addr_keys TYPE gtt_contaddr_keys
      EXPORTING et_message  TYPE gtt_message.

    METHODS : adjust_number_contact
      RETURNING VALUE(rt_contact_mapping) TYPE gtt_contact_mapping.

    METHODS : finalize_contact, save_contact, initialize_contact.

    METHODS : check_before_save_contact
      EXPORTING et_message TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : process_messages
      IMPORTING iv_cid        TYPE abp_behv_cid OPTIONAL
                iv_contact_id TYPE zjo_contact-contact_id OPTIONAL
                it_messages   TYPE gtt_message
      EXPORTING ev_has_error  TYPE abap_boolean
      CHANGING  ct_failed     TYPE gtt_failed_contact
                ct_report     TYPE gtt_reported_contact.

    "address"

    METHODS : read_address
      IMPORTING it_contaddr_keys TYPE zcl_aux_contact_u=>gtt_contaddr_keys
      EXPORTING et_contaddr      TYPE zcl_aux_contact_u=>gtt_contaddr_u
                et_message       TYPE zcl_aux_contact_u=>gtt_message.

    METHODS : create_address
      IMPORTING it_address        TYPE gtt_contaddr_u
                iv_numbering_mode TYPE c DEFAULT gs_constants-numbering_mode-late
      EXPORTING et_address        TYPE gtt_contaddr_u
                et_message        TYPE gtt_message.

    METHODS : update_address
      IMPORTING it_address        TYPE gtt_contaddr_u
                it_addressx       TYPE gtt_contaddr_intx
                iv_numbering_mode TYPE c DEFAULT gs_constants-numbering_mode-late
      EXPORTING et_address        TYPE gtt_contaddr_u
                et_message        TYPE gtt_message.

    METHODS : delete_address
      IMPORTING it_address  TYPE gtt_contaddr_u
                it_addressx TYPE gtt_contaddr_intx
      EXPORTING et_message  TYPE gtt_message.


    METHODS : adjust_number_address
      EXPORTING VALUE(rt_contaddr_mapping) TYPE gtt_contaddr_mapping.

    METHODS : save_address,
      initialize_address.

    METHODS : process_message_address
      IMPORTING iv_cid        TYPE abp_behv_cid OPTIONAL
                iv_contact_id TYPE zjo_contact-contact_id OPTIONAL
                it_messages   TYPE gtt_message
      EXPORTING ev_has_error  TYPE abap_boolean
      CHANGING  ct_failed     TYPE gtt_failed_address
                ct_report     TYPE gtt_reported_address.


    CLASS-METHODS : get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_aux_contact_u.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA : go_instance TYPE REF TO  zcl_aux_contact_u.

ENDCLASS.



CLASS zcl_aux_contact_u IMPLEMENTATION.

  METHOD get_instance.

    go_instance = COND #(
                          WHEN go_instance IS BOUND
                          THEN go_instance ELSE NEW #(  ) ).
    ro_instance = go_instance.

  ENDMETHOD.

  METHOD read_contact.

    lcl_buffer_contact=>get_instance(  )->_read_contact(
          EXPORTING
            it_contact_keys = it_contact_keys
          IMPORTING
            et_contact      = et_contact
*        et_contaddr     = et_contaddr
        ).


  ENDMETHOD.

  METHOD create_contact.


    lcl_buffer_contact=>get_instance(  )->prepare_transaction_buffer(
         EXPORTING
           it_contact        = VALUE #( ( CORRESPONDING #( is_contact ) ) )
           it_contactx       = VALUE #( (
                                           contact_id  = is_contact-contact_id
               action_code = gs_constants-operation_action-create
             )  )
         IMPORTING
           et_contact        = DATA(lt_contact)
           et_message        = et_message
       ).

    IF et_message IS INITIAL.
      es_contact = VALUE #( lt_contact[ 1 ] OPTIONAL ).
      lcl_buffer_contact=>get_instance( )->copy_b2a_contact( ).
    ENDIF.


  ENDMETHOD.

  METHOD update_contact.

    lcl_buffer_contact=>get_instance(  )->prepare_transaction_buffer(
      EXPORTING
        it_contact        = VALUE #( ( CORRESPONDING #( is_contact ) ) )
        it_contactx       = VALUE #( (
                                        contact_id  = is_contact-contact_id
            action_code = gs_constants-operation_action-update
            _intx = CORRESPONDING #( is_contactx )
          )  )
*        iv_delete_check   =
*        iv_numbering_mode = zcl_brt_data_contact=>gs_constants-numbering_mode-late
      IMPORTING
        et_contact        = DATA(lt_contact)
        et_message        = et_message
    ).

    IF  et_message IS INITIAL.
      es_contact = VALUE #( lt_contact[ 1 ] OPTIONAL ).
      lcl_buffer_contact=>get_instance( )->copy_b2a_contact( ).
    ENDIF.

  ENDMETHOD.

  METHOD delete_contact.

*    DATA : lt_contaddr TYPE zcl_aux_contact_u=>gtt_contaddr_u,
*           lt_addressx TYPE zcl_aux_contact_u=>gtt_contaddr_intx.
*
*    lt_contaddr = VALUE #(
*        FOR lwa_keysx IN it_addr_keys
*        ( contact_id = lwa_keysx-contact_id
*          address_id = lwa_keysx-address_id
*          address_sr = lwa_keysx-address_sr )
*         ).
*    lt_addressx = VALUE #(
*        FOR lwa_keysx IN it_addr_keys
*        ( contact_id = lwa_keysx-contact_id
*          address_id = lwa_keysx-address_id
*          address_sr = lwa_keysx-address_sr
*          action_code = zcl_brt_data_contact=>gs_constants-operation_action-delete )
*          ).
*    lcl_buffer_contact=>get_instance(  )->prepare_tran_buf_address(
*      EXPORTING
*        it_contaddr       = lt_contaddr
*        it_contaddrx      = lt_addressx
**        iv_numbering_mode = zcl_brt_data_contact=>gs_constants-numbering_mode-late
*      IMPORTING
**        et_contaddr       =
*        et_message        = et_message
*    ).
*    IF et_message IS INITIAL.
*      lcl_buffer_contact=>get_instance( )->copy_b2a_address( ).
*    ENDIF.

    LOOP AT it_del_keys INTO DATA(ls_del_keys).

      lcl_buffer_contact=>get_instance(  )->prepare_transaction_buffer(
        EXPORTING
          it_contact        = VALUE #( ( contact_id = ls_del_keys-contact_id ) )
          it_contactx       = VALUE #( (
                                      contact_id  = ls_del_keys-contact_id
                               action_code = gs_constants-operation_action-delete
                               ) )
*            iv_delete_check   =
*            iv_numbering_mode = zcl_brt_data_contact=>gs_constants-numbering_mode-late
        IMPORTING
          et_contact        = DATA(lt_contact)
          et_message        = et_message
      ).

      IF  et_message IS INITIAL.
        lcl_buffer_contact=>get_instance( )->copy_b2a_contact( ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD process_messages.

    ev_has_error = abap_false.

    LOOP AT it_messages INTO DATA(ls_message).

      IF ls_message-msgty = 'E' OR ls_message-msgty = 'A'.

        APPEND VALUE #(
            %cid = iv_cid
            contactid = iv_contact_id
         ) TO ct_failed.
        ct_report = VALUE #( BASE ct_report
           (
               %cid = iv_cid
               contactid = iv_contact_id
               %msg = new_message(
                        id       = ls_message-msgid
                        number   = ls_message-msgno
                        severity = if_abap_behv_message=>severity-error
                        v1       = ls_message-msgv1
                        v2       = ls_message-msgv2
                        v3       = ls_message-msgv3
                        v4       = ls_message-msgv4
                      )
           )
         ).
        ev_has_error = abap_true.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD adjust_number_contact.

    rt_contact_mapping = lcl_buffer_contact=>get_instance( )->adjust_number_contact( ).

  ENDMETHOD.

  METHOD initialize_contact.

    lcl_buffer_contact=>get_instance( )->initialize_contact( ).

  ENDMETHOD.

  ""====================================""

  METHOD save_contact.

    lcl_buffer_contact=>get_instance( )->save_contact( ).

  ENDMETHOD.

  METHOD finalize_contact.

    lcl_buffer_contact=>get_instance(  )->finalize_contact(  ).

  ENDMETHOD.

  METHOD check_before_save_contact.

    lcl_buffer_contact=>get_instance( )->check_before_save_contact(
      IMPORTING
        et_message = et_message
    ).

  ENDMETHOD.

  METHOD adjust_number_address.

    rt_contaddr_mapping = lcl_buffer_contact=>get_instance( )->adjust_number_address( ).


  ENDMETHOD.

  METHOD create_address.

    CHECK : iv_numbering_mode = gs_constants-numbering_mode-early OR
                iv_numbering_mode = gs_constants-numbering_mode-late.

    CHECK it_address[] IS NOT INITIAL.

    DATA(ls_address) = VALUE #( it_address[ 1 ] OPTIONAL ).
    lcl_buffer_contact=>get_instance(  )->prepare_tran_buf_address(
      EXPORTING
        it_contaddr       = it_address
        it_contaddrx      = VALUE #( (
                        contact_id  = ls_address-contact_id
          address_id  = ls_address-address_id
          action_code = gs_constants-operation_action-create
        ) )
*        iv_numbering_mode = zcl_brt_data_contact=>gs_constants-numbering_mode-late
      IMPORTING
        et_contaddr       = et_address
        et_message        = et_message
    ).

    IF et_message IS INITIAL.
      lcl_buffer_contact=>get_instance( )->copy_b2a_address( ).
    ENDIF.


  ENDMETHOD.

  METHOD delete_address.

    lcl_buffer_contact=>get_instance(  )->prepare_tran_buf_address(
          EXPORTING
            it_contaddr       = it_address
            it_contaddrx      = it_addressx
*        iv_numbering_mode = zcl_brt_data_contact=>gs_constants-numbering_mode-late
          IMPORTING
*        et_contaddr       =
            et_message        = et_message
        ).
    IF et_message IS INITIAL.
      lcl_buffer_contact=>get_instance( )->copy_b2a_address( ).
    ENDIF.


  ENDMETHOD.

  METHOD initialize_address.

    lcl_buffer_contact=>get_instance( )->initialize_address( ).

  ENDMETHOD.

  METHOD process_message_address.

    ev_has_error = abap_false.
    LOOP AT it_messages INTO DATA(ls_message).
      IF ls_message-msgty = 'E' OR ls_message-msgty = 'A'.
        APPEND VALUE #(
          %cid = iv_cid
          contactid = iv_contact_id
       ) TO ct_failed.
        ct_report = VALUE #( BASE ct_report
           (
               %cid = iv_cid
               contactid = iv_contact_id
               %msg = new_message(
                        id       = ls_message-msgid
                        number   = ls_message-msgno
                        severity = if_abap_behv_message=>severity-error
                        v1       = ls_message-msgv1
                        v2       = ls_message-msgv2
                        v3       = ls_message-msgv3
                        v4       = ls_message-msgv4
                      )
           )
         ).
        ev_has_error = abap_true.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD read_address.

    CHECK it_contaddr_keys[] IS NOT INITIAL.

    "read address details
    lcl_buffer_contact=>get_instance(  )->read_address(
      EXPORTING
        it_contaddr_keys = VALUE #( FOR lwa_contaddr IN it_contaddr_keys
                                   ( contact_id = lwa_contaddr-contact_id
                                    address_id = lwa_contaddr-address_id
                                    address_sr = lwa_contaddr-address_sr ) )
      IMPORTING
        et_contaddr      = et_contaddr
        et_message       = et_message
    ).


  ENDMETHOD.

  METHOD save_address.

    lcl_buffer_contact=>get_instance( )->save_address( ).

  ENDMETHOD.

  METHOD update_address.

    lcl_buffer_contact=>get_instance(  )->prepare_tran_buf_address(
         EXPORTING
           it_contaddr       = it_address
           it_contaddrx      = it_addressx
           iv_numbering_mode = iv_numbering_mode
         IMPORTING
           et_contaddr       = et_address
           et_message        = et_message
       ).
    IF et_message IS INITIAL.
      lcl_buffer_contact=>get_instance( )->copy_b2a_address( ).
    ENDIF.

  ENDMETHOD.


ENDCLASS.
