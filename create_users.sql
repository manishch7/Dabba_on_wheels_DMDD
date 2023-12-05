-- drop user C00004;
-- select * from user_users;
-- select * from dba_users;
--The error was improper use of the DROP USER statement within a PL/SQL block. 
--The DROP USER statement is a DDL (Data Definition Language) statement, and it cannot be directly executed within PL/SQL blocks like a FOR loop.
-- we can't drop a user when it assigned a role.
SET SERVEROUTPUT ON
/
BEGIN
  FOR audit_rec IN (select * from dba_users where oracle_maintained = 'N' 
  and account_status = 'OPEN' and Authentication_type = 'PASSWORD' and profile = 'DEFAULT')
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP USER ' || audit_rec.username;
      DBMS_OUTPUT.PUT_LINE('Dropped the user with UserName: ' || audit_rec.username);
      DBMS_OUTPUT.PUT_LINE('=======================================================');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping user ' || audit_rec.username || ': ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('=======================================================');
    END;
  END LOOP;
END;
/

--creating customer users
create user C00001 identified by Welcome_123456789;
GRANT CREATE SESSION TO C00001;
GRANT UNLIMITED TABLESPACE TO C00001;

create user C00002 identified by Welcome_123456789;
GRANT CREATE SESSION TO C00002;
GRANT UNLIMITED TABLESPACE TO C00002; 

create user C00003 identified by Welcome_123456789;
GRANT CREATE SESSION TO C00003;
GRANT UNLIMITED TABLESPACE TO C00003; 

create user C00004 identified by Welcome_123456789;
GRANT CREATE SESSION TO C00004;
GRANT UNLIMITED TABLESPACE TO C00004; 

--creating  manager users
create user MGR00001 identified by Welcome_123456789;
GRANT CREATE SESSION TO MGR00001;
GRANT UNLIMITED TABLESPACE TO MGR00001; 

create user MGR00002 identified by Welcome_123456789;
GRANT CREATE SESSION TO MGR00002;
GRANT UNLIMITED TABLESPACE TO MGR00002; 

create user MGR00003 identified by Welcome_123456789;
GRANT CREATE SESSION TO MGR00003;
GRANT UNLIMITED TABLESPACE TO MGR00003;

create user MGR00004 identified by Welcome_123456789;
GRANT CREATE SESSION TO MGR00004;
GRANT UNLIMITED TABLESPACE TO MGR00004; 

-------------------------------------
create user DP00001 identified by Welcome_123456789;
GRANT CREATE SESSION TO DP00001;
GRANT UNLIMITED TABLESPACE TO DP00001;

create user DP00002 identified by Welcome_123456789;
GRANT CREATE SESSION TO DP00002;
GRANT UNLIMITED TABLESPACE TO DP00002;

create user DP00003 identified by Welcome_123456789;
GRANT CREATE SESSION TO DP00003;
GRANT UNLIMITED TABLESPACE TO DP00003;

create user DP00004 identified by Welcome_123456789;
GRANT CREATE SESSION TO DP00004;
GRANT UNLIMITED TABLESPACE TO DP00004;

--creating users by our names 
CREATE USER Jaswanth IDENTIFIED BY Welcome_123456789;
GRANT CREATE SESSION TO Jaswanth;
GRANT UNLIMITED TABLESPACE TO Jaswanth; 
CREATE USER Manish IDENTIFIED BY Welcome_123456789;
GRANT CREATE SESSION TO Manish;
GRANT UNLIMITED TABLESPACE TO Manish; 
CREATE USER Chirag IDENTIFIED BY Welcome_123456789;
GRANT CREATE SESSION TO Chirag;
GRANT UNLIMITED TABLESPACE TO Chirag; 
