-- Customer workflow 
---------------------------------------------------------------------------------
-- 1. CUSTOMER_REGISTRATION_PROCEDURE
-- input: name, dob, gender, email, phone, street_address, city, state, zipcode
-- output: prints customer id on successful customer creation
-- exception: throws exception various cases like email or phone is null or not
--valid, if the colum level constraints are iolated, etc..

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE CUSTOMER_REGISTRATION_PROCEDURE (
    p_name            IN VARCHAR2,
    p_dob             IN DATE,
    p_gender          IN VARCHAR2,
    p_email           IN VARCHAR2,
    p_phone_number    IN NUMBER,
    p_street_address  IN VARCHAR2,
    p_city            IN VARCHAR2,
    p_state           IN VARCHAR2,
    p_zipcode         IN NUMBER,
    o_customer_id     OUT NUMBER
) IS
    v_loc_id   NUMBER;
    v_c_id     NUMBER;
    v_email_exists EXCEPTION;
    v_email_count number;
    v_phone_exists EXCEPTION;
    v_phone_count number;
    EXC_PHONE_NUMBER EXCEPTION;
    EXC_GENDER EXCEPTION;
    EXC_EMAIL EXCEPTION;
    EXC_STREET EXCEPTION;
    EXC_CITY EXCEPTION;
    EXC_STATE EXCEPTION;
    EXC_ZIP EXCEPTION;
    v_email_pattern VARCHAR2(100) := '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$';
    EXC_VALID_EMAIL EXCEPTION;
BEGIN

 -- Check if the provided phone number  not equal to 10 digits
IF p_phone_number is null or length(p_phone_number) =0 
    or length(p_phone_number) != 10 THEN
        RAISE EXC_PHONE_NUMBER;
    END IF;
     -- Check if the provided gender greater than 10 characters

    IF length(p_gender) > 10 THEN
        RAISE EXC_GENDER;
    END IF;
     -- Check if the provided email greater than 50 characters
IF p_email is null or length(p_email) =0 or length(p_email) > 50 THEN
        RAISE EXC_EMAIL;
    END IF;

   IF NOT REGEXP_LIKE(p_email, v_email_pattern) THEN
      -- Raise an exception with a custom error message
      RAISE EXC_VALID_EMAIL;
   END IF;
   
     -- Check if the provided address greater than 50 characters
IF p_street_address is null or length(p_street_address) =0 or length(p_street_address) > 50 THEN
        RAISE EXC_STREET;
    END IF;
     -- Check if the provided city greater than 20 characters
IF p_city is null or length(p_city) =0 or length(p_city) > 20 THEN
        RAISE EXC_CITY;
    END IF;
     -- Check if the provided state greater than 20 characters
IF p_state is null or length(p_state) =0 or length(p_state) > 20 THEN
        RAISE EXC_STATE;
    END IF;
         -- Check if the provided zipcode is not equal to 5 digits
    IF p_zipcode is null or length(p_zipcode) =0 or length(p_zipcode) != 5 THEN
        RAISE EXC_ZIP;
    END IF;
    
    -- Check if the provided email already exists

        SELECT count(*) INTO v_email_count FROM CUSTOMER WHERE c_email = p_email;
        -- If the email exists, raise an exception
        if v_email_count>0 THEN
            RAISE v_email_exists;
        end if;

    -- Check if the provided phone number already exists
        SELECT count(*) INTO v_phone_count FROM CUSTOMER 
        WHERE c_phone_number = p_phone_number;
        
        -- If the phone number exists, raise an exception
       if v_phone_count>0 THEN
            RAISE v_phone_exists;
        end if;

    -- Check if the location already exists
    SELECT loc_id INTO v_loc_id FROM LOCATION WHERE street_address = p_street_address
      AND city = p_city AND state = p_state AND zipcode = p_zipcode;

    -- If location doesn't exist, create a new location record
    IF v_loc_id IS NULL THEN
        INSERT INTO LOCATION (loc_id, street_address, city, state, zipcode)
        VALUES (LOCATION_SEQ.NEXTVAL, p_street_address, p_city, p_state, p_zipcode);

        -- Retrieve the newly created location ID
        SELECT LOCATION_SEQ.CURRVAL INTO v_loc_id FROM DUAL;
    END IF;

    -- Create a new customer record
    INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, c_email, c_phone_number)
    VALUES (CUSTOMER_SEQ.NEXTVAL, v_loc_id, p_name, p_dob, 
    p_gender, p_email, p_phone_number)
    RETURNING c_id INTO v_c_id;

    -- Set the output parameter with the customer ID
    o_customer_id := v_c_id;
    COMMIT;
    -- Print the customer ID or use it as needed
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || v_c_id);
EXCEPTION
    WHEN v_email_exists THEN
        DBMS_OUTPUT.PUT_LINE('Error: Email already exists.');
    WHEN v_phone_exists THEN
        DBMS_OUTPUT.PUT_LINE('Error: Phone number already exists.');
    WHEN EXC_PHONE_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Mobile phone number cant be null and should be 10 digit number');
    WHEN EXC_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('email cant be null and should not be more than 50 characters');
    WHEN EXC_VALID_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('Invalid email format. Please provide a valid email.');
    WHEN EXC_GENDER THEN
        DBMS_OUTPUT.PUT_LINE('gender should not be more than 10 characters');
    WHEN EXC_STREET THEN
        DBMS_OUTPUT.PUT_LINE('street address is required and should not be more than 50 characters');
    WHEN EXC_CITY THEN
        DBMS_OUTPUT.PUT_LINE('city is required and should not be more than 20 characters');
    WHEN EXC_STATE THEN
        DBMS_OUTPUT.PUT_LINE('state is required and should not be more than 50 characters');
    WHEN EXC_ZIP THEN
        DBMS_OUTPUT.PUT_LINE('zipcode is required and should be equal 5 digit number');
   WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: An unexpected error occurred.' || SQLERRM);
