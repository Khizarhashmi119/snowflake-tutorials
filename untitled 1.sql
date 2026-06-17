-- Select Role
USE ROLE ACCOUNTADMIN;
-- Create Warehouse
CREATE
OR REPLACE WAREHOUSE FIRST_WH
WITH
    WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 300 AUTO_RESUME = TRUE SCALING_POLICY = 'ECONOMY';

-- Alter Warehouse
ALTER WAREHOUSE FIRST_WH SUSPEND;
ALTER WAREHOUSE FIRST_WH RESUME;
ALTER WAREHOUSE FIRST_WH
SET
    AUTO_SUSPEND = 600;
-- Drop Database
DROP WAREHOUSE FIRST_WH;
-- Create Database
CREATE DATABASE EXERCISE_DB;
-- Create Table
CREATE TABLE EXERCISE_DB.PUBLIC.CUSTOMERS (
    "ID" INT,
    "first_name" varchar,
    "last_name" varchar,
    "email" varchar,
    "age" int,
    "city" varchar
);
-- Copy into table
COPY INTO EXERCISE_DB.PUBLIC.CUSTOMERS
FROM
    's3://snowflake-assignments-mc/gettingstarted/customers.csv' FILE_FORMAT = (TYPE = csv FIELD_DELIMITER = ',' SKIP_HEADER = 1);
-- Count
SELECT
    COUNT(*)
FROM
    EXERCISE_DB.PUBLIC.CUSTOMERS;

CREATE TABLE FIRST_TABLE (FIRST_COL INT, SECOND_COL VARCHAR) COMMENT = 'This is my first table.';

-- Rename database & creating the table + meta data
ALTER DATABASE FIRST_DB
RENAME TO OUR_FIRST_DB;

CREATE TABLE IF NOT EXISTS "OUR_FIRST_DB"."PUBLIC"."LOAN_PAYMENT" (
    "Loan_ID" STRING,
    "loan_status" STRING,
    "Principal" STRING,
    "terms" STRING,
    "effective_date" STRING,
    "due_date" STRING,
    "paid_off_time" STRING,
    "past_due_days" STRING,
    "age" STRING,
    "education" STRING,
    "Gender" STRING
);

-- Check that table is empty
USE DATABASE OUR_FIRST_DB;
USE SCHEMA PUBLIC;

-- Loading the data from S3 bucket
COPY INTO LOAN_PAYMENT
FROM
    's3://bucketsnowflakes3/Loan_payments_data.csv' FILE_FORMAT = (TYPE = csv FIELD_DELIMITER = ',' SKIP_HEADER = 1);

-- Validate
SELECT
    COUNT(*)
FROM
    LOAN_PAYMENT;

-- Database to manage stage objects, fileformats etc.
CREATE
OR REPLACE DATABASE MANAGE_DB;
CREATE
OR REPLACE SCHEMA EXTERNAL_STAGES;
-- Creating external stage
CREATE
OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE URL = 's3://bucketsnowflakes3' CREDENTIALS = (
    AWS_KEY_ID = 'ABCD_DUMMY_ID' AWS_SECRET_KEY = '1234abcd_key'
);
-- Description of external stage
DESC STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE;
-- Alter external stage
ALTER STAGE AWS_STAGE
SET
    CREDENTIALS = (
        AWS_KEY_ID = 'XYZ_DUMMY_ID' AWS_SECRET_KEY = '987xyz'
    );
-- Publicly accessible staging area
CREATE
OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE URL = 's3://bucketsnowflakes3';
-- List files in stage
LIST @AWS_STAGE;
--Load data using copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM
    @AWS_STAGE
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*';

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(50),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.ORDERS;

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM
    @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1) FILES = ('OrderDetails.csv');

CREATE
OR REPLACE STAGE CUSTOMER_STAGE URL = 's3://snowflake-assignments-mc/loadingdata/';

LIST @CUSTOMER_STAGE;

COPY INTO EXERCISE_DB.PUBLIC.CUSTOMERS
FROM
    @CUSTOMER_STAGE FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ';' SKIP_HEADER = 1);