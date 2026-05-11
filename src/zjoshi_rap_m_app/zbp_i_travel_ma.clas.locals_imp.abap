CLASS lsc_zi_travel_ma DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_ma IMPLEMENTATION.

  METHOD save_modified.

    DATA : lt_travel_log TYPE STANDARD TABLE OF zilog_table.
    DATA : lt_travel_log_c TYPE STANDARD TABLE OF zilog_table.
    DATA : lt_travel_log_u TYPE STANDARD TABLE OF zilog_table.

    IF  create-zi_travel_ma IS NOT INITIAL.

      lt_travel_log = CORRESPONDING #( create-zi_travel_ma ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).

        <ls_travel_log>-changing_operation = 'CREATE'.
        GET TIME STAMP FIELD <ls_travel_log>-created_at.

        READ TABLE create-zi_travel_ma  ASSIGNING FIELD-SYMBOL(<ls_travel>)
                                 WITH TABLE KEY entity
                                 COMPONENTS TravelId = <ls_travel_log>-travelid.
        IF sy-subrc IS INITIAL.

          IF <ls_travel>-%control-BookingFee = cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'Booking Fee'.
            <ls_travel_log>-changed_value  = <ls_travel>-BookingFee.
            TRY.
                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_c.

          ENDIF.
          IF <ls_travel>-%control-OverallStatus = cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'Overall Status'.
            <ls_travel_log>-changed_value  = <ls_travel>-OverallStatus.
            TRY.
                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_c.

          ENDIF.

        ENDIF.
      ENDLOOP.
      INSERT  zilog_table FROM TABLE @lt_travel_log_c.
    ENDIF.

    IF  update-zi_travel_ma IS NOT INITIAL.
      lt_travel_log = CORRESPONDING #( update-zi_travel_ma ).

      LOOP AT update-zi_travel_ma ASSIGNING FIELD-SYMBOL(<ls_log_update>).
        ASSIGN lt_travel_log[ travelid = <ls_log_update>-travelid ] TO FIELD-SYMBOL(<ls_log_u>).

        <ls_log_u>-changing_operation = 'UPDATE'.
        GET TIME STAMP FIELD <ls_log_u>-created_at.

        IF <ls_log_update>-%control-customerid = if_abap_behv=>mk-on.
          <ls_log_u>-changed_value = <ls_log_update>-customerid.
          TRY.
              <ls_log_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
            CATCH cx_uuid_error.
          ENDTRY.
          <ls_log_u>-changed_field_name = 'customer_id'.
          APPEND <ls_log_u> TO lt_travel_log_u.
        ENDIF.

        IF <ls_log_update>-%control-description = if_abap_behv=>mk-on.
          <ls_log_u>-changed_value = <ls_log_update>-description.
          TRY.
              <ls_log_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
            CATCH cx_uuid_error.
          ENDTRY.
          <ls_log_u>-changed_field_name = 'description'.
          APPEND <ls_log_u> TO lt_travel_log_u.
        ENDIF.
      ENDLOOP.
      INSERT zilog_table FROM TABLE @lt_travel_log_u.
    ENDIF.


    IF  delete-zi_travel_ma IS NOT INITIAL.

      lt_travel_log = CORRESPONDING #( delete-zi_travel_ma ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_log_del>).
        <ls_log_del>-changing_operation = 'DELETE'.
        GET TIME STAMP FIELD <ls_log_del>-created_at.
        TRY.
            <ls_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static( ) .
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

      " Inserts rows specified in lt_travel_log into the DB table /dmo/log_travel
      INSERT zilog_table  FROM TABLE @lt_travel_log.

    ENDIF.

    "unmanaged save for booking suppl"

    DATA: lt_book_suppl TYPE STANDARD TABLE OF zjbooking_supp_m.
    IF create-zi_bookingsuppl_ma IS NOT INITIAL.

      lt_book_suppl = VALUE #( FOR ls_booksup IN  create-zi_bookingsuppl_ma (
                                           travel_id  = ls_booksup-TravelId
                                           booking_id = ls_booksup-BookingId
                                           booking_supplement_id  = ls_booksup-BookingSupplementId
                                           supplement_id   = ls_booksup-SupplementId
                                           price   = ls_booksup-Price
                                           currency_code    = ls_booksup-CurrencyCode
                                           last_changed_at = ls_booksup-LastChangedAt
                                             )  ).

      INSERT zjbooking_supp_m FROM TABLE @lt_book_suppl.

    ENDIF.
    IF update-zi_bookingsuppl_ma IS NOT INITIAL.

      lt_book_suppl = VALUE #( FOR ls_booksup IN  update-zi_bookingsuppl_ma (
                                        travel_id  = ls_booksup-TravelId
                                        booking_id = ls_booksup-BookingId
                                        booking_supplement_id  = ls_booksup-BookingSupplementId
                                        supplement_id   = ls_booksup-SupplementId
                                        price   = ls_booksup-Price
                                        currency_code    = ls_booksup-CurrencyCode
                                        last_changed_at = ls_booksup-LastChangedAt
                                          )  ).


      UPDATE zjbooking_supp_m FROM TABLE @lt_book_suppl.

    ENDIF.
    IF delete-zi_bookingsuppl_ma IS NOT INITIAL.

      lt_book_suppl = VALUE #( FOR ls_del IN  delete-zi_bookingsuppl_ma (
                                         travel_id  = ls_del-TravelId
                                         booking_id = ls_del-BookingId
                                         booking_supplement_id  = ls_del-BookingSupplementId
                                           )  ).

      DELETE zjbooking_supp_m FROM TABLE @lt_book_suppl.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

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

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_ma RESULT result.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_ma~validatebookingfee.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_ma~validatecurrencycode.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_ma~validatecustomer.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_ma~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_ma~validatestatus.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_ma~calculatetotalprice.

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

    MODIFY ENTITIES OF zi_travel_ma IN LOCAL MODE
   ENTITY zi_travel_ma
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                        OverallStatus = 'A' ) ).

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
    ENTITY zi_travel_ma
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .

    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).

  ENDMETHOD.

  METHOD copyTravel.

    DATA : lt_travel   TYPE TABLE FOR CREATE zi_travel_ma,
           lt_booking  TYPE TABLE FOR CREATE zi_travel_ma\_Booking,
           lt_booksupp TYPE TABLE FOR CREATE zi_booking_ma\_Suppl.

    "fisrt we need to check cid is intial or not" it shoud not be filled "
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_without_cid>) WITH KEY %cid = ' '.
    ASSERT <ls_without_cid> IS NOT ASSIGNED.

    "now we are reading three mapped tables"
    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
    ENTITY zi_travel_ma
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travle_r)
    FAILED DATA(lt_travel_f).

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
   ENTITY zi_travel_ma BY \_Booking
   ALL FIELDS WITH CORRESPONDING #( lt_travle_r )
   RESULT DATA(lt_booking_r).

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
       ENTITY zi_booking_ma BY \_Suppl
       ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
       RESULT DATA(lt_bookingsupp_r).

    "looping internal and assign to another table "
    LOOP AT lt_travle_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).

      "appending travel data"
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <ls_travel_r>-TravelId ]-%cid
                      %data = CORRESPONDING #( <ls_travel_r> EXCEPT Travelid ) )
                      TO lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      "after copy , some fields want to be chnaged " "getting system varibles by method"
      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date(  ) + 30.
      <ls_travel>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref = <ls_travel>-%cid )
      TO lt_booking ASSIGNING FIELD-SYMBOL(<lt_booking>)
  .
      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>)
                                  USING KEY entity
                                  WHERE TravelId = <ls_travel_r>-TravelId.
        "appending booking data (travel cid and trget)

        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId  "concatnate"
                        %data = CORRESPONDING #( <ls_booking_r> EXCEPT Travelid ) )
                        TO <lt_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_n>).

        "modifiny the booking status as new"
        <ls_booking_n>-BookingStatus = 'N'.

        APPEND VALUE #( %cid_ref = <ls_travel>-%cid )
      TO lt_booksupp ASSIGNING FIELD-SYMBOL(<lt_bookingsupp>) .

        "looping and appending for booking supp"
        LOOP AT lt_bookingsupp_r ASSIGNING FIELD-SYMBOL(<ls_booksuppl_r>)
                                        USING KEY entity
                                        WHERE TravelId = <ls_travel_r>-TravelId
                                        AND BookingId = <ls_booking_r>-BookingId.
          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId && <ls_booksuppl_r>-BookingSupplementId
                          %data = CORRESPONDING #( <ls_booksuppl_r> EXCEPT Travelid  BookingId ) )
                          TO <lt_bookingsupp>-%target.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    "creating new bo instance by using modify stat"
    MODIFY ENTITIES OF zi_travel_ma IN LOCAL MODE
    ENTITY zi_travel_ma
    CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
    WITH lt_travel
    ENTITY zi_travel_ma
    CREATE BY \_Booking
    FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
    WITH lt_booking
    ENTITY zi_booking_ma
    CREATE BY \_Suppl
    FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
    WITH lt_booksupp
    MAPPED DATA(lt_mapp_data).

    "need to assign the mapped data to Bd mapped table"
    mapped-zi_travel_ma = lt_mapp_data-zi_travel_ma.




  ENDMETHOD.

  METHOD recalcTotPrice.

    TYPES : BEGIN OF ty_total,
              price TYPE /dmo/total_price,
              curr  TYPE /dmo/currency_code,
            END OF ty_total .
    DATA: lt_total      TYPE TABLE OF ty_total,
          lv_conv_price TYPE ty_total-price.
