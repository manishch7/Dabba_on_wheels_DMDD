--drop role customer;

SET SERVEROUTPUT ON
/
BEGIN
  FOR audit_rec IN (select * from dba_roles where oracle_maintained = 'N')
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP ROLE ' || audit_rec.role;
      DBMS_OUTPUT.PUT_LINE('Dropped the role: ' || audit_rec.role);
      DBMS_OUTPUT.PUT_LINE('=======================================================');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping role ' || audit_rec.role || ': ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('=======================================================');
    END;
  END LOOP;
END;
/

--CREATES ROLES 

CREATE ROLE CUSTOMER;
CREATE ROLE MANAGER;
CREATE ROLE DELIVERY_PERSON;

-- Customer
-- grant permission to views
-------------------------------

GRANT SELECT ON POPULAR_MEAL_BY_SUBSCRIPTION_VIEW TO CUSTOMER;
/
GRANT SELECT ON CUSTOMER_CHOICE_BY_SEASON_VIEW TO CUSTOMER;

-- grant permission to procedures.
-----------------------------------------------------
grant execute on CUSTOMER_REGISTRATION_PROCEDURE to CUSTOMER; 

grant execute on ViewAllSubscriptionTypes to CUSTOMER; 

grant execute on PurchaseSubscription to CUSTOMER; 

grant execute on ViewAllMealTypes to CUSTOMER; 

grant execute on book_meal to CUSTOMER; 

grant execute on generate_invoice to CUSTOMER; 

grant execute on get_delivery_details to CUSTOMER; 

-----------------------------------------------------

-- Manager
--grant permission to views

GRANT SELECT ON POPULAR_MEAL_BY_SUBSCRIPTION_VIEW TO MANAGER;
/
GRANT SELECT ON REVENUE_VIEW TO MANAGER;
/
GRANT SELECT ON DELIVERY_SCHEDULE_VIEW TO MANAGER;
/
GRANT SELECT ON CUSTOMER_CHOICE_BY_SEASON_VIEW TO MANAGER;
/
GRANT SELECT ON  DELIVERY_DETAILS_VIEW TO MANAGER;
/
-----------------------------------------------------

-- grant permission to procedures.
-----------------------------------------------------
grant execute on ViewAllSubscriptionTypes to MANAGER; 

grant execute on add_or_update_subscription_type to MANAGER; 

grant execute on ViewAllMealTypes to MANAGER; 

grant execute on add_meal to MANAGER; 

grant execute on create_delivery_partner to MANAGER; 

grant execute on update_booking_delivery_partner to MANAGER; 

-----------------------------------------------------

-- Delivery Partner
--grant permission to procedures

------------------------------------------------------------
grant execute on view_pending_deliveries to DELIVERY_PERSON; 

grant execute on update_delivery_status to DELIVERY_PERSON; 

grant execute on update_delivery_partner to DELIVERY_PERSON; 

----------------------------------------------------

--- Grant roles for users
----------------------------------------------------
GRANT MANAGER TO MGR00001;
/
GRANT MANAGER TO MGR00002;
/
GRANT MANAGER TO MGR00003;
/
GRANT MANAGER TO MGR00004;

----------------------------------

GRANT CUSTOMER TO C00001;
/
GRANT CUSTOMER TO C00002;
/
GRANT CUSTOMER TO C00003;
/
GRANT CUSTOMER TO C00004;
------------------------------

GRANT DELIVERY_PERSON TO DP00001;
/
GRANT DELIVERY_PERSON TO DP00002;
/
GRANT DELIVERY_PERSON TO DP00003;
/
GRANT DELIVERY_PERSON TO DP00004;
/
--------------------------------------