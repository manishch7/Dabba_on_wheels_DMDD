--drop trigger trg_update_subscription_meals;

SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_update_subscription_meals
AFTER INSERT ON BOOKING
FOR EACH ROW
DECLARE
v_sub_id number;
BEGIN
    SELECT s.sub_id into v_sub_id FROM subscription s WHERE s.c_id = :OLD.c_id
    AND s.end_date >= TRUNC(SYSDATE);
   -- Update the no_of_meals in the subscription table
    update subscription set no_of_meals_left = no_of_meals_left - 1 
    where sub_id = v_sub_id;
END;
/
