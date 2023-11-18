SET SERVEROUTPUT ON
/
DECLARE
CURSOR C_FK IS SELECT TABLE_NAME,CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R'; --CURSOR TO STORE TABLE NAME AND CONSTRAINT NAME
CURSOR C_SK IS SELECT SEQUENCE_NAME FROM USER_SEQUENCES;
CURSOR C_TBL IS SELECT TABLE_NAME FROM USER_TABLES;
CURSOR C_IDX IS SELECT INDEX_NAME FROM USER_INDEXES WHERE INDEX_NAME='IDX1' OR INDEX_NAME='IDX3';
I NUMBER:=0;                                                                                        --DECLARE AND INITALIZE VARIABLE I
V_COUNT  NUMBER :=0;
V_COUNT1 NUMBER:=0;--DECLARE COUNTER 
V_COUNT2 NUMBER:=0;
V_COUNT3 NUMBER:=0;
BEGIN
WHILE I<6                                                                                           --WHILE LOOP TO ITERATE I VARIABLE UNTIL I VALUE IS LESS THAN 6
	LOOP
		I:=I+1;                                                                                     --INCREMENT I VALUE
		SELECT COUNT(*) INTO V_COUNT FROM USER_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R';				--SELECT QUERY TO INSERT NUMBER OF REFRENTIAL KEYS INTO VARIABLE V_COUNT
		SELECT COUNT(*) INTO V_COUNT1 FROM USER_SEQUENCES;	
		SELECT COUNT(*) INTO V_COUNT2 FROM USER_TABLES;
		SELECT COUNT(*) INTO V_COUNT3 FROM USER_INDEXES WHERE INDEX_NAME='IDX1' OR INDEX_NAME='IDX3';
            IF I=1 AND V_COUNT>0 THEN                                                               --IF CLAUSE TO CHECK I VALUE AND NUMBER OF VALUES IN V_COUNT VARIABLE
					FOR FK IN C_FK LOOP 
                    DBMS_OUTPUT.PUT_LINE('DROPPING FOREIGN KEY CONSTRAINTS FOR TABLE '||FK.TABLE_NAME);--FOR LOOP TO ITERATE CURSOR C_FK
					EXECUTE IMMEDIATE 'ALTER TABLE ' || FK.TABLE_NAME || ' DROP CONSTRAINT ' || FK.CONSTRAINT_NAME; --DROP ALL FOREIGN KEY CONSTRAINTS IN DATABASE             --DISPLAY DROPPING MESSAGE TO CONSOLE
					END LOOP;
            ELSE IF I=2 AND V_COUNT1>0 THEN
                    FOR SK IN C_SK LOOP
                    DBMS_OUTPUT.PUT_LINE('DROPPING SEQUENCES '||SK.SEQUENCE_NAME);
                    EXECUTE IMMEDIATE 'DROP SEQUENCE '||SK.SEQUENCE_NAME;
                    END LOOP;
            ELSE IF I=3 AND V_COUNT2>0 THEN
					FOR TBL IN C_TBL LOOP
                    DBMS_OUTPUT.PUT_LINE('DROPPING TABLES '||TBL.TABLE_NAME);
					EXECUTE IMMEDIATE 'DROP TABLE '||TBL.TABLE_NAME;
					END LOOP;
			ELSE IF I=4 AND V_COUNT3>0 THEN
					FOR IDX IN C_IDX LOOP
                    DBMS_OUTPUT.PUT_LINE('DROPPING INDEXES '||IDX.INDEX_NAME);
					EXECUTE IMMEDIATE 'DROP INDEX '||IDX.INDEX_NAME;
					END LOOP;
			ELSE IF i=5 AND V_COUNT=0 AND V_COUNT1=0 AND V_COUNT2=0 AND V_COUNT3=0 THEN
					DBMS_OUTPUT.PUT_LINE('NO OBJECTS EXISTS IN DATABASE');
			END IF;
            END IF;
            END IF;
            END IF;
            END IF;
