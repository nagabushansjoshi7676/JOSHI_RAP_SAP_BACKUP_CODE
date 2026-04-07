CLASS lhc_ZI_TRAVEL_MA DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_ma RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_ma RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ma~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ma~copytravel.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ma~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_ma~rejecttravel RESULT result.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_ma\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_ma.

ENDCLASS.

CLASS lhc_ZI_TRAVEL_MA IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.  "it meant for avoiding duplicates and work like number range and it will trigger first//

    DATA(lt_entities) = entities. "entites has table field and values storing into one internal table "

    DELETE lt_entities WHERE TravelId IS NOT INITIAL. "here deleting if some exist values are there"

    TRY.
        cl_numberrange_runtime=>number_get(    "method will generte the number automatically in squenece way"
          EXPORTING
            nr_range_nr       = '01'            "start number"
            object            = '/DMO/TRV_M'    "standard number range "
            quantity          = CONV #( lines( lt_entities ) )  "how much travel id's you want , we are converting due to Numc datatype"
          IMPORTING
            number            =  DATA(lv_latest_num)
            returncode        =  DATA(lv_code)
            returned_quantity =  DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
        "here looping data and getting failed id and reporting in msg way"
        LOOP AT lt_entities  INTO DATA(ls_entities).
          APPEND VALUE #( %cid =  ls_entities-%cid
                          %key = ls_entities-%key  )
                 TO failed-zi_travel_ma.
          APPEND VALUE #( %cid =  ls_entities-%cid
                          %key = ls_entities-%key
                          %msg =  lo_error )
                 TO reported-zi_travel_ma.

        ENDLOOP.
        EXIT.
    ENDTRY.

    ASSERT lv_qty = lines( lt_entities ). "confimining both are same"

    DATA(lv_curr_num)   =  lv_latest_num - lv_qty.

    LOOP AT lt_entities  INTO ls_entities.

      lv_curr_num = lv_curr_num + 1.
*      ls_travel_tech_m = VALUE #( %cid =  ls_entities-%cid
*                                  TravelId = lv_curr_num
*       )
*      APPEND ls_travel_tech_m TO mapped-yi_travel_tech_m.

      APPEND VALUE #( %cid =  ls_entities-%cid
                      TravelId = lv_curr_num  )
               TO mapped-zi_travel_ma.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA : lv_max_booking TYPE /dmo/booking_id.  "to know max booking id"

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE  "local mode read will skip the authorization"
     ENTITY zi_travel_ma BY \_Booking  "reading booking data on travle id"
     FROM CORRESPONDING #( entities )
     LINK DATA(lt_link_data). "link data means insted getting all data as result , we can get only data which is on travle id"

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
                           GROUP BY <ls_group_entity>-TravelId .


      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                 FOR ls_link IN lt_link_data USING KEY entity
                                      WHERE ( source-TravelId = <ls_group_entity>-TravelId  )
                                 NEXT  lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                                                                       THEN ls_link-target-BookingId
                                                                        ELSE lv_max ) ).
      lv_max_booking  = REDUCE #( INIT lv_max = lv_max_booking
                                   FOR ls_entity IN entities USING KEY entity
                                       WHERE ( TravelId = <ls_group_entity>-TravelId  )
                                     FOR ls_booking IN ls_entity-%target
                                     NEXT lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
                                                                        THEN ls_booking-BookingId
                                                                         ELSE lv_max )
       ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
                        USING KEY entity
                         WHERE TravelId = <ls_group_entity>-TravelId.

        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).
          APPEND CORRESPONDING #( <ls_booking> )  TO   mapped-zi_booking_ma
             ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
          IF <ls_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.

            <ls_new_map_book>-BookingId = lv_max_booking.
          ENDIF.

        ENDLOOP.


      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.
  ENDMETHOD.

  METHOD copyTravel.
  ENDMETHOD.

  METHOD recalcTotPrice.
  ENDMETHOD.

  METHOD rejectTravel.
  ENDMETHOD.

ENDCLASS.
