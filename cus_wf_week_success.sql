-- Customer procedure executions 

-- procedure 1 execution
DECLARE
    v_name VARCHAR2(50) := 'Jaswanth marri';
    v_dob DATE := TO_DATE('1998-11-24', 'YYYY-MM-DD');
    v_gender VARCHAR2(40) := 'male';
    v_email VARCHAR2(50) := 'marri@email.com';
    v_phone_number NUMBER := 1234569860;
    v_street_address VARCHAR2(50) := '123 Main St';
    v_city VARCHAR2(20) := 'Cityville';
    v_state VARCHAR2(20) := 'CA';
    v_zipcode NUMBER := 12345;
    v_customer_id NUMBER;
BEGIN
    CUSTOMER_REGISTRATION_PROCEDURE(
        p_name => v_name,
        p_dob => v_dob,
        p_gender => v_gender,
        p_email => v_email,
        p_phone_number => v_phone_number,
        p_street_address => v_street_address,
        p_city => v_city,
        p_state => v_state,
        p_zipcode => v_zipcode,
        o_customer_id => v_customer_id
    );
END;
/

-- procedure 2 execution
SET SERVEROUTPUT ON;
BEGIN
    ViewAllSubscriptionTypes;
END;
/

-- procedure 3 execution
set serveroutput on
DECLARE
   v_customer_id NUMBER := CUSTOMER_SEQ.CURRVAL; -- Replace with the actual customer ID
   v_subscription_type VARCHAR2(10) := 'WEEKLY'; -- Replace with the desired subscription type
   v_payment_amount NUMBER := 50; -- Replace with the desired payment amount
BEGIN
   PurchaseSubscription(v_customer_id, v_subscription_type, v_payment_amount);
END;
/

-- procedure 4 execution

SET SERVEROUTPUT ON;

BEGIN
    ViewAllMealTypes;
END;
/

-- procedure 5 execution

SET SERVEROUTPUT ON;
DECLARE
  v_customer_id    NUMBER := CUSTOMER_SEQ.CURRVAL; -- Provide the customer ID here
  v_meal_type      VARCHAR2(10) := 'HALaL'; -- Provide the meal type here
  v_time_slot      VARCHAR2(10) := 'afterNoon'; -- Provide the time slot here
  v_delivery_date  DATE := sysdate + 2;  --TO_DATE('2023-12-15', 'YYYY-MM-DD'); -- Provide the delivery date here
BEGIN
  book_meal(v_customer_id, v_meal_type, v_time_slot, v_delivery_date);
END;
/
-- procedure 6 execution
SET SERVEROUTPUT ON;
DECLARE
  v_customer_id NUMBER := CUSTOMER_SEQ.CURRVAL; -- Provide the customer ID here
BEGIN
  generate_invoice(v_customer_id);
END;
/

-- procedure 7 execution

SET SERVEROUTPUT ON;
DECLARE
  v_customer_id NUMBER := CUSTOMER_SEQ.CURRVAL; -- Provide the customer ID here
BEGIN
  get_delivery_details(v_customer_id);
END;
/

-- procedure 8 execution
-- Update only the customer's email
EXEC update_customer_details(p_customer_id => CUSTOMER_SEQ.CURRVAL, p_email => 'abc@email.com');

-- Update both name and phone number
EXEC update_customer_details(p_customer_id => CUSTOMER_SEQ.CURRVAL, p_name => 'Updated Name', p_phone_number => 9876159621);

