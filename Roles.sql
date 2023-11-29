--select * from dual;

CREATE TABLE role_audit (
  role_name VARCHAR(30) NOT NULL,
  created_at DATE NOT NULL,
  created_by VARCHAR(30) NOT NULL
);

-- SELECT * FROM USER_TRIGGERS;
--  SELECT * FROM DBA_ROLES;
--  
--  drop role manager;
--  drop role customer;
--  drop role delivery_person;
SELECT * FROM role_audit
/
 
-- drop trigger role_audit_trigger;
--/
--
--
--CREATE OR REPLACE TRIGGER role_audit_trigger
--BEFORE CREATE ON DATABASE
--DECLARE
--  v_role_name VARCHAR2(30);
--BEGIN
--  -- Use SYS_CONTEXT to get the current SQL statement
--  SELECT SYS_CONTEXT('USERENV', 'CURRENT_SQL') INTO v_role_name FROM DUAL;
--
--  -- Extract the role name from the SQL statement
--  v_role_name := regexp_substr(v_role_name, 'CREATE ROLE (.+)', 1, 1, NULL, 1);
--
--  -- Check if the role name is not NULL before inserting into the audit table
--  IF v_role_name IS NOT NULL THEN
--    -- Insert into the audit table
--    INSERT INTO role_audit (role_name, created_at, created_by)
--    VALUES (v_role_name, SYSDATE, USER);
--  END IF;
--END;
--/
--
--
--
--
--DECLARE
--  v_role_name VARCHAR2(30);
--BEGIN
--  -- Loop through the role_audit table
--  FOR role_rec IN (SELECT role_name FROM role_audit) 
--  LOOP
--    v_role_name := role_rec.role_name;
--
--    -- Use dynamic SQL to drop the role
--    EXECUTE IMMEDIATE 'DROP ROLE ' || v_role_name;
--       
--  END LOOP;
--END;
--/



--CREATES ROLES 
CREATE ROLE CUSTOMER;
CREATE ROLE MANAGER;
CREATE ROLE DELIVERY_PERSON;

-- Customer
-- grant permission to views
-------------------------------
/
GRANT SELECT ON  DELIVERY_DETAILS_VIEW TO CUSTOMER;
/
GRANT SELECT ON  CUSTOMER_CHOICE_BY_SEASON_VIEW TO CUSTOMER;

-- DELIVERY_PERSON
-- grant permission to views
-------------------------------
/
GRANT SELECT ON  DELIVERY_SCHEDULE_VIEW TO DELIVERY_PERSON;
/
GRANT SELECT ON  DELIVERY_DETAILS_VIEW TO DELIVERY_PERSON;
/

-- Manager
--grant permission to views

GRANT SELECT ON  POPULAR_MEAL_BY_SUBSCRIPTION_VIEW TO MANAGER;
/
GRANT SELECT ON REVENUE_VIEW TO MANAGER;
/

--- Grant roles for users
----------------------------------------------------
GRANT MANAGER TO MGR00001;
/
GRANT MANAGER TO MGR00002;
/
GRANT MANAGER TO MGR00003;
/
GRANT MANAGER TO MGR00004;

----------------------------------

GRANT CUSTOMER TO C00001;
/
GRANT CUSTOMER TO C00002;
/
GRANT CUSTOMER TO C00003;
/
GRANT CUSTOMER TO C00004;
------------------------------

GRANT DELIVERY_PERSON TO DP00001;
/
GRANT DELIVERY_PERSON TO DP00002;
/
GRANT DELIVERY_PERSON TO DP00003;
/
GRANT DELIVERY_PERSON TO DP00004;
/
--------------------------------------