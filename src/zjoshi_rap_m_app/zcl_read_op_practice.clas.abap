CLASS zcl_read_op_practice DEFINITION

  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_read_op_practice IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
*sort form read

**    READ ENTITY zi_travel_ma
**     FROM VALUE #( ( %key-TravelId = '00000002'
**                     %control = VALUE #( AgencyId    = if_abap_behv=>mk-on "on means provide values , off means only zero values"
**                                         customerid  = if_abap_behv=>mk-on
**                                         begindate   = if_abap_behv=>mk-on
**                                         )
**
**          )
**                    )
**     RESULT DATA(lt_result_short)
**     FAILED DATA(lt_failed_sort).
**
**    IF lt_failed_sort IS NOT INITIAL.
**      out->write( 'Read failed' ).
**
**    ELSE.
**      out->write( lt_result_short ).
**    ENDIF.

    "short form with all fields value syntex "

*    READ ENTITY zi_travel_ma
**    FIELDS ( AgencyId CustomerId )
**    WITH   VALUE #(  ( %key-TravelId = '00000002' ) )
*    ALL FIELDS WITH
*    VALUE #( ( %key-TravelId = '00000002' )
*              ( %key-TravelId = '00000003' ) )
***
*       RESULT DATA(lt_result_short)
*       FAILED DATA(lt_failed_sort).
*
*    IF lt_failed_sort IS NOT INITIAL.
*      out->write( 'Read failed' ).
*
*    ELSE.
*      out->write( lt_result_short ).
*    ENDIF.
*
    "Short form by association "

*    READ ENTITY zi_travel_ma
*   BY \_Booking
*    ALL FIELDS WITH
*    VALUE #( ( %key-TravelId = '00000002' )
*              ( %key-TravelId = '00000003' ) )
*
*       RESULT DATA(lt_result_short)
*       FAILED DATA(lt_failed_sort).
*
*    IF lt_failed_sort IS NOT INITIAL.
*      out->write( 'Read failed' ).
*
*    ELSE.
*      out->write( lt_result_short ).
*    ENDIF.


    ""Long form to read multiple entites "

*
    """Dyanmic Read Operation with single entity "

*    DATA: it_optab         TYPE abp_behv_retrievals_tab,
*          it_travel        TYPE TABLE FOR READ IMPORT yi_travel_tech_m,
*          it_travel_result TYPE TABLE FOR READ RESULT  yi_travel_tech_m.
*
*    it_travel = VALUE #( ( %key-TravelId = '0000000001'
*                    %control = VALUE #( AgencyId    = if_abap_behv=>mk-on
*                                       customerid  = if_abap_behv=>mk-on
*                                       begindate   = if_abap_behv=>mk-on
*                                    ) ) ).
*
*    it_optab = VALUE #( ( op = if_abap_behv=>op-r-read
*                               entity_name = 'YI_TRAVEL_TECH_M'
*                               instances = REF #( it_travel )
*                               results  = REF #( it_travel_result )  ) ).
*
*    READ ENTITIES
*OPERATIONS it_optab
*FAILED DATA(lt_failed_dy).
*
*    IF lt_failed_dy IS NOT INITIAL.
*      out->write( 'Read failed' ).
*
*    ELSE.
*      out->write( it_travel_result ).
**      out->write( it_booking_result ).
*    ENDIF.
*
*
*  ENDMETHOD.

    "'Dynamic read operation b association ""


    DATA: it_optab          TYPE abp_behv_retrievals_tab,
          it_travel         TYPE TABLE FOR READ IMPORT yi_travel_tech_m,
          it_travel_result  TYPE TABLE FOR READ RESULT  yi_travel_tech_m,
          it_booking        TYPE TABLE FOR READ IMPORT yi_travel_tech_m\_Booking,
          it_booking_result TYPE TABLE FOR READ RESULT yi_travel_tech_m\_Booking.


    it_travel = VALUE #( ( %key-TravelId = '0000000001'
                    %control = VALUE #( AgencyId    = if_abap_behv=>mk-on
                                       customerid  = if_abap_behv=>mk-on
                                       begindate   = if_abap_behv=>mk-on
                                    ) ) ).

    it_booking = VALUE #( ( %key-TravelId = '0000000002'
%control = VALUE #(
BookingDate = if_abap_behv=>mk-on
BookingStatus = if_abap_behv=>mk-on
BookingId =  if_abap_behv=>mk-on
) ) ).

    it_optab = VALUE #( ( op = if_abap_behv=>op-r-read
                               entity_name = 'YI_TRAVEL_TECH_M'
                               instances = REF #( it_travel )
                               results  = REF #( it_travel_result )  )

                           ( op = if_abap_behv=>op-r-read_ba
                          entity_name = 'YI_TRAVEL_TECH_M'
                          sub_name  = '_BOOKING'
                          instances = REF #( it_booking )
                          results  = REF #( it_booking_result )
                            ) ).

    READ ENTITIES
OPERATIONS it_optab
FAILED DATA(lt_failed_dy).

    IF lt_failed_dy IS NOT INITIAL.
      out->write( 'Read failed' ).

    ELSE.
      out->write( it_travel_result ).
      out->write( it_booking_result ).
    ENDIF.


  ENDMETHOD.


ENDCLASS.
