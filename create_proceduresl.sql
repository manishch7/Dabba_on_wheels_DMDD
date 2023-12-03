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
BEGIN

 -- Check if the provided phone number  not equal to 10 digits
IF p_phone_number is null or length(p_phone_number) =0 or length(p_phone_number) != 10 THEN
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
     -- Check if the provided address greater than 50 characters
IF length(p_street_address) > 50 THEN
        RAISE EXC_STREET;
    END IF;
     -- Check if the provided city greater than 20 characters
IF length(p_city) > 20 THEN
        RAISE EXC_CITY;
    END IF;
     -- Check if the provided state greater than 20 characters
IF length(p_state) > 20 THEN
        RAISE EXC_STATE;
    END IF;
         -- Check if the provided zipcode is not equal to 5 digits
    IF length(p_zipcode) != 5 THEN
        RAISE EXC_ZIP;
    END IF;
    
    -- Check if the provided email already exists

        SELECT count(*) INTO v_email_count FROM CUSTOMER WHERE c_email = p_email;
        -- If the email exists, raise an exception
        if v_email_count>0 THEN
            RAISE v_email_exists;
        end if;

    -- Check if the provided phone number already exists
        SELECT count(*) INTO v_phone_count FROM CUSTOMER WHERE c_phone_number = p_phone_number;
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
    VALUES (CUSTOMER_SEQ.NEXTVAL, v_loc_id, p_name, p_dob, p_gender, p_email, p_phone_number)
    RETURNING c_id INTO v_c_id;

    -- Set the output parameter with the customer ID
    o_customer_id := v_c_id;

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
    WHEN EXC_GENDER THEN
        DBMS_OUTPUT.PUT_LINE('gender should not be more than 10 characters');
    WHEN EXC_STREET THEN
        DBMS_OUTPUT.PUT_LINE('street address should not be more than 50 characters');
    WHEN EXC_CITY THEN
        DBMS_OUTPUT.PUT_LINE('city should not be more than 20 characters');
    WHEN EXC_STATE THEN
        DBMS_OUTPUT.PUT_LINE('state should not be more than 50 characters');
    WHEN EXC_ZIP THEN
        DBMS_OUTPUT.PUT_LINE('zipcode should be equal 5 digit number');

    --WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('Error: An unexpected error occurred.');
END CUSTOMER_REGISTRATION_PROCEDURE;
/

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
        
        select count(*) into v_customer_exists_count from customer where c_id = p_customer_id;
        
        if v_customer_exists_count = 0 then
        raise EXC_CUS_NOT_EXISTS;
        end if;
        
        SELECT count(s.sub_id) into v_sub_exists_count FROM customer c JOIN subscription s ON c.c_id = s.c_id 
        where s.end_date >= sysdate and s.c_id =p_customer_id and s.no_of_meals_left>0;
        
        if v_sub_exists_count>0 then
        raise EXC_SUB_EXISTS;
        end if;
        
        IF p_payment_amount = v_subscription_price THEN
        
            -- Insert subscription record
            INSERT INTO subscription(sub_id, start_date, end_date, sub_type_id, c_id, no_of_meals_left)
            VALUES (sub_seq.NEXTVAL, SYSDATE, SYSDATE + 7, v_subscription_type_id, p_customer_id, v_subscription_meal_count);
            
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
    -- Check if the customer has an active subscription
    SELECT MAX(s.end_date) INTO v_sub_end_date
    FROM subscription s
    WHERE s.c_id = p_customer_id
    AND s.end_date >= TRUNC(SYSDATE);

    if p_meal_type is NULL or length(p_meal_type)<1 then --or lower(p_meal_type) not in (select lower(type) from meal) then
    RAISE EXC_MEAL;
    end if;

    SELECT COUNT(*) INTO v_count FROM (SELECT LOWER(type) as type FROM meal) WHERE type = LOWER(p_meal_type);

  IF v_count = 0 THEN
    RAISE EXC_MEAL;
  END IF;
    
    if p_time_slot is NULL or length(p_time_slot)<1 or lower(p_time_slot) not in ('afternoon','night') then
    RAISE EXC_TIME_SLOT;
    end if;
    
    IF v_sub_end_date IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Customer does not have an active subscription.');
        RETURN;
    END IF;

    -- Check if the delivery date is valid
    IF p_delivery_date <= TRUNC(SYSDATE) THEN
        DBMS_OUTPUT.PUT_LINE('Delivery date must be greater than today.');
        RETURN;
    END IF;
    
    select no_of_meals_left into no_of_meals from subscription 
    where sub_id = (SELECT s.sub_id FROM subscription s WHERE s.c_id = p_customer_id AND s.end_date >= TRUNC(SYSDATE));
    
    IF no_of_meals <= 0 THEN
    DBMS_OUTPUT.PUT_LINE('Out of meals! Please purchase a subscription');
    RETURN;
    END IF;

    -- Proceed with the booking process
    INSERT INTO booking ( book_id,c_id,sub_id,meal_id,booking_date,date_of_delivery,time_slot,dp_id,is_delivered)
    VALUES (booking_seq.NEXTVAL,p_customer_id,(SELECT s.sub_id FROM subscription s WHERE s.c_id = p_customer_id AND s.end_date >= TRUNC(SYSDATE)),
        (SELECT m.meal_id FROM meal m WHERE m.type = upper(p_meal_type)), SYSDATE, p_delivery_date, upper(p_time_slot),
        NULL,'N');
        
    update subscription set no_of_meals_left = no_of_meals_left - 1 
    where sub_id = (SELECT s.sub_id FROM subscription s WHERE s.c_id = p_customer_id AND s.end_date >= TRUNC(SYSDATE));
    
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

CREATE OR REPLACE PROCEDURE generate_invoice (
    p_customer_id IN NUMBER
) IS
BEGIN
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


CREATE OR REPLACE PROCEDURE get_delivery_details (
    p_customer_id IN NUMBER
) IS
BEGIN
    FOR delivery_rec IN (
        SELECT *
        FROM DELIVERY_DETAILS_view
        WHERE CUSTOMER_ID = p_customer_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || delivery_rec.BOOK_ID ||' | ' ||'Customer ID: ' || delivery_rec.CUSTOMER_ID || ' | ' ||
'Delivery Date: ' || TO_CHAR(delivery_rec.DATE_OF_DELIVERY, 'YYYY-MM-DD') || ' | ' ||
'Time Slot: ' || delivery_rec.TIME_SLOT || ' | ' || 'Delivery Partner: ' || delivery_rec.delivery_person ||
' | ' || 'Is Delivered: ' || delivery_rec.delivery_status);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
END get_delivery_details;
/