END LOOP;
DBMS_OUTPUT.PUT_LINE('DATABASE CLEANUP DONE SUCCESSFULLY');
END;
/
CREATE SEQUENCE LOCATION_SEQ
START WITH 111001
INCREMENT BY 1
NOCYCLE;
/
CREATE TABLE LOCATION (
    loc_id         NUMBER NOT NULL,
    street_address VARCHAR2(50 CHAR),
    city           VARCHAR2(20 CHAR),
    state          VARCHAR2(20 CHAR),
    zipcode        NUMBER(5),
    unit           NUMBER,
    CONSTRAINT location_pk PRIMARY KEY ( loc_id ));
/
-- Inserting data into the LOCATION table
INSERT INTO LOCATION (loc_id, street_address, city, state, zipcode, unit)
VALUES (LOCATION_SEQ.NEXTVAL, '123 Main St', 'Cityville', 'CA', 12345, 101);

INSERT INTO LOCATION (loc_id, street_address, city, state, zipcode, unit)
VALUES (LOCATION_SEQ.NEXTVAL, '456 Oak St', 'Townsville', 'NY', 54321, 205);

INSERT INTO LOCATION (loc_id, street_address, city, state, zipcode, unit)
VALUES (LOCATION_SEQ.NEXTVAL, '789 Pine St', 'Villagetown', 'TX', 67890, 303);

INSERT INTO LOCATION (loc_id, street_address, city, state, zipcode, unit)
VALUES (LOCATION_SEQ.NEXTVAL, '101 Elm St', 'Hamlet City', 'FL', 98765, 404);

INSERT INTO LOCATION (loc_id, street_address, city, state, zipcode, unit)
VALUES (LOCATION_SEQ.NEXTVAL, '202 Maple St', 'Boroughville', 'IL', 34567, 506);
/
CREATE SEQUENCE SUB_TYPE_SEQ
START WITH 222001
INCREMENT BY 1
NOCYCLE;
/
CREATE TABLE SUBSCRIPTION_TYPE (
    sub_type_id NUMBER NOT NULL,
    type        VARCHAR2(10),
    price       NUMBER,
    meal_count  NUMBER(4),
 CONSTRAINT subscription_type_pk PRIMARY KEY ( sub_type_id ),
 CONSTRAINT CHK_TYPE CHECK (TYPE IN ('WEEKLY', 'MONTHLY')),
 CONSTRAINT CHK_PRICE CHECK (PRICE IN (50, 180)),
 CONSTRAINT CHK_COUNT CHECK (MEAL_COUNT IN (10, 45))
 );
/
--SELECT * FROM SUBSCRIPTION_TYPE;
--TRUNCATE TABLE SUBSCRIPTION_TYPE;
-- Inserting data into the SUBSCRIPTION_TYPE table
INSERT INTO SUBSCRIPTION_TYPE (sub_type_id, type, price, meal_count)
VALUES (SUB_TYPE_SEQ.NEXTVAL, 'WEEKLY', 50, 10);

INSERT INTO SUBSCRIPTION_TYPE (sub_type_id, type, price, meal_count)
VALUES (SUB_TYPE_SEQ.NEXTVAL, 'MONTHLY', 180, 45);
/
CREATE SEQUENCE DP_SEQ
START WITH 333001
INCREMENT BY 1
NOCYCLE;
/
CREATE TABLE DELIVERY_PARTNER (
    dp_id        NUMBER NOT NULL,
    name         VARCHAR2(20 CHAR),
    phone_number NUMBER(10),
    email        VARCHAR2(50 CHAR),
    CONSTRAINT delivery_partner_pk PRIMARY KEY ( dp_id ));
/
-- Inserting data into the DELIVERY_PARTNER table
INSERT INTO DELIVERY_PARTNER (dp_id, name, phone_number, email)
VALUES (DP_SEQ.NEXTVAL, 'Express Delivery', 1234567890, 'express@example.com');

INSERT INTO DELIVERY_PARTNER (dp_id, name, phone_number, email)
VALUES (DP_SEQ.NEXTVAL, 'Swift Couriers', 9876543210, 'swift_couriers@example.com');

INSERT INTO DELIVERY_PARTNER (dp_id, name, phone_number, email)
VALUES (DP_SEQ.NEXTVAL, 'Quick Ship', 5551234567, 'quick_ship@example.com');