END CUSTOMER_REGISTRATION_PROCEDURE;
/

-- 2. ViewAllSubscriptionTypes
-- input: None
-- output: displays all the subscription types available in the system.
-- exception: None
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ViewAllSubscriptionTypes IS
BEGIN
    FOR sub_type_rec IN (
        SELECT sub_type_id, type, price, meal_count
        FROM subscription_type
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Type: ' || sub_type_rec.type ||', Price: ' || sub_type_rec.price ||
            ', Meal Count: ' || sub_type_rec.meal_count);
    END LOOP;
END ViewAllSubscriptionTypes;
/

-- 3. PurchaseSubscription
-- INPUT : customer id, subscription type, payment amount
-- OUTPUT: payment is recorded and enrolled for subscription
-- DESCRIPTION AND EXCEPTIONS: checks if customer exisits in system or not, 
-- creates subscription only if there is an active subscription and meal count 
-- is greater than 0 else need to use the current subscription for meal booking,
-- checks if subscription type amount equal to payment amount only then
-- transaction carries forward else need to retry
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE PurchaseSubscription(
    p_customer_id IN NUMBER,
    p_subscription_type IN VARCHAR2,
    p_payment_amount IN NUMBER
) IS
    v_subscription_price NUMBER;
    v_subscription_type_id NUMBER;
    v_subscription_meal_count NUMBER;
    EXC_INV_SUB_TYPE EXCEPTION;
    EXC_INV_AMT EXCEPTION;
    EXC_CUS_NOT_EXISTS EXCEPTION;
    EXC_SUB_EXISTS EXCEPTION;
    v_sub_exists_count number;
    v_end_date date;
    v_customer_exists_count number;
BEGIN
    -- Retrieve subscription type ID based on the provided subscription type
    SELECT sub_type_id INTO v_subscription_type_id
    FROM subscription_type
    WHERE type = p_subscription_type;

    -- Check if the subscription type exists
    IF v_subscription_type_id IS NOT NULL THEN
        -- Retrieve subscription price based on the subscription type
        SELECT price INTO v_subscription_price
        FROM subscription_type
        WHERE sub_type_id = v_subscription_type_id;
        
        -- Retrieve meal count based on the subscription type
        SELECT meal_count INTO v_subscription_meal_count
        FROM subscription_type
        WHERE sub_type_id = v_subscription_type_id;

        -- Check if the payment amount matches the subscription price
        
        select count(*) into v_customer_exists_count from customer 
        where c_id = p_customer_id;
        
        if v_customer_exists_count = 0 then
        raise EXC_CUS_NOT_EXISTS;
        end if;

        SELECT count(s.sub_id) into v_sub_exists_count FROM customer c 
        JOIN subscription s ON c.c_id = s.c_id 
        where s.end_date >= sysdate and s.c_id =p_customer_id and s.no_of_meals_left>0;
        
        if v_sub_exists_count>0 then
        raise EXC_SUB_EXISTS;
        end if;
      -- Check if the payment amount matches the subscription price
        IF p_payment_amount = v_subscription_price THEN
            -- Insert subscription record
            INSERT INTO subscription(sub_id, start_date, end_date, sub_type_id,
            c_id, no_of_meals_left)
            VALUES (sub_seq.NEXTVAL, SYSDATE, SYSDATE + 7, v_subscription_type_id,
            p_customer_id, v_subscription_meal_count);
            
            -- Insert payment record
            INSERT INTO payment(pay_id, sub_id, transaction_date, amount)
            VALUES (payment_seq.NEXTVAL, sub_seq.CURRVAL, SYSDATE, p_payment_amount);

            DBMS_OUTPUT.PUT_LINE('Payment and Subscription Purchase Successful.');
        ELSE
            -- Raise an exception if the payment amount doesn't match the subscription price
            RAISE EXC_INV_AMT;
        END IF;
    ELSE
        -- Raise an exception if the subscription type is not found
        RAISE EXC_INV_SUB_TYPE;
    END IF;
