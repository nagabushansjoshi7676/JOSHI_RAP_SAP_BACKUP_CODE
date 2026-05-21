CLASS zcl_aux_contact_u DEFINITION
  PUBLIC
  FINAL
   CREATE PUBLIC INHERITING FROM cl_abap_behv.

  PUBLIC SECTION.

    TYPES : BEGIN OF ls_contact_key,
              contact_id TYPE zjo_contact-contact_id,
            END OF ls_contact_key.

    TYPES : BEGIN OF lty_contact_intx,

              contact_id  TYPE zjo_contact-contact_id,
              action_code TYPE c LENGTH 1,
              _intx       TYPE zjo_s_contact,

            END OF lty_contact_intx.

    TYPES : gty_contact_u    TYPE zjo_contact,
            gtt_contact_u    TYPE TABLE OF zjo_contact,
            gtt_contact_intx TYPE TABLE OF lty_contact_intx,
            gtt_contact_keys TYPE TABLE OF ls_contact_key,
            gtt_message      TYPE TABLE OF symsg.

    TYPES : gtt_failed_contact   TYPE TABLE FOR FAILED EARLY zi_contact_u\\zi_contact_u,
            gtt_reported_contact TYPE TABLE FOR REPORTED EARLY zi_contact_u\\zi_contact_u.


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

    METHODS : create_contact
      IMPORTING is_contact        TYPE gty_contact_u
                iv_numbering_mode TYPE c DEFAULT gs_constants-numbering_mode-late
      EXPORTING es_contact        TYPE gty_contact_u
                et_message        TYPE gtt_message.

    METHODS : process_messages
      IMPORTING iv_cid        TYPE abp_behv_cid OPTIONAL
                iv_contact_id TYPE zjo_contact-contact_id OPTIONAL
                it_messages   TYPE gtt_message
      EXPORTING ev_has_error  TYPE abap_boolean
      CHANGING  ct_failed     TYPE gtt_failed_contact
                ct_report     TYPE gtt_reported_contact.


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
ENDCLASS.