INSERT INTO DELIVERY_PARTNER (dp_id, name, phone_number, email)
VALUES (DP_SEQ.NEXTVAL, 'Speedy Delivery', 7890123456, 'speedy@example.com');

INSERT INTO DELIVERY_PARTNER (dp_id, name, phone_number, email)
VALUES (DP_SEQ.NEXTVAL, 'Rapid Express', 6543210987, 'rapid_express@example.com');
/
CREATE SEQUENCE MEAL_SEQ
START WITH 444001
INCREMENT BY 1
NOCYCLE;
/
CREATE TABLE MEAL (
    meal_id NUMBER NOT NULL,
    type    VARCHAR2(10 CHAR),
    CONSTRAINT meal_pk PRIMARY KEY ( meal_id ),
    CONSTRAINT CHK_MTYPE CHECK (TYPE IN ('VEG','NON-VEG','VEGAN','HALAL')));
/
-- Inserting data into the MEAL table
INSERT INTO MEAL (meal_id, type)
VALUES (MEAL_SEQ.NEXTVAL, 'VEG');

INSERT INTO MEAL (meal_id, type)
VALUES (MEAL_SEQ.NEXTVAL, 'NON-VEG');

INSERT INTO MEAL (meal_id, type)
VALUES (MEAL_SEQ.NEXTVAL, 'VEGAN');

INSERT INTO MEAL (meal_id, type)
VALUES (MEAL_SEQ.NEXTVAL, 'HALAL');
/
CREATE SEQUENCE CUSTOMER_SEQ
START WITH 555001
INCREMENT BY 1
NOCYCLE;
/
CREATE TABLE CUSTOMER (
    c_id         NUMBER NOT NULL,
    loc_id       NUMBER NOT NULL,
    c_name       VARCHAR2(20 CHAR),
    dob          DATE,
    gender       VARCHAR2(10 CHAR),
    email        VARCHAR2(50 CHAR),
    phone_number NUMBER(10),
    CONSTRAINT customer_pk PRIMARY KEY (c_id),
    CONSTRAINT customer_location_fk FOREIGN KEY ( loc_id ) REFERENCES location ( loc_id ));
/
-- Inserting data into the CUSTOMER table

-- SELECT * FROM CUSTOMER;
INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111001, 'John Doe', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 'Male', 'john.doe@example.com', 1234567890);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111002, 'Jane Smith', TO_DATE('1985-08-22', 'YYYY-MM-DD'), 'Female', 'jane.smith@example.com', 9876543210);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111003, 'Bob Johnson', TO_DATE('1978-12-10', 'YYYY-MM-DD'), 'Male', 'bob.johnson@example.com', 5551234567);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111004, 'Alice Williams', TO_DATE('1995-03-28', 'YYYY-MM-DD'), 'Female', 'alice.williams@example.com', 7890123456);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111005, 'Chris Davis', TO_DATE('1980-11-03', 'YYYY-MM-DD'), 'Non-Binary', 'chris.davis@example.com', 4567890123);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111001, 'Emma White', TO_DATE('1992-09-18', 'YYYY-MM-DD'), 'Female', 'emma.white@example.com', 9876543210);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111003, 'Mike Black', TO_DATE('1987-07-12', 'YYYY-MM-DD'), 'Male', 'mike.black@example.com', 1234567890);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111002, 'Sara Green', TO_DATE('1983-04-05', 'YYYY-MM-DD'), 'Female', 'sara.green@example.com', 5551234567);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111004, 'Alex Turner', TO_DATE('1998-01-25', 'YYYY-MM-DD'), 'Male', 'alex.turner@example.com', 7890123456);

INSERT INTO CUSTOMER (c_id, loc_id, c_name, dob, gender, email, phone_number)
VALUES (CUSTOMER_SEQ.NEXTVAL, 111005, 'Taylor Martinez', TO_DATE('1991-06-14', 'YYYY-MM-DD'), 'Non-Binary', 'taylor.martinez@example.com', 4567890123);

