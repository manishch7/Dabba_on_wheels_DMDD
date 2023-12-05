# Dabba_on_wheels_DMDD

![alt text](https://github.com/Jaswanth-marri/Dabba_on_wheels_DMDD/blob/Jaswanth_marri_feature/Relational_1.png?raw=true)

## Customer Workflow
1. Customer registers and creates an account.
2. View the available subscription plans.
3. Customer chooses a plan, makes a payment, and purchases a subscription plan.
4. Views the available meal options, and chooses to book a meal according to his/her convenience.
5. Customer can view the booking details and can generate invoices if required to date.
6. Customer also has an option to update their details.

## Manager Workflow
1. The manager has access to assign the delivery persons to the bookings that are yet to be delivered.
2. The manager also has access to add and update subscription types, add meal options, and onboard delivery partners to the system.

## Delivery partner Workflow
1. The Delivery partner can view all the pending deliveries assigned to him.
2. Also has access to update the delivery status for a booking he is associated with.
3. Delivery partner also has an option to update their details.

## Code Execution
1. Creation of tables, constraints, and inserting records.(DB_OBJECTS_CREATION_SCRIPTS.sql)
2. Reports are written in the form of views. (VIEWS_SCRIPTS.sql)
3. Creation of procedures for customer, manager, and delivery partner.(create_proceduresl.sql)
4. User creations. (create_users.sql) (we can't drop users after assigning the roles, we need to drop roles and then drop users)
5. Roles are created and roles are assigned to users. Users are granted access to required views, and procedures. (Roles.sql)

