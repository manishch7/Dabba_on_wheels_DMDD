create or replace view SUBSCRIPTION_VIEW as
select s.c_id,s.sub_id,p.pay_id,p.amount,p.transaction_date,s.start_date,s.end_date,s.sub_type_id,st.type,st.meal_count,s.no_of_meals_left
from payment p 
left join subscription s
on p.sub_id = s.sub_id
left join SUBSCRIPTION_TYPE st
on st.sub_type_id = s.sub_type_id;

create or replace view DELIVERY_DETAILS as
SELECT b.dp_id, c.c_name, c.c_phone_number, dp.d_name, dp.d_phone_number,
( l.unit ||', ' || l.street_address||', ' || l.city ||', ' || l.state ||', ' || l.zipcode) as address,
b.book_id, b.time_slot, b.date_of_delivery, m.type, b.is_delivered
from booking b
left join delivery_partner dp
on b.dp_id = dp.dp_id
left join customer c
on b.c_id = c.c_id
left join meal m
on b.meal_id = m.meal_id
left join location l
on c.loc_id = l.loc_id;

create or replace view Orders_view as
select b.book_id, b.booking_date,b.time_slot, m.type, b.date_of_delivery, b.is_delivered
from booking b
left join meal m
on b.meal_id = m.meal_id;