/
CREATE SEQUENCE SUB_SEQ
START WITH 666001
INCREMENT BY 1
NOCYCLE;
/
CREATE TABLE SUBSCRIPTION (
    sub_id           NUMBER NOT NULL,
    sub_date         DATE,
    end_date         DATE,
    sub_type_id      NUMBER NOT NULL,
    c_id             NUMBER NOT NULL,
    no_of_meals_left NUMBER,
CONSTRAINT subscription_pk PRIMARY KEY ( sub_id ),
CONSTRAINT subscription_customer_fkv2 FOREIGN KEY ( c_id ) REFERENCES customer ( c_id ),
CONSTRAINT subscription_subscription_type_fk FOREIGN KEY ( sub_type_id ) REFERENCES subscription_type ( sub_type_id ));
/

--DROP SEQUENCE SUB_SEQ;
-- Inserting data into the SUBSCRIPTION table
INSERT INTO SUBSCRIPTION (sub_id, sub_date, end_date, sub_type_id, c_id, no_of_meals_left)
VALUES (SUB_SEQ.NEXTVAL, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-01-31', 'YYYY-MM-DD'), 222001, 555001, 10);

INSERT INTO SUBSCRIPTION (sub_id, sub_date, end_date, sub_type_id, c_id, no_of_meals_left)
VALUES (SUB_SEQ.NEXTVAL, TO_DATE('2023-02-01', 'YYYY-MM-DD'), TO_DATE('2023-02-28', 'YYYY-MM-DD'), 222002, 555002, 45);

INSERT INTO SUBSCRIPTION (sub_id, sub_date, end_date, sub_type_id, c_id, no_of_meals_left)
VALUES (SUB_SEQ.NEXTVAL, TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2023-03-31', 'YYYY-MM-DD'), 222001, 555003,10);

INSERT INTO SUBSCRIPTION (sub_id, sub_date, end_date, sub_type_id, c_id, no_of_meals_left)
VALUES (SUB_SEQ.NEXTVAL, TO_DATE('2023-04-01', 'YYYY-MM-DD'), TO_DATE('2023-04-30', 'YYYY-MM-DD'), 222002, 555004, 45);

INSERT INTO SUBSCRIPTION (sub_id, sub_date, end_date, sub_type_id, c_id, no_of_meals_left)
VALUES (SUB_SEQ.NEXTVAL, TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2023-05-31', 'YYYY-MM-DD'), 222002, 555005, 45);

/
CREATE SEQUENCE PAYMENT_SEQ
START WITH 777001
INCREMENT BY 1
NOCYCLE;
/

-- DROP TABLE PYAMENT;
CREATE TABLE PAYMENT (
    pay_id           NUMBER NOT NULL,
    sub_id           NUMBER NOT NULL,
    transaction_date DATE,
    amount           NUMBER,
CONSTRAINT payment_pk PRIMARY KEY ( pay_id ),
CONSTRAINT payment__un UNIQUE ( sub_id ),
CONSTRAINT payment_subscription_fk FOREIGN KEY ( sub_id ) REFERENCES subscription ( sub_id ));
/
-- Inserting data into the PAYMENT table
INSERT INTO PAYMENT (pay_id, sub_id, transaction_date, amount)
VALUES (PAYMENT_SEQ.NEXTVAL, 666001, TO_DATE('2023-01-15', 'YYYY-MM-DD'), 50);

INSERT INTO PAYMENT (pay_id, sub_id, transaction_date, amount)
VALUES (PAYMENT_SEQ.NEXTVAL, 666002, TO_DATE('2023-02-10', 'YYYY-MM-DD'), 180);

INSERT INTO PAYMENT (pay_id, sub_id, transaction_date, amount)
VALUES (PAYMENT_SEQ.NEXTVAL, 666003, TO_DATE('2023-03-22', 'YYYY-MM-DD'), 50);

INSERT INTO PAYMENT (pay_id, sub_id, transaction_date, amount)
VALUES (PAYMENT_SEQ.NEXTVAL, 666004, TO_DATE('2023-04-05', 'YYYY-MM-DD'), 180);

INSERT INTO PAYMENT (pay_id, sub_id, transaction_date, amount)
VALUES (PAYMENT_SEQ.NEXTVAL, 666005, TO_DATE('2023-05-18', 'YYYY-MM-DD'), 180);

/
CREATE SEQUENCE BOOKING_SEQ
START WITH 777001
INCREMENT BY 1
NOCYCLE;
/
--DROP TABLE BOOKING;

CREATE TABLE BOOKING (
    BOOK_ID          NUMBER NOT NULL,
    C_ID             NUMBER NOT NULL,
    SUB_ID           NUMBER NOT NULL,
    MEAL_ID          NUMBER NOT NULL,
    BOOKING_DATE     DATE DEFAULT SYSDATE,
    DATE_OF_DELIVERY DATE,
    TIME_SLOT        VARCHAR2(10 CHAR),
    DP_ID            NUMBER NOT NULL,
    IS_DELIVERED     CHAR(1) CHECK(IS_DELIVERED IN ('Y','N')),
    CONSTRAINT booking_pk PRIMARY KEY ( book_id ),
    CONSTRAINT CHK_TIME_SLOT CHECK (time_slot IN ('AFTERNOON','NIGHT')),
    CONSTRAINT booking_customer_fk FOREIGN KEY (c_id) REFERENCES customer (c_id),
    CONSTRAINT booking_delivery_partner_fk FOREIGN KEY (dp_id) REFERENCES delivery_partner (dp_id),
    CONSTRAINT booking_meal_fk FOREIGN KEY ( meal_id ) REFERENCES meal ( meal_id ),
    CONSTRAINT booking_subscription_fk FOREIGN KEY ( sub_id ) REFERENCES subscription ( sub_id ));
/
--SELECT * FROM BOOKING;
-- Inserting data into the BOOKING table
INSERT INTO BOOKING (book_id, c_id, sub_id, meal_id, DATE_OF_DELIVERY, time_slot, dp_id, is_delivered)
VALUES (777001, 555001, 666001, 444001, TO_DATE('2023-11-20', 'YYYY-MM-DD'), 'AFTERNOON', 333001, 'N');

INSERT INTO BOOKING (book_id, c_id, sub_id, meal_id, BOOKING_DATE, DATE_OF_DELIVERY, time_slot, dp_id, is_delivered)
VALUES (777002, 555002, 666002, 444002, TO_DATE('2023-02-10', 'YYYY-MM-DD'), TO_DATE('2023-02-15', 'YYYY-MM-DD'), 'NIGHT', 333002, 'Y');

INSERT INTO BOOKING (book_id, c_id, sub_id, meal_id, BOOKING_DATE, DATE_OF_DELIVERY, time_slot, dp_id, is_delivered)
VALUES (777003, 555003, 666003, 444003, TO_DATE('2023-03-22', 'YYYY-MM-DD'), TO_DATE('2023-03-27', 'YYYY-MM-DD'), 'AFTERNOON', 333001, 'N');

INSERT INTO BOOKING (book_id, c_id, sub_id, meal_id, BOOKING_DATE, DATE_OF_DELIVERY, time_slot, dp_id, is_delivered)
VALUES (777004, 555004, 666004, 444004, TO_DATE('2023-04-05', 'YYYY-MM-DD'), TO_DATE('2023-04-10', 'YYYY-MM-DD'), 'NIGHT', 333002, 'Y');

INSERT INTO BOOKING (book_id, c_id, sub_id, meal_id, BOOKING_DATE, DATE_OF_DELIVERY, time_slot, dp_id, is_delivered)
VALUES (777005, 555005, 666005, 444001, TO_DATE('2023-05-18', 'YYYY-MM-DD'), TO_DATE('2023-05-23', 'YYYY-MM-DD'), 'AFTERNOON', 333001, 'N');
/
--ALTER TABLE BOOKING ADD CONSTRAINT CHK_DOD CHECK( DATE_OF_DELIVERY >= TRUNC(SYSDATE));
--ALTER TABLE BOOKING ADD CONSTRAINT CHK_BOOKING_DATE CHECK( BOOKING_DATE >= TRUNC(SYSDATE));
