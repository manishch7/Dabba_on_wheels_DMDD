
-- procedure 15 execution
select *from booking;
SET SERVEROUTPUT ON
BEGIN
    admin.view_pending_deliveries(333001);
END;
/

-- procedure 16 execution
SET SERVEROUTPUT ON
BEGIN
    admin.update_delivery_status(333001, 777005, 'y');
END;
/

-- procedure 17 execution
--select * from DELIVERY_PARTNER;

BEGIN
    admin.update_delivery_partner(p_dp_id => null, p_d_name => 'New Express Delivery');
    admin.update_delivery_partner(p_dp_id => 333001);
    admin.update_delivery_partner(p_dp_id => 3, p_d_email => 'new_quick_ship@example.com');
END;
/