COMMIT;
EXCEPTION
    when EXC_INV_SUB_TYPE then
    DBMS_OUTPUT.PUT_LINE('Sub type doesnt exist, please enter a valid sub type');
    when EXC_INV_AMT then
    DBMS_OUTPUT.PUT_LINE('payment amount is invalid please enter the correct amount');
    when EXC_SUB_EXISTS then
    DBMS_OUTPUT.PUT_LINE('Subscrition already exist ');
    when EXC_CUS_NOT_EXISTS then
    DBMS_OUTPUT.PUT_LINE('Customer doesnt exists ');
    when no_data_found then
	dbms_output.put_line('Sub type doesnt exist, please enter a valid sub type');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE( 'An error occurred: ' || SQLERRM);
        
END PurchaseSubscription;
/

-- 4. ViewAllMealTypes
-- input: None
-- output: displays all the meal types available in the system.
-- exception: None
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE ViewAllMealTypes IS
BEGIN
    FOR meal_type_rec IN (
        SELECT type 
        FROM meal
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Meal Type: ' || meal_type_rec.type );
    END LOOP;
END ViewAllMealTypes;
/

-- 5. book_meal
-- INPUT: Customer_id, meal type, time slot, delivery date
-- OUTPUT: creates a booking record in the system for speified time slot and date for the customer
-- DESCRIPTION AND EXCEPTIONS : checks if active subscription or not, delivery date
-- is valid or not and checks all the column level constraints
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE book_meal (
    p_customer_id    IN NUMBER,
    p_meal_type      IN VARCHAR2,
    p_time_slot      IN VARCHAR2,
    p_delivery_date  IN DATE
) IS
    v_sub_end_date   DATE;
    EXC_MEAL EXCEPTION;
    EXC_TIME_SLOT EXCEPTION;
    v_count number;
    no_of_meals number;
BEGIN

    if p_meal_type is NULL or length(p_meal_type)<1 then
    RAISE EXC_MEAL;
    end if;

    SELECT COUNT(*) INTO v_count FROM (SELECT LOWER(type) as type FROM meal) 
    WHERE type = LOWER(p_meal_type);

  IF v_count = 0 THEN
    RAISE EXC_MEAL;
  END IF;
    
    if p_time_slot is NULL or length(p_time_slot)<1 or lower(p_time_slot) 
    not in ('afternoon','night') then
    RAISE EXC_TIME_SLOT;
    end if;
    
    -- Check if the customer has an active subscription
    SELECT MAX(s.end_date) INTO v_sub_end_date
    FROM subscription s
    WHERE s.c_id = p_customer_id
    AND s.end_date >= TRUNC(SYSDATE);
    
    IF v_sub_end_date IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Customer does not have an active subscription.');
        RETURN;
    END IF;

    -- Check if the delivery date is valid
    IF p_delivery_date <= TRUNC(SYSDATE) or p_delivery_date > v_sub_end_date THEN
        DBMS_OUTPUT.PUT_LINE('Delivery date must be between tommorrow and subscription enddate ');
        RETURN;
    END IF;
    
    select no_of_meals_left into no_of_meals from subscription 
    where sub_id = (SELECT s.sub_id FROM subscription s WHERE s.c_id = p_customer_id
    AND s.end_date >= TRUNC(SYSDATE));
    
    IF no_of_meals <= 0 THEN
    DBMS_OUTPUT.PUT_LINE('Out of meals! Please purchase a subscription');
    RETURN;
    END IF;

    -- Proceed with the booking process
    INSERT INTO booking ( book_id,c_id,sub_id,meal_id,booking_date,date_of_delivery,
    time_slot,dp_id,is_delivered)
    VALUES (booking_seq.NEXTVAL,p_customer_id,(SELECT s.sub_id FROM subscription s
    WHERE s.c_id = p_customer_id AND s.end_date >= TRUNC(SYSDATE)),
        (SELECT m.meal_id FROM meal m WHERE m.type = upper(p_meal_type)),
        SYSDATE, p_delivery_date, upper(p_time_slot),
        NULL,'N');
        
--    update subscription set no_of_meals_left = no_of_meals_left - 1 
--    where sub_id = (SELECT s.sub_id FROM subscription s WHERE s.c_id = p_customer_id
--    AND s.end_date >= TRUNC(SYSDATE));
    COMMIT;  
    DBMS_OUTPUT.PUT_LINE('Meal booked successfully!');
EXCEPTION
    WHEN EXC_MEAL then
        DBMS_OUTPUT.PUT_LINE('Enter a valid meal type');
    WHEN EXC_TIME_SLOT THEN
        DBMS_OUTPUT.PUT_LINE('Enter a valid Time slot');    
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Customer does not have an active subscription.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END book_meal;
/

-- 6. generate_invoice
-- INPUT : Customer_id
-- OUTPUT: prints all the payment details made till date  
-- DESCRIPTION AND EXCEPTION: checks if customer exists in system or not 
-- if exists displays all the payments in chronological order else displays error message
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE generate_invoice (
    p_customer_id IN NUMBER
) IS
 count_number NUMBER;
BEGIN
    select count(c_id) into count_number from customer where c_id = p_customer_id  ;
    if count_number = 0 then
    DBMS_OUTPUT.PUT_LINE('Customer doesnt exist! Please enter a valid customer id');
    return;
    end if;
    FOR invoice_rec IN (
        SELECT
            p.pay_id,
            p.transaction_date,
            s.sub_type_id,
            st.type AS subscription_type,
            p.amount AS amount,
            s.no_of_meals_left
        FROM payment p
        JOIN subscription s ON p.sub_id = s.sub_id
        JOIN subscription_type st ON s.sub_type_id = st.sub_type_id
        WHERE s.c_id = p_customer_id
        ORDER BY p.transaction_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Transaction ID: ' || invoice_rec.pay_id || ' | ' ||
        'Transaction Date: ' || TO_CHAR(invoice_rec.transaction_date, 'YYYY-MM-DD HH24:MI:SS') || ' | ' ||
        'Subscription Type: ' || invoice_rec.subscription_type || ' | ' || 'Amount Paid: $' || invoice_rec.amount);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
END generate_invoice;
/

-- 7. get_delivery_details
-- INPUT: customer_id
-- OUTPUT: prints delivery details
-- DESCRIPTION AND EXCEPTION: this procedure checks if customer exists in system or not if exists then it is used
-- to get delivery details of all the bookings made by the customer.
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE get_delivery_details (
    p_customer_id IN NUMBER
) IS
count_number NUMBER;
BEGIN
    select count(c_id) into count_number from customer where c_id = p_customer_id  ;
    if count_number = 0 then
    DBMS_OUTPUT.PUT_LINE('Customer doesnt exist! Please enter a valid customer id');
    return;
    end if;
    FOR delivery_rec IN (
        SELECT *
        FROM DELIVERY_DETAILS_view
        WHERE CUSTOMER_ID = p_customer_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || delivery_rec.BOOK_ID ||' | ' 
        ||'Customer ID: ' || delivery_rec.CUSTOMER_ID || ' | ' || 'Delivery Date: ' ||
        TO_CHAR(delivery_rec.DATE_OF_DELIVERY, 'YYYY-MM-DD') || ' | ' ||
        'Time Slot: ' || delivery_rec.TIME_SLOT || ' | ' || 'Delivery Partner: '
        || delivery_rec.delivery_person || ' | ' || 'Is Delivered: ' ||
        delivery_rec.delivery_status);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
END get_delivery_details;
/

-- 8. update_customer_details
-- INPUT: customer_id or/and name or/and dob or/and gender or/and email or/and hone number. 
-- OUTPUT: updates the correspondeing customer record with new details.
-- DESCRIPTION AND EXCEPTION: this procedure checks if customer exists in system
-- or not if exists then it is used to get delivery details of all the bookings made by the customer.
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE update_customer_details (
    p_customer_id   IN NUMBER,
    p_name          IN VARCHAR2 DEFAULT NULL,
    p_dob           IN DATE DEFAULT NULL,
    p_gender        IN VARCHAR2 DEFAULT NULL,
    p_email         IN VARCHAR2 DEFAULT NULL,
    p_phone_number  IN NUMBER DEFAULT NULL
) IS
    v_email_exists EXCEPTION;
    v_email_count number;
    v_phone_exists EXCEPTION;
    v_phone_count number;
    EXC_PHONE_NUMBER EXCEPTION;
    EXC_GENDER EXCEPTION;
    EXC_EMAIL EXCEPTION;
    v_email_pattern VARCHAR2(100) := '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$';
    EXC_VALID_EMAIL EXCEPTION;
BEGIN

     -- Check if the provided phone number  not equal to 10 digits
    IF length(p_phone_number) =0 or length(p_phone_number) != 10 THEN
        RAISE EXC_PHONE_NUMBER;
    END IF;
    
     -- Check if the provided gender greater than 10 characters
    IF length(p_gender) > 10 THEN
        RAISE EXC_GENDER;
    END IF;
     -- Check if the provided email greater than 50 characters
    IF length(p_email) =0 or length(p_email) > 50 THEN
        RAISE EXC_EMAIL;
    END IF;

   IF NOT REGEXP_LIKE(p_email, v_email_pattern) THEN
      -- Raise an exception with a custom error message
      RAISE EXC_VALID_EMAIL;
   END IF;
   
    -- Check if the provided email already exists
        SELECT count(*) INTO v_email_count FROM CUSTOMER WHERE c_email = p_email and c_id != p_customer_id;
        
        -- If the email exists, raise an exception
        if v_email_count>0 THEN
            RAISE v_email_exists;
        end if;

    -- Check if the provided phone number already exists
        SELECT count(*) INTO v_phone_count FROM CUSTOMER 
        WHERE c_phone_number = p_phone_number and c_id != p_customer_id;
        
        -- If the phone number exists, raise an exception
       if v_phone_count>0 THEN
            RAISE v_phone_exists;
        end if;
       
    UPDATE CUSTOMER
    SET
        c_name = NVL(p_name, c_name),
        dob = NVL(p_dob, dob),
        gender = NVL(p_gender, gender),
        c_email = NVL(p_email, c_email),
        c_phone_number = NVL(p_phone_number, c_phone_number)
    WHERE c_id = p_customer_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Customer details updated successfully.');
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Customer with ID ' || p_customer_id || ' not found.');
    WHEN v_email_exists THEN
        DBMS_OUTPUT.PUT_LINE('Error: Email already exists.');
    WHEN v_phone_exists THEN
        DBMS_OUTPUT.PUT_LINE('Error: Phone number already exists.');
    WHEN EXC_PHONE_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Mobile phone number cant be empty and should be 10 digit number');
    WHEN EXC_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('email cant be empty and should not be more than 50 characters');
    WHEN EXC_VALID_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('Invalid email format. Please provide a valid email.');
    WHEN EXC_GENDER THEN
        DBMS_OUTPUT.PUT_LINE('gender should not be more than 10 characters');
   WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: An unexpected error occurred.');
END update_customer_details;
/

-- End of Customer workflow
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- Manager workflow

-- 9. add_or_update_subscription_type
-- INPUT:  type(required param), price, meal count
-- OUTPUT: updates the corresponding sub type record with new details or create a new one.
-- DESCRIPTION AND EXCEPTION: this procedure checks if sub type is valid or not 
-- and all column level constraints.

SET SERVEROUTPUT ON        
CREATE OR REPLACE PROCEDURE add_or_update_subscription_type (
    p_type IN VARCHAR2,
    p_price IN NUMBER DEFAULT NULL,
    p_meal_count IN NUMBER DEFAULT NULL
) IS
BEGIN
    -- checks if sub type valid or not
    IF p_type is null or length(p_type) =0 or length(p_type) > 10 THEN
        DBMS_OUTPUT.PUT_LINE('type is required and need to be less than 10 charcters length');
        return;
    END IF;
     -- checks if meal count is more than 9999
    IF length(p_meal_count) > 4 THEN
        DBMS_OUTPUT.PUT_LINE('meal count cant be more than 9999');
        return;
    END IF;

    -- Check if the subscription type already exists
    DECLARE
        v_type_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_type_exists
        FROM subscription_type
        WHERE lower(type) = lower(p_type);
        -- If the type exists, update the record
        IF v_type_exists > 0 THEN
            UPDATE subscription_type
            SET price = NVL(p_price, price),
                meal_count = NVL(p_meal_count, meal_count)
            WHERE lower(type) = lower(p_type);

            DBMS_OUTPUT.PUT_LINE('Success! Subscription type updated.');
        ELSE
            -- If the type does not exist, insert a new record
            INSERT INTO subscription_type (sub_type_id, type, price, meal_count)
            VALUES (SUB_TYPE_SEQ.NEXTVAL, p_type, p_price, p_meal_count);

            DBMS_OUTPUT.PUT_LINE('Success! New subscription type added.');
        END IF;
COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;
END add_or_update_subscription_type;
/


-- 10. delete_subscription_type
-- INPUT:  type(required param)
-- OUTPUT: updates the corresponding sub type record with new details or create a new one.
-- DESCRIPTION AND EXCEPTION: this procedure checks if sub type is valid or not 
-- and all column level constraints.
--SET SERVEROUTPUT ON        
--CREATE OR REPLACE PROCEDURE delete_subscription_type (
--    p_type IN VARCHAR2
--) IS
--BEGIN
--    -- Check if the subscription type exists
--    DECLARE
--        v_type_exists NUMBER;
--    BEGIN
--    
--        -- checks if sub type valid or not
--        IF p_type is null or length(p_type) =0 or length(p_type) > 10 THEN
--        DBMS_OUTPUT.PUT_LINE('type is required and need to be less than 10 charcters length');
--        return;
--        END IF;
--        
--        SELECT COUNT(*) INTO v_type_exists
--        FROM subscription_type
--        WHERE type = p_type;
--
--        -- If the type exists, delete the record
--        IF v_type_exists > 0 THEN
--            DELETE FROM subscription_type
--            WHERE lower(type) = lower(p_type);
--
--            DBMS_OUTPUT.PUT_LINE('Success! Subscription type deleted.');
--        ELSE
--            -- If the type does not exist, display an error message
--            DBMS_OUTPUT.PUT_LINE('Error: Subscription type does not exist. please enter a valid type');
--        END IF;
--    EXCEPTION
--        WHEN OTHERS THEN
--            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
--    END;
--
--END delete_subscription_type;
--/

-- 11. add_meal
-- INPUT:  type(required param)
-- OUTPUT:creates a new meal type if already exists prompts the user with warning message.
-- DESCRIPTION AND EXCEPTION: this procedure checks if meal type is valid or not 
-- and all column level constraints.
SET SERVEROUTPUT ON        
CREATE OR REPLACE PROCEDURE add_meal (
    p_meal_type IN VARCHAR2
) IS
BEGIN
    -- checks if sub type valid or not
    IF p_meal_type is null or length(p_meal_type) =0 or length(p_meal_type) > 10 THEN
        DBMS_OUTPUT.PUT_LINE('type is required and need to be less than 10 charcters length');
        RETURN;
    END IF;
    -- Check if the meal type already exists
    DECLARE
        v_type_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_type_exists
        FROM meal
        WHERE lower(type) = lower(p_meal_type);

        -- If the meal type does not exist, insert a new record
        IF v_type_exists = 0 THEN
            INSERT INTO meal (meal_id,type)
            VALUES (MEAL_SEQ.NEXTVAL,p_meal_type);

            DBMS_OUTPUT.PUT_LINE('Success! Meal added.');
        ELSE
            -- If the meal type already exists, display an error message
            DBMS_OUTPUT.PUT_LINE('Error: Meal type already exists.');
        END IF;
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;

END add_meal;
/

-- 12. delete_subscription_type
-- INPUT:  type(required param)
-- OUTPUT: updates the corresponding sub type record with new details or create a new one.
-- DESCRIPTION AND EXCEPTION: this procedure checks if sub type is valid or not 
-- and all column level constraints.
--
--SET SERVEROUTPUT ON
--CREATE OR REPLACE PROCEDURE delete_meal (
--    p_meal_type IN VARCHAR2
--) IS
--BEGIN
--    -- checks if meal type valid or not
--    IF p_meal_type is null or length(p_meal_type) =0 or length(p_meal_type) > 10 THEN
--        DBMS_OUTPUT.PUT_LINE('type is required and need to be less than 10 charcters length');
--        RETURN;
--    END IF;
--    -- Check if the meal ID exists
--    DECLARE
--        v_meal_exists NUMBER;
--    BEGIN
--        SELECT COUNT(*) INTO v_meal_exists
--        FROM meal
--        WHERE lower(type) = lower(p_meal_type);
--
--        -- If the meal ID exists, delete the record
--        IF v_meal_exists > 0 THEN
--            DELETE FROM meal
--            WHERE lower(type) = lower(p_meal_type);
--
--            DBMS_OUTPUT.PUT_LINE('Success! Meal deleted.');
--        ELSE
--            -- If the meal ID does not exist, display an error message
--            DBMS_OUTPUT.PUT_LINE('Error: Meal Type does not exist.');
--        END IF;
--    EXCEPTION
--        WHEN OTHERS THEN
--            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
--    END;
--
--END delete_meal;
--/
--

-- 13. update_booking_delivery_partner
-- INPUT:  p_booking_id(required param), p_dp_id (required param)
-- OUTPUT: updates the corresponding sub record with dp_id and displays success message or error message.
-- DESCRIPTION AND EXCEPTION: this procedure checks if sub type is valid or not 
-- and all column level constraints.

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE update_booking_delivery_partner (
    p_booking_id      IN NUMBER,
    p_dp_id           IN NUMBER
) IS
BEGIN
    IF p_booking_id is null or length(p_booking_id) =0 THEN
       DBMS_OUTPUT.PUT_LINE('booking_id is required');
       RETURN;
    END IF;
    IF p_dp_id is null or length(p_dp_id) =0 THEN
       DBMS_OUTPUT.PUT_LINE('dp_id is required');
       RETURN;
    END IF;
    
    UPDATE BOOKING
    SET dp_id = p_dp_id
    WHERE book_id = p_booking_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' updated with Delivery Partner ID ' || p_dp_id || ' successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Booking ' || p_booking_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Booking ' || p_booking_id || ': ' || SQLERRM);
END update_booking_delivery_partner;
/


-- 14. create_delivery_partner
-- INPUT:  p_booking_id(required param), p_dp_id (required param)
-- OUTPUT: updates the corresponding sub record with dp_id and displays success message or error message.
-- DESCRIPTION AND EXCEPTION: this procedure checks if sub type is valid or not 
-- and all column level constraints.

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE create_delivery_partner (
    p_d_name         IN VARCHAR2,
    p_phone_number   IN NUMBER,
    p_email          IN VARCHAR2
) IS
EXC_PHONE_NUMBER EXCEPTION;
EXC_NAME EXCEPTION;
EXC_EMAIL EXCEPTION;
v_email_pattern VARCHAR2(100) := '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$';
EXC_VALID_EMAIL EXCEPTION;
BEGIN
     -- Check if the provided phone number  not equal to 10 digits
    IF length(p_phone_number) =0 or length(p_phone_number) != 10 THEN
        RAISE EXC_PHONE_NUMBER;
    END IF;
         -- Check if the provided phone number  not equal to 10 digits
    IF p_d_name is null or length(p_d_name) =0 or length(p_d_name) > 20 THEN
        RAISE EXC_NAME;
    END IF;
     -- Check if the provided email greater than 50 characters
    IF length(p_email) =0 or length(p_email) > 50 THEN
        RAISE EXC_EMAIL;
    END IF;
    
    IF NOT REGEXP_LIKE(p_email, v_email_pattern) THEN
      -- Raise an exception with a custom error message
      RAISE EXC_VALID_EMAIL;
   END IF;
   
    INSERT INTO DELIVERY_PARTNER (dp_id, d_name, d_phone_number, d_email)
    VALUES (DP_SEQ.NEXTVAL, p_d_name, p_phone_number, p_email);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Delivery Partner created successfully.');
EXCEPTION
    WHEN EXC_NAME THEN
        DBMS_OUTPUT.PUT_LINE('Cname cant be empty or more than 20 characters');
    WHEN EXC_PHONE_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Mobile phone number cant be empty and should be 10 digit number');
    WHEN EXC_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('email cant be empty and should not be more than 50 characters');
    WHEN EXC_VALID_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('Invalid email format. Please provide a valid email.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Delivery Partner ' || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating Delivery Partner ' || DP_SEQ.CURRVAL || ': ' || SQLERRM);
END create_delivery_partner;
/


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Delivery partner workflow

-- 15. view_pending_deliveries
-- INPUT:  dp_id(required param)
-- OUTPUT: fetches pending deliveries for a deliery person
-- DESCRIPTION AND EXCEPTION: this procedure checks if dp id is exists or not 
-- and all column level constraints.

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE view_pending_deliveries (
    p_dp_id IN NUMBER
    
) IS
count_num NUMBER DEFAULT 0;
BEGIN
    FOR delivery_rec IN (
        SELECT *
        FROM DELIVERY_SCHEDULE_VIEW
        WHERE DELIVERY_PERSON_ID = p_dp_id
          AND delivery_status = 'N'
    ) LOOP
        count_num:= count_num + 1;
        DBMS_OUTPUT.PUT_LINE('Delivery ID: ' || delivery_rec.DELIVERY_PERSON_ID || ' | ' ||
                            'Customer Name: ' || delivery_rec.customer_name || ' | ' ||
                            'Booking id: ' || delivery_rec.book_id || ' | ' ||
                            'TIMESLOT: ' || DELIVERY_REC.TIME_SLOT || ' | ' ||
                            'Delivery Date: ' || delivery_rec.delivery_date || ' | ' ||
                            'delivery address: ' || delivery_rec.DELIVERY_ADDRESS
                            
                            );
    END LOOP;
    IF count_num = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Dp id doesnt exists! or No pending deliveries');
    END IF;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
END view_pending_deliveries;
/


-- 16. update_delivery_status
-- INPUT:  booking_id(required param) and delivery status (required param)
-- OUTPUT: updates the corresponding sub record with delivery status.
-- DESCRIPTION AND EXCEPTION: this procedure checks if booking id and is_delivered is valid or not 
-- and all column level constraints.
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE update_delivery_status (
    p_dp_id      IN NUMBER,
    p_booking_id IN NUMBER,
    p_is_delivered IN VARCHAR2
) IS
BEGIN
    IF p_booking_id is null or length(p_booking_id) = 0 THEN
       DBMS_OUTPUT.PUT_LINE('booking_id is required');
       RETURN;
    END IF;
    IF p_dp_id is null or length(p_dp_id) = 0 THEN
       DBMS_OUTPUT.PUT_LINE('dp_id is required');
       RETURN;
    END IF;
    IF p_is_delivered is null or length(p_is_delivered) =0 or length(p_is_delivered) != 1 or lower(p_is_delivered) not in ('y', 'n') THEN
        DBMS_OUTPUT.PUT_LINE('Delivery status is required and need to be either Y or N');
        RETURN;
    END IF;
    -- Check if the booking ID exists
    DECLARE
        v_booking_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_booking_exists
        FROM booking
        WHERE book_id = p_booking_id and dp_id = p_dp_id;

        -- If the booking ID exists, update the delivery status
        IF v_booking_exists > 0 THEN
            UPDATE booking
            SET is_delivered = UPPER(p_is_delivered)
            WHERE book_id = p_booking_id and dp_id = p_dp_id;

            DBMS_OUTPUT.PUT_LINE('Success! Delivery status updated.');
        ELSE
            -- If the booking ID does not exist, display an error message
            DBMS_OUTPUT.PUT_LINE('Error: Booking does not exist.');
        END IF;
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;

END update_delivery_status;
/

-- 17. update_delivery_partner
-- INPUT:  dp_id (required param), name, phone, email.
-- OUTPUT: updates the corresponding dp record with new data.
-- DESCRIPTION AND EXCEPTION: this procedure checks if dp id is valid or not 
-- and all column level constraints and updates accordingly.
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE update_delivery_partner (
    p_dp_id           IN NUMBER,
    p_d_name          IN VARCHAR2 DEFAULT NULL,
    p_phone_number    IN NUMBER DEFAULT NULL,
    p_d_email         IN VARCHAR2 DEFAULT NULL
) IS
EXC_PHONE_NUMBER EXCEPTION;
EXC_NAME EXCEPTION;
EXC_EMAIL EXCEPTION;
v_dp_exists number;
v_email_pattern VARCHAR2(100) := '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$';
EXC_VALID_EMAIL EXCEPTION;
BEGIN

    IF p_dp_id is null or length(p_dp_id) =0 THEN
       DBMS_OUTPUT.PUT_LINE('dp_id is required');
       RETURN;
    END IF;

     -- Check if the provided phone number  not equal to 10 digits
    IF length(p_phone_number) =0 or length(p_phone_number) != 10 THEN
        RAISE EXC_PHONE_NUMBER;
    END IF;
         -- Check if the provided phone number  not equal to 10 digits
    IF length(p_d_name) =0 or length(p_d_name) > 20 THEN
        RAISE EXC_NAME;
    END IF;
     -- Check if the provided email greater than 50 characters
    IF length(p_d_email) =0 or length(p_d_email) > 50 THEN
        RAISE EXC_EMAIL;
    END IF;
    
    IF NOT REGEXP_LIKE(p_d_email, v_email_pattern) THEN
      -- Raise an exception with a custom error message
      RAISE EXC_VALID_EMAIL;
   END IF;
   
    select count(*) into v_dp_exists from DELIVERY_PARTNER where dp_id = p_dp_id;
    
    if v_dp_exists = 0 then
        DBMS_OUTPUT.PUT_LINE('DP_ID ' || p_dp_id || ' doesnt exists');
        return;
    end if;
    
    UPDATE DELIVERY_PARTNER
    SET
        d_name = NVL(p_d_name, d_name),
        d_phone_number = NVL(p_phone_number, d_phone_number),
        d_email = NVL(p_d_email, d_email)
    WHERE dp_id = p_dp_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Delivery Partner ' || p_dp_id || ' updated successfully.');
EXCEPTION
    WHEN EXC_NAME THEN
        DBMS_OUTPUT.PUT_LINE('Cname cant be empty or more than 20 characters');
    WHEN EXC_PHONE_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Mobile phone number cant be empty and should be 10 digit number');
    WHEN EXC_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('email cant be empty and should not be more than 50 characters');
    WHEN EXC_VALID_EMAIL THEN
        DBMS_OUTPUT.PUT_LINE('Invalid email format. Please provide a valid email.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Delivery Partner ' || p_dp_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating Delivery Partner ' || p_dp_id || ': ' || SQLERRM);
END update_delivery_partner;
/