*☺

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
     ENTITY zi_travel_ma
     FIELDS ( BookingFee CurrencyCode )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    DELETE lt_travel WHERE CurrencyCode IS INITIAL.

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
     ENTITY zi_travel_ma BY \_Booking
     FIELDS ( FlightPrice CurrencyCode )
     WITH CORRESPONDING #( lt_travel )
     RESULT DATA(lt_ba_booking).

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
     ENTITY zi_booking_ma BY \_suppl
     FIELDS ( Price CurrencyCode )
     WITH CORRESPONDING #( lt_ba_booking )
     RESULT DATA(lt_ba_booksuppl).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      lt_total =  VALUE #( ( price = <ls_travel>-BookingFee curr = <ls_travel>-CurrencyCode ) ).

      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<ls_booking>)
                                 USING KEY entity
                                  WHERE TravelId = <ls_travel>-TravelId
                                  AND CurrencyCode IS NOT INITIAL.

        APPEND VALUE #( price = <ls_booking>-FlightPrice curr = <ls_booking>-CurrencyCode )
           TO lt_total.

        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<ls_booksuppl>)
                                          USING KEY entity
                                          WHERE TravelId = <ls_booking>-TravelId
                                           AND  BookingId = <ls_booking>-BookingId
                                            AND CurrencyCode IS NOT INITIAL..
          APPEND VALUE #( price = <ls_booksuppl>-Price curr = <ls_booksuppl>-CurrencyCode )
           TO lt_total.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<ls_total>).

        IF <ls_total>-curr = <ls_travel>-CurrencyCode.
          lv_conv_price = <ls_total>-price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <ls_total>-price
              iv_currency_code_source = <ls_total>-curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   =  cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_conv_price
          ).

        ENDIF.

        <ls_travel>-TotalPrice =  <ls_travel>-TotalPrice + lv_conv_price.
      ENDLOOP.


    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_ma IN LOCAL MODE
    ENTITY zi_travel_ma
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel ).

    .
  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zi_travel_ma IN LOCAL MODE
  ENTITY zi_travel_ma
   UPDATE FIELDS ( OverallStatus )
   WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                       OverallStatus = 'X' ) ).

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
    ENTITY zi_travel_ma
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .

    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).

  ENDMETHOD.

  METHOD get_instance_features.

    "reading "

    READ ENTITIES OF  zi_travel_ma IN LOCAL MODE
  ENTITY zi_travel_ma
  FIELDS ( TravelId OverallStatus )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_travel).

    result  = VALUE #( FOR ls_travel IN lt_travel
                        (  %tky = ls_travel-%tky
                           %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                           %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                           %features-%assoc-_Booking  = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                                                                     )
                   ).

  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITY  IN LOCAL MODE zi_travel_ma
     FIELDS ( CustomerId )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId  ).
    DELETE lt_cust WHERE customer_id IS INITIAL.
    SELECT
     FROM /dmo/customer
     FIELDS customer_id
     FOR ALL ENTRIES IN @lt_cust
     WHERE customer_id = @lt_cust-customer_id
     INTO TABLE @DATA(lt_cust_db).
    IF sy-subrc IS INITIAL.

    ENDIF.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL
         OR  NOT line_exists( lt_cust_db[ customer_id = <ls_travel>-CustomerId  ] )   .

        APPEND VALUE #( %tky = <ls_travel>-%tky )
                   TO failed-zi_travel_ma.
        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                            textid                = /dmo/cm_flight_messages=>customer_unkown
                                           customer_id           = <ls_travel>-CustomerId
                                severity              = if_abap_behv_message=>severity-error
                                )
                        %element-CustomerId = if_abap_behv=>mk-on

        )
                   TO reported-zi_travel_ma.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
               ENTITY zi_travel_ma
                 FIELDS ( BeginDate EndDate )
                 WITH CORRESPONDING #( keys )
               RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(travel).

      IF travel-EndDate < travel-BeginDate.  "end_date before begin_date

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zi_travel_ma.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = travel-BeginDate
                                   end_date   = travel-EndDate
                                   travel_id  = travel-TravelId )
                        %element-BeginDate   = if_abap_behv=>mk-on
                        %element-EndDate     = if_abap_behv=>mk-on
                     ) TO reported-zi_travel_ma.

      ELSEIF travel-BeginDate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future

        APPEND VALUE #( %tky        = travel-%tky ) TO failed-zi_travel_ma.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                    textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                    severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate  = if_abap_behv=>mk-on
                        %element-EndDate    = if_abap_behv=>mk-on
                      ) TO reported-zi_travel_ma.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF zi_travel_ma IN LOCAL MODE
          ENTITY zi_travel_ma
            FIELDS ( OverallStatus )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travel).
      CASE ls_travel-OverallStatus.
        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted

        WHEN OTHERS.
          APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-zi_travel_ma.

          APPEND VALUE #( %tky = ls_travel-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                     textid = /dmo/cm_flight_messages=>status_invalid
                                     severity = if_abap_behv_message=>severity-error
                                     status = ls_travel-OverallStatus )
                          %element-OverallStatus = if_abap_behv=>mk-on
                        ) TO reported-zi_travel_ma.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zi_travel_ma IN LOCAL MODE
    ENTITY zi_travel_ma
    EXECUTE  recalctotprice
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.
