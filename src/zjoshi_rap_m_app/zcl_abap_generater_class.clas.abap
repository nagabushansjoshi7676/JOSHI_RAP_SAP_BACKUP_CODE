
CLASS zcl_abap_generater_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abap_generater_class IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " delete existing entries in the database table

    DELETE FROM zjtravel_m.

    DELETE FROM zjbooking_m.

    DELETE FROM zjbooking_supp_m.

    COMMIT WORK.
    " insert travel demo data
    INSERT zjtravel_m FROM (
        SELECT *

          FROM /dmo/travel_m

      ).

    COMMIT WORK.


    " insert booking demo data

    INSERT zjbooking_m FROM (

        SELECT *

          FROM   /dmo/booking_m

*            JOIN ztravel_tech_m AS z

*            ON   booking~travel_id = z~travel_id

      ).

    COMMIT WORK.

    INSERT zjbooking_supp_m FROM (

        SELECT *

          FROM   /dmo/booksuppl_m

*            JOIN ztravel_tech_m AS z

*            ON   booking~travel_id = z~travel_id
      ).

    COMMIT WORK.

    out->write( 'Travel and booking demo data inserted.' ).

  ENDMETHOD.

ENDCLASS.

