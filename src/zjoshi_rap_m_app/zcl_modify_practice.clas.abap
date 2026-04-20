CLASS zcl_modify_practice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_modify_practice IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
*MODIFY ENTITY, ENTITIES, field_spec
*1->...  { FROM fields_tab }
*       CREATE, CREATE BY, UP☺DATE, DELETE, EXECUTE
*       For DELETE, EXECUTE we can use this option only
*       The %control structure must be filled explicitly in the internal table fields_tab for CREATE, CREATE BY and UPDATE
*    DATA : lt_book TYPE TABLE FOR CREATE yi_travel_tech_m\_Booking.

*    "craete" "create by"
*    DATA : lt_book TYPE TABLE FOR CREATE zi_travel_ma\_Booking.
*    MODIFY ENTITY zi_travel_ma
*     CREATE FROM VALUE #(
*               ( %cid = 'cid1'
*                 %data-BeginDate = '20260225'
*                 %control-BeginDate = if_abap_behv=>mk-on
*      ) )
*      CREATE BY \_Booking
*        FROM VALUE #( ( %cid_ref = 'cid1'
*                        %target  = VALUE #( ( %cid = 'cid11'
*                                              %data-bookingdate = '20240216'
*                                              %control-Bookingdate = if_abap_behv=>mk-on  ) )
* ) )
*       FAILED FINAL(it_failed)
*      MAPPED FINAL(it_mapped)
*      REPORTED FINAL(it_result).
*
*    IF it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

    "delete"

*    MODIFY ENTITY zi_travel_ma
*    DELETE FROM VALUE #( ( %key-TravelId = '0000004158'
*                            ) )
*     FAILED FINAL(it_failed1)
*      MAPPED FINAL(it_mapped1)
*      REPORTED FINAL(it_result1).
*    .
*    IF it_failed1 IS NOT INITIAL.
*      out->write( it_failed1 ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

*2->   | { AUTO FILL CID WITH fields_tab }
*    MODIFY ENTITY zi_travel_ma
*        CREATE AUTO FILL CID WITH VALUE #(
*                  (  %data-BeginDate = '20240229'
*                    %control-BeginDate = if_abap_behv=>mk-on
*
*         ) )
*            FAILED FINAL(it_failed)
*         MAPPED FINAL(it_mapped)
*         REPORTED FINAL(it_result).
*
*    IF it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

*3->   | { [AUTO FILL CID] FIELDS ( comp1 comp2 ... ) WITH fields_tab }

    MODIFY ENTITIES OF zi_travel_ma
     ENTITY zi_travel_ma
     UPDATE FIELDS ( BeginDate )
     WITH VALUE #( ( %key-TravelId = '0000004143'
                     BeginDate = '20250325' ) )
     ENTITY zi_travel_ma
     DELETE FROM VALUE #( ( TravelId = '0000004143' ) ) .
    COMMIT ENTITIES.
*    COMMIT ENTITIES.
*

  ENDMETHOD.

ENDCLASS.
