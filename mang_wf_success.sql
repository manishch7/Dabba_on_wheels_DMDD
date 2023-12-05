-- MANAGER procedure executions 

-- procedure 9 execution
--select * from subscription_type;

BEGIN
    add_or_update_subscription_type('Quaterly', 500,150);
END;
/

-- procedure 11 execution
-- select * from meal;

BEGIN
    add_meal('DABBA_SPL');
END;
/

-- procedure 14 execution
-- select * from DELIVERY_PARTNER;
BEGIN
    create_delivery_partner(p_d_name => 'new_delivery_person', p_phone_number => 9998887777, p_email => 'new_dp@example.com');
END;
/

--views the schedule to assign the delivery partner to a booking.
-- select * from delivery_schedule_view;

-- procedure 13 execution
--select * from booking;
BEGIN
    update_booking_delivery_partner(p_booking_id => 777001, p_dp_id => DP_SEQ.CURRVAL);
    update_booking_delivery_partner(p_booking_id => 777003, p_dp_id => DP_SEQ.CURRVAL);
END;
/

