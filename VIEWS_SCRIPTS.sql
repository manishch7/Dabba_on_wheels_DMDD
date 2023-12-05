-- 1. Revenue Report View
-- This view takes input from customer table, subscription and payment table
-- This view generates revenue by customer in order of highest contribution to lowest. 

-- select * from admin.REVENUE_VIEW;

create or replace view REVENUE_VIEW as
SELECT C.C_ID ,C.C_NAME as customer_name, COUNT(S.SUB_ID) AS NUM_SUBSCRIPTIONS, NVL(SUM(P.AMOUNT), 0) AS CUSTOMER_EXPENDITURE,
(case when (select sum(amount) from payment) != 0 then (NVL(SUM(P.AMOUNT), 0)/(select sum(amount) from payment)) *100
else 0 end) as contribution,(select sum(amount) from payment) as TOTAL_REVENUE FROM CUSTOMER C LEFT JOIN SUBSCRIPTION S ON C.C_ID = S.C_ID
LEFT JOIN PAYMENT P ON S.SUB_ID = P.SUB_ID GROUP BY C.C_ID, C.C_NAME,P.AMOUNT ORDER BY NUM_SUBSCRIPTIONS DESC;

-- 2. Delivery Details Comprehensive View
-- 		This view will provide delivery details of customers
-- 		This view takes input from location table, booking table, meal table, delivery_partner and customer table 
-- 	    This view generates delivery status of order, delivery date and delivery driver details 

-- select * from DELIVERY_DETAILS_view;

create or replace view DELIVERY_DETAILS_view as
SELECT C.C_ID AS CUSTOMER_ID,c.c_name as customer_name,  c.c_phone_number as customer_contact ,b.book_id,b.time_slot, b.date_of_delivery, m.type as meal_type,
b.is_delivered as delivery_status, dp.d_name as delivery_person, dp.d_phone_number as delivery_person_contact,
( l.street_address||', ' || l.city ||', ' || l.state ||', ' || l.zipcode) as address
from booking b
left join delivery_partner dp
on b.dp_id = dp.dp_id
left join customer c
on b.c_id = c.c_id
left join meal m
on b.meal_id = m.meal_id
left join location l
on c.loc_id = l.loc_id;

-- 3. Popular Meal View
-- 		This view takes input from location table, booking table, meal table, delivery_partner and customer table 
--      This view will provide popular meal among the subscription types for the manager

-- select * from POPULAR_MEAL_BY_SUBSCRIPTION_VIEW;

create or replace view POPULAR_MEAL_BY_SUBSCRIPTION_VIEW as
WITH SubscriptionMealCounts AS (
    SELECT ST.TYPE AS SUBSCRIPTION_TYPE, M.TYPE AS MEAL_TYPE, COUNT(*) AS MEAL_COUNT
    FROM SUBSCRIPTION S JOIN SUBSCRIPTION_TYPE ST ON S.SUB_TYPE_ID = ST.SUB_TYPE_ID
    JOIN BOOKING B ON S.SUB_ID = B.SUB_ID JOIN MEAL M ON B.MEAL_ID = M.MEAL_ID GROUP BY ST.TYPE, M.TYPE
    )
select SUBSCRIPTION_TYPE, MEAL_TYPE, MEAL_COUNT from (
SELECT SUBSCRIPTION_TYPE, MEAL_TYPE, MEAL_COUNT,
RANK() OVER (PARTITION BY SUBSCRIPTION_TYPE ORDER BY MEAL_COUNT DESC) AS RANKING
FROM SubscriptionMealCounts
)
WHERE RANKING = 1;


-- 4. Delivery schedule View
-- 		This view takes input from location table, booking table, meal table, delivery_partner and customer table 
--      This view will provide popular meal among the subscription types for manager

-- select * from DELIVERY_SCHEDULE_VIEW;

create or replace view DELIVERY_SCHEDULE_VIEW as
SELECT
    DP.DP_ID as DELIVERY_PERSON_ID,
    DP.D_NAME AS DELIVERY_PERSON,
    TO_CHAR(B.DATE_OF_DELIVERY, 'YYYY-MM-DD') AS DELIVERY_DATE,
    B.BOOK_ID,
    B.is_delivered as delivery_status,
    C.C_NAME AS CUSTOMER_NAME,
    L.STREET_ADDRESS || ', ' || L.CITY || ', ' || L.STATE || ' ' || L.ZIPCODE AS DELIVERY_ADDRESS,
    B.TIME_SLOT
FROM
    BOOKING B
JOIN
    CUSTOMER C ON B.C_ID = C.C_ID
JOIN
    DELIVERY_PARTNER DP ON B.DP_ID = DP.DP_ID
JOIN
    LOCATION L ON C.LOC_ID = L.LOC_ID
ORDER BY
    DP.D_NAME, B.DATE_OF_DELIVERY, B.TIME_SLOT, B.BOOK_ID;


-- 5. Customer popular choice View
-- 		This view takes input from location table, booking table, meal table, delivery_partner and customer table 
--      This view will provide popular meal among the subscription types for manager

-- select * from CUSTOMER_CHOICE_BY_SEASON_VIEW;

create or replace view CUSTOMER_CHOICE_BY_SEASON_VIEW as 
with POPULAR_MEALS as (
SELECT
    CASE
        WHEN TO_CHAR(B.DATE_OF_DELIVERY, 'MM') IN ('12', '01', '02') THEN 'Winter'
        WHEN TO_CHAR(B.DATE_OF_DELIVERY, 'MM') IN ('03', '04', '05') THEN 'Spring'
        WHEN TO_CHAR(B.DATE_OF_DELIVERY, 'MM') IN ('06', '07', '08') THEN 'Summer'
        WHEN TO_CHAR(B.DATE_OF_DELIVERY, 'MM') IN ('09', '10', '11') THEN 'Fall'
        ELSE 'None' -- Handle cases where month is not in 1-12 range
    END AS SEASON, M.TYPE AS MEAL_TYPE, COUNT(B.MEAL_ID) AS BOOKING_COUNT
FROM BOOKING B
LEFT JOIN MEAL M ON B.MEAL_ID = M.MEAL_ID
GROUP BY TO_CHAR(B.DATE_OF_DELIVERY, 'MM'), M.TYPE)
--ORDER BY
--    SEASON, COUNT(B.MEAL_ID) DESC)
   select SEASON, MEAL_TYPE, BOOKING_COUNT from (Select SEASON, MEAL_TYPE, BOOKING_COUNT, 
   RANK() OVER (PARTITION BY season, meal_type ORDER BY BOOKING_COUNT DESC) AS RANKING
FROM POPULAR_MEALS) where RANKING = 1;


