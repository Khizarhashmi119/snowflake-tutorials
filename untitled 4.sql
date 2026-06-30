-- Merged txt files
-- Generated : 2026-06-28 12:05:20
-- Total files: 78
--============================================================


--============================================================
-- FILE: All resources/Section 2 - Getting started/11 Loading data in snowflake/Loading data.txt
--============================================================

-- Creating the table / meta data
CREATE OR REPLACE DATABASE "OUR_FIRST_DB";

CREATE TABLE "OUR_FIRST_DB"."PUBLIC"."LOAN_PAYMENT" (
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

SELECT * FROM LOAN_PAYMENT;

-- Loading the data from S3 bucket
COPY INTO LOAN_PAYMENT
FROM 's3://bucketsnowflakes3/Loan_payments_data.csv'
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
);

-- Validate
SELECT * FROM LOAN_PAYMENT;

--============================================================
-- FILE: All resources/Section 4 - Loading data/20 Creating stage/Create Stage.txt
--============================================================

-- Database to manage stage objects, file formats etc.
CREATE OR REPLACE DATABASE MANAGE_DB;

CREATE OR REPLACE SCHEMA EXTERNAL_STAGES;


-- Creating external stage
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
URL='s3://bucketsnowflakes3'
CREDENTIALS=(
    AWS_KEY_ID='ABCD_DUMMY_ID'
    AWS_SECRET_KEY='1234abcd_key'
);


-- Description of external stage
DESC STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE;

-- Alter external stage
ALTER STAGE AWS_STAGE
SET CREDENTIALS=(
    AWS_KEY_ID='XYZ_DUMMY_ID'
    AWS_SECRET_KEY='987xyz'
);

-- Publicly accessible staging area
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
URL='s3://bucketsnowflakes3';

-- List files in stage
LIST @AWS_STAGE;

-- Load data using copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM @AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV 
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*';


--============================================================
-- FILE: All resources/Section 4 - Loading data/21 COPY command/COPY Command.txt
--============================================================

-- Creating orders table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS;

-- First copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM @AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
);

-- Copy command with fully qualified stage object
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
);


-- List files contained in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE;

-- Copy command with specified file(s)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails.csv');


-- Copy command with pattern for file names
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*';


--============================================================
-- FILE: All resources/Section 4 - Loading data/22 Transforming data/Transforming data.txt
--============================================================

-- Transforming using the SELECT statement
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM (
    SELECT 
        S.$1,
        S.$2
    FROM 
        @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE S
    )
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails.csv');


-- Example 1 - Table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT
);

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 2 - Table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)
);

-- Example 2 - copy command using a sql function (subset of functions available)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM (
    SELECT
        S.$1,
        S.$2,
        S.$3,
        CASE
            WHEN CAST(S.$3 AS INT) < 0 THEN 'not profitable'
                ELSE 'profitable'
            END
    FROM
        @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE S
)
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails.csv');


SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 3 - Table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    CATEGORY_SUBSTRING VARCHAR(5)
);

-- Example 3 - copy command using a sql function (subset of functions available)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM (
    SELECT
        S.$1,
        S.$2,
        S.$3,
        SUBSTRING(S.$5, 1, 5)
    FROM
        @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE S
)
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

--============================================================
-- FILE: All resources/Section 4 - Loading data/23 More transformations/More transformations.txt
--============================================================

-- Example 3 - Table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)
);

-- Example 4 - using subset of columns
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX (ORDER_ID, PROFIT)
FROM (
    SELECT
        S.$1,
        S.$3
    FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE S
)
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 5 - Table auto increment
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID NUMBER AUTOINCREMENT START 1 INCREMENT 1,
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)
);

-- Example 5 - auto increment id
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX (PROFIT, AMOUNT)
FROM (
    SELECT
        S.$2,
        S.$3
    FROM
        @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE S
)
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails.csv');

SELECT * 
FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX
WHERE ORDER_ID > 15;

DROP TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

--============================================================
-- FILE: All resources/Section 4 - Loading data/24 Copy options & ON_ERROR/Copy options & ON_ERROR.txt
--============================================================

-- Create new stage
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
URL='s3://bucketsnowflakes4';

-- List files in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX;

-- Create example table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Demonstrating error message
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails_error.csv');
-- FILES=('OrderDetails_error2.csv');

-- Validating table is empty
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails_error.csv')
ON_ERROR='CONTINUE';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

SELECT COUNT(*)
FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option=ABORT_STATEMENT (default)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=(
    'OrderDetails_error.csv',
    'OrderDetails_error2.csv'
)
ON_ERROR='ABORT_STATEMENT';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

SELECT COUNT(*)
FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option=SKIP_FILE
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=(
    'OrderDetails_error.csv',
    'OrderDetails_error2.csv'
)
ON_ERROR='SKIP_FILE'; -- Skip the file that contains errors

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

SELECT COUNT(*)
FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option=SKIP_FILE_<number>
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=(
    'OrderDetails_error.csv',
    'OrderDetails_error2.csv'
)
ON_ERROR='SKIP_FILE_2';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

SELECT COUNT(*)
FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option=SKIP_FILE_<number>
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=(
    'OrderDetails_error.csv',
    'OrderDetails_error2.csv'
)
ON_ERROR='SKIP_FILE_0.5%';

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=(
    'OrderDetails_error.csv',
    'OrderDetails_error2.csv'
)
ON_ERROR='SKIP_FILE_3'
SIZE_LIMIT=30;

--============================================================
-- FILE: All resources/Section 4 - Loading data/25 FILE FORMAT object/FILE FORMAT.txt
--============================================================

-- Specifying file_format in copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=(
    'OrderDetails_error.csv',
    'OrderDetails_error2.csv'
)
ON_ERROR='SKIP_FILE_3';

-- Creating table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Creating schema to keep things organized
CREATE OR REPLACE SCHEMA MANAGE_DB.FILE_FORMATS;

-- Creating FILE FORMAT object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- See properties of FILE FORMAT object
DESC FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- Using FILE FORMAT object in copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    FORMAT_NAME=MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
)
FILES=('OrderDetails_error.csv')
ON_ERROR='SKIP_FILE_3';

-- Altering FILE FORMAT object
ALTER FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
SET SKIP_HEADER=1;

-- Defining properties on creation of FILE FORMAT object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
TYPE=JSON,
TIME_FORMAT=AUTO;

-- See properties of FILE FORMAT object
DESC FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- Using FILE FORMAT object in copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    FORMAT_NAME=MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
)
FILES=('OrderDetails_error.csv')
ON_ERROR='SKIP_FILE_3';

-- ERROR: Altering the type of a FILE FORMAT is not possible
ALTER FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
SET TYPE=CSV;

-- Recreate FILE FORMAT (default=csv)
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- See properties of FILE FORMAT object
DESC FILE FORMAT MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT;

-- Truncate table
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Overwriting properties of FILE FORMAT object
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM  @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX
FILE_FORMAT=(
    FORMAT_NAME=MANAGE_DB.FILE_FORMATS.MY_FILE_FORMAT
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
FILES=('OrderDetails_error.csv')
ON_ERROR='SKIP_FILE_3';

DESC STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE_ERROREX;

--============================================================
-- FILE: All resources/Section 5 - Copy options/28 VALIDATION_MODE/VALIDATION_MODE.txt
--============================================================

-- validation_mode --
-- Prepare database & table
CREATE OR REPLACE DATABASE COPY_DB;

CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Prepare stage object
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_COPY
URL='s3://snowflakebucket-copyoption/size/';

LIST @COPY_DB.PUBLIC.AWS_STAGE_COPY;

-- Load data using copy command
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
VALIDATION_MODE=RETURN_ERRORS;

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
VALIDATION_MODE=RETURN_5_ROWS;

--============================================================
-- FILE: All resources/Section 5 - Copy options/29 Working with rejected records/Rejected_records.txt
--============================================================

-- use files with errors --
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_COPY
URL='s3://snowflakebucket-copyoption/returnfailed/';

LIST @COPY_DB.PUBLIC.AWS_STAGE_COPY;

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
VALIDATION_MODE=RETURN_ERRORS;

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
VALIDATION_MODE=RETURN_1_ROWS;

-- working with error results --

-- 1) saving rejected files after validation_mode --
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
VALIDATION_MODE=RETURN_ERRORS;
-- QUERY ID 👆: 01c55ea7-0109-9117-002e-f96700996c1a

-- Storing rejected /failed results in a table
-- Returns the ID of a specified query in the current session
SELECT LAST_QUERY_ID();

SET QUERY_ID='01c55ea7-0109-9117-002e-f96700996c1a';

SELECT * FROM TABLE(RESULT_SCAN($QUERY_ID));

CREATE OR REPLACE TABLE REJECTED AS
SELECT REJECTED_RECORD
FROM TABLE(RESULT_SCAN($QUERY_ID));

INSERT INTO REJECTED
SELECT REJECTED_RECORD
FROM TABLE(RESULT_SCAN($QUERY_ID));

SELECT * FROM REJECTED;

-- 2) saving rejected files without validation_mode --
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
ON_ERROR=CONTINUE;

-- Validates the files loaded in a past execution of the COPY INTO command
-- and returns all the errors encountered during the load,
-- rather than just the first error
CREATE OR REPLACE TABLE REJECTED AS
SELECT * FROM TABLE(VALIDATE(ORDERS, JOB_ID => '_last'));

-- 3) working with rejected records --
SELECT REJECTED_RECORD FROM REJECTED;

CREATE OR REPLACE TABLE REJECTED_VALUES AS
SELECT
    SPLIT_PART(REJECTED_RECORD,',',1) AS ORDER_ID,
    SPLIT_PART(REJECTED_RECORD,',',2) AS AMOUNT,
    SPLIT_PART(REJECTED_RECORD,',',3) AS PROFIT,
    SPLIT_PART(REJECTED_RECORD,',',4) AS QUANTITY,
    SPLIT_PART(REJECTED_RECORD,',',5) AS CATEGORY,
    SPLIT_PART(REJECTED_RECORD,',',6) AS SUBCATEGORY
FROM REJECTED;

SELECT * FROM REJECTED_VALUES;

--============================================================
-- FILE: All resources/Section 5 - Copy options/30 SIZE_LIMIT/SIZE_LIMIT.txt
--============================================================

-- size_limit --
-- Prepare database & table
CREATE OR REPLACE DATABASE COPY_DB;

CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Prepare stage object
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_COPY
URL='s3://snowflakebucket-copyoption/size/';

-- List files in stage
LIST @AWS_STAGE_COPY;

-- Load data using copy command
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
SIZE_LIMIT=20000;

--============================================================
-- FILE: All resources/Section 5 - Copy options/31 RETURN_FAILED_ONLY/RETURN_FAILED_ONLY.txt
--============================================================
-- return_failed_only --
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Prepare stage object
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_COPY
URL='s3://snowflakebucket-copyoption/returnfailed/';

LIST @COPY_DB.PUBLIC.AWS_STAGE_COPY;

-- Load data using copy command
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
RETURN_FAILED_ONLY=TRUE;

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
ON_ERROR=CONTINUE
RETURN_FAILED_ONLY=TRUE;  -- Default=false

CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
ON_ERROR=CONTINUE;

--============================================================
-- FILE: All resources/Section 5 - Copy options/32 TRUNCATECOLUMNS/TRUCATECOLUMNS.txt
--============================================================

-- truncate columns --
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(10),
    SUBCATEGORY VARCHAR(30)
);

-- Prepare stage object
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_COPY
URL='s3://snowflakebucket-copyoption/size/';

LIST @COPY_DB.PUBLIC.AWS_STAGE_COPY;

-- Load data using copy command
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*';

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
TRUNCATECOLUMNS=TRUE;

SELECT * FROM ORDERS;

--============================================================
-- FILE: All resources/Section 5 - Copy options/33 FORCE/FORCE.txt
--============================================================

-- force --
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Prepare stage object
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.AWS_STAGE_COPY
URL='s3://snowflakebucket-copyoption/size/';

LIST @COPY_DB.PUBLIC.AWS_STAGE_COPY;

-- Load data using copy command
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*';

-- Not possible to load file that have been loaded and data has not been modified
COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*';

SELECT * FROM ORDERS;

-- Using the force option

COPY INTO COPY_DB.PUBLIC.ORDERS
FROM @AWS_STAGE_COPY
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*Order.*'
FORCE=TRUE;

--============================================================
-- FILE: All resources/Section 5 - Copy options/34 Load history/Load history.txt
--============================================================

-- Query load history within a database --
USE DATABASE COPY_DB;

SELECT
    *
FROM
    INFORMATION_SCHEMA.LOAD_HISTORY;

-- Query load history globally from SNOWFLAKE database --
SELECT
    *
FROM
    SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY;

-- Filter on specific table & schema
SELECT
    *
FROM
    SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY
WHERE
    SCHEMA_NAME = 'PUBLIC'
    AND TABLE_NAME = 'ORDERS';


-- Filter on specific table & schema
SELECT
    *
FROM
    SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY
WHERE
    SCHEMA_NAME = 'PUBLIC'
    AND TABLE_NAME = 'ORDERS'
    AND ERROR_COUNT > 0;


-- Filter on specific table & schema
SELECT
    *
FROM
    SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY
WHERE
    DATE(LAST_LOAD_TIME) <= DATEADD(DAYS, -1, CURRENT_DATE);

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/37 Creating stage & raw file/Create Stage & Load raw (JSON 1).txt
--============================================================

-- First step: load raw json
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE
URL='s3://bucketsnowflake-jsondemo';

LIST @MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE;

CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.JSONFORMAT
TYPE=JSON;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.JSON_RAW (RAW_FILE VARIANT);

COPY INTO OUR_FIRST_DB.PUBLIC.JSON_RAW
FROM @MANAGE_DB.EXTERNAL_STAGES.JSONSTAGE
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.JSONFORMAT
FILES=('HR_data.json');

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/38 Parsing JSON/Parse & Analyze (JSON 2).txt
--============================================================

-- Second step: parse & analyze raw json
-- Selecting attribute/column
SELECT RAW_FILE:city FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT $1:first_name FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

-- Selecting attribute/column - formatted
SELECT RAW_FILE:first_name::STRING AS FIRST_NAME  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT RAW_FILE:id::INT AS ID  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:id::INT AS ID,
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:last_name::STRING AS LAST_NAME,
    RAW_FILE:gender::STRING AS GENDER
FROM
    OUR_FIRST_DB.PUBLIC.JSON_RAW;

-- Handling nested data
SELECT RAW_FILE:job AS JOB  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/39 Handling nested data/Handling nested data (JSON 3).txt
--============================================================

-- Handling nested data
SELECT RAW_FILE:job AS JOB  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:JOB.salary::INT AS SALARY
FROM
    OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:job.salary::INT AS SALARY,
    RAW_FILE:job.title::STRING AS TITLE
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

-- Handling arrays
SELECT
    RAW_FILE:prev_company AS PREV_COMPANY
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:prev_company[1]::STRING AS PREV_COMPANY
FROM
    OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    ARRAY_SIZE(RAW_FILE:prev_company) AS PREV_COMPANY
FROM
    OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:id::INT AS ID,
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:prev_company[0]::STRING AS PREV_COMPANY
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
UNION ALL
    SELECT
    RAW_FILE:id::INT AS ID,
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:prev_company[1]::STRING AS PREV_COMPANY
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
ORDER BY ID;

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/40 Dealing with hierarchy/Dealing with hierarchy (JSON 4).txt
--============================================================

SELECT
    RAW_FILE:spoken_languages AS SPOKEN_LANGUAGES
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT * FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    ARRAY_SIZE(RAW_FILE:spoken_languages) AS SPOKEN_LANGUAGES
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    ARRAY_SIZE(RAW_FILE:spoken_languages) AS SPOKEN_LANGUAGES
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:spoken_languages[0] AS FIRST_LANGUAGE
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:spoken_languages[0] AS FIRST_LANGUAGE
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:spoken_languages[0].language::STRING AS FIRST_LANGUAGE,
    RAW_FILE:spoken_languages[0].level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:id::INT AS ID,
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:spoken_languages[0].language::STRING AS FIRST_LANGUAGE,
    RAW_FILE:spoken_languages[0].level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
UNION ALL
    SELECT
    RAW_FILE:id::INT AS ID,
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:spoken_languages[1].language::STRING AS FIRST_LANGUAGE,
    RAW_FILE:spoken_languages[1].level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
UNION ALL
    SELECT
    RAW_FILE:id::INT AS ID,
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    RAW_FILE:spoken_languages[2].language::STRING AS FIRST_LANGUAGE,
    RAW_FILE:spoken_languages[2].level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW
ORDER BY ID;

SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    F.VALUE:language::STRING AS FIRST_LANGUAGE,
    F.VALUE:level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW, TABLE(FLATTEN(RAW_FILE:spoken_languages)) F;

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/41 Insert final data/Insert the final data (JSON 5).txt
--============================================================

-- Option 1: create table as

CREATE OR REPLACE TABLE LANGUAGES AS
SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    F.VALUE:language::STRING AS FIRST_LANGUAGE,
    F.VALUE:level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW, TABLE(FLATTEN(RAW_FILE:spoken_languages)) F;

SELECT * FROM LANGUAGES;

TRUNCATE TABLE LANGUAGES;

-- Option 2: insert into
INSERT INTO LANGUAGES
SELECT
    RAW_FILE:first_name::STRING AS FIRST_NAME,
    F.VALUE:language::STRING AS FIRST_LANGUAGE,
    F.VALUE:level::STRING AS LEVEL_SPOKEN
FROM OUR_FIRST_DB.PUBLIC.JSON_RAW, TABLE(FLATTEN(RAW_FILE:spoken_languages)) F;

SELECT * FROM LANGUAGES;

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/42 Querying PARQUET data/Parquet data 1.txt
--============================================================

-- Create FILE FORMAT and stage object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT
TYPE='parquet';

CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE
URL='s3://snowflakeparquetdemo'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT;

-- Preview the data
LIST  @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE;

SELECT * FROM @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE LIMIT 10;

-- FILE FORMAT in queries
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE
URL='s3://snowflakeparquetdemo';

SELECT
    *
FROM
    @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE (
        FILE_FORMAT => 'MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT'
    )
LIMIT 10;

-- Quotes can be omitted in case of the current namespace
USE SCHEMA MANAGE_DB.FILE_FORMATS;

SELECT
    *
FROM
    @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE (
        FILE_FORMAT => MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT
    );


CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE
URL='s3://snowflakeparquetdemo'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.PARQUET_FORMAT;


-- Syntax for querying unstructured data

SELECT
    $1:__INDEX_LEVEL_0__,
    $1:CAT_ID,
    $1:DATE,
    $1:"__index_level_0__",
    $1:"cat_id",
    $1:"d",
    $1:"date",
    $1:"dept_id",
    $1:"id",
    $1:"item_id",
    $1:"state_id",
    $1:"store_id",
    $1:"value"
FROM
    @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE;

-- Date conversion
SELECT 1;

SELECT DATE(365*60*60*24);

-- Querying with conversions and aliases
SELECT
    $1:__index_level_0__::INT AS INDEX_LEVEL,
    $1:cat_id::VARCHAR(50) AS CATEGORY,
    DATE($1:date::INT ) AS DATE,
    $1:"dept_id"::VARCHAR(50) AS DEPT_ID,
    $1:"id"::VARCHAR(50) AS ID,
    $1:"item_id"::VARCHAR(50) AS ITEM_ID,
    $1:"state_id"::VARCHAR(50) AS STATE_ID,
    $1:"store_id"::VARCHAR(50) AS STORE_ID,
    $1:"value"::INT AS VALUE
FROM 
    @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE
LIMIT 10;

--============================================================
-- FILE: All resources/Section 6 - Loading unstructured data/43 Loading PARQUET data/Parquet data 2.txt
--============================================================

-- Adding metadata
SELECT
    $1:__index_level_0__::INT AS INDEX_LEVEL,
    $1:cat_id::VARCHAR(50) AS CATEGORY,
    DATE($1:date::INT ) AS DATE,
    $1:"dept_id"::VARCHAR(50) AS DEPT_ID,
    $1:"id"::VARCHAR(50) AS ID,
    $1:"item_id"::VARCHAR(50) AS ITEM_ID,
    $1:"state_id"::VARCHAR(50) AS STATE_ID,
    $1:"store_id"::VARCHAR(50) AS STORE_ID,
    $1:"value"::INT AS VALUE,
    METADATA$FILENAME AS FILENAME,
    METADATA$FILE_ROW_NUMBER AS ROWNUMBER,
    TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP) AS LOAD_DATE
FROM
    @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE
LIMIT 10;

SELECT TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP), CURRENT_TIMESTAMP;

-- Create destination table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.PARQUET_DATA (
    ROW_NUMBER INT,
    INDEX_LEVEL INT,
    CAT_ID VARCHAR(50),
    DATE DATE,
    DEPT_ID VARCHAR(50),
    ID VARCHAR(50),
    ITEM_ID VARCHAR(50),
    STATE_ID VARCHAR(50),
    STORE_ID VARCHAR(50),
    VALUE INT,
    LOAD_DATE TIMESTAMP DEFAULT TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP)
);

-- Load the parquet data
COPY INTO OUR_FIRST_DB.PUBLIC.PARQUET_DATA
FROM (
    SELECT
        METADATA$FILE_ROW_NUMBER,
        $1:__INDEX_LEVEL_0__::INT,
        $1:CAT_ID::VARCHAR(50),
        DATE($1:DATE::INT),
        $1:"dept_id"::VARCHAR(50),
        $1:"id"::VARCHAR(50),
        $1:"item_id"::VARCHAR(50),
        $1:"state_id"::VARCHAR(50),
        $1:"store_id"::VARCHAR(50),
        $1:"value"::INT,
        TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP)
    FROM
        @MANAGE_DB.EXTERNAL_STAGES.PARQUETSTAGE
);

SELECT * FROM OUR_FIRST_DB.PUBLIC.PARQUET_DATA LIMIT 10;

--============================================================
-- FILE: All resources/Section 7 - Performance optimization/46 Implement dedicated virtual warehouse/Dedicated VW.txt
--============================================================

--  Create virtual warehouse for data scientist & dba
-- Data scientists
CREATE WAREHOUSE DS_WH
WITH
    WAREHOUSE_SIZE='SMALL'
    WAREHOUSE_TYPE='STANDARD'
    AUTO_SUSPEND=300
    AUTO_RESUME=TRUE
    MIN_CLUSTER_COUNT=1
    MAX_CLUSTER_COUNT=1
    SCALING_POLICY='STANDARD';

-- Dba
CREATE WAREHOUSE DBA_WH
WITH 
    WAREHOUSE_SIZE='XSMALL'
    WAREHOUSE_TYPE='STANDARD'
    AUTO_SUSPEND=300
    AUTO_RESUME=TRUE
    MIN_CLUSTER_COUNT=1
    MAX_CLUSTER_COUNT=1
    SCALING_POLICY='STANDARD';

-- Create role for data scientists & dbas
CREATE ROLE DATA_SCIENTIST;

GRANT USAGE ON WAREHOUSE DS_WH TO ROLE DATA_SCIENTIST;

CREATE ROLE DBA;

GRANT USAGE ON WAREHOUSE DBA_WH TO ROLE DBA;

-- Setting up users with roles
-- Data scientists
CREATE USER DS1
PASSWORD='DS1'
LOGIN_NAME='DS1'
DEFAULT_ROLE='DATA_SCIENTIST'
DEFAULT_WAREHOUSE='DS_WH'
MUST_CHANGE_PASSWORD=FALSE;

CREATE USER DS2
PASSWORD='DS2'
LOGIN_NAME='DS2'
DEFAULT_ROLE='DATA_SCIENTIST'
DEFAULT_WAREHOUSE='DS_WH'
MUST_CHANGE_PASSWORD=FALSE;

CREATE USER DS3
PASSWORD='DS3'
LOGIN_NAME='DS3'
DEFAULT_ROLE='DATA_SCIENTIST'
DEFAULT_WAREHOUSE='DS_WH'
MUST_CHANGE_PASSWORD=FALSE;

GRANT ROLE DATA_SCIENTIST TO USER DS1;

GRANT ROLE DATA_SCIENTIST TO USER DS2;

GRANT ROLE DATA_SCIENTIST TO USER DS3;


-- Dbas
CREATE USER DBA1
PASSWORD='DBA1'
LOGIN_NAME='DBA1'
DEFAULT_ROLE='DBA'
DEFAULT_WAREHOUSE='DBA_WH'
MUST_CHANGE_PASSWORD=FALSE;

CREATE USER DBA2
PASSWORD='DBA2'
LOGIN_NAME='DBA2'
DEFAULT_ROLE='DBA'
DEFAULT_WAREHOUSE='DBA_WH'
MUST_CHANGE_PASSWORD=FALSE;

GRANT ROLE DBA TO USER DBA1;

GRANT ROLE DBA TO USER DBA2;

-- Drop objects again
DROP USER DBA1;

DROP USER DBA2;

DROP USER DS1;

DROP USER DS2;

DROP USER DS3;

DROP ROLE DATA_SCIENTIST;

DROP ROLE DBA;

DROP WAREHOUSE DS_WH;

DROP WAREHOUSE DBA_WH;

--============================================================
-- FILE: All resources/Section 7 - Performance optimization/48 Scaling out/Scaling Out.txt
--============================================================

SELECT
    *
FROM
    SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T1
    CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T2
    CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T3
    CROSS JOIN (
        SELECT
            TOP 57 *
        FROM
            SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE
    ) T4;

--============================================================
-- FILE: All resources/Section 7 - Performance optimization/50 Maximize Caching/Caching.txt
--============================================================

SELECT
    AVG(C_BIRTH_YEAR)
FROM
    SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Setting up an additional user
CREATE ROLE DATA_SCIENTIST;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE DATA_SCIENTIST;

CREATE USER DS1
PASSWORD='DS1'
LOGIN_NAME='DS1'
DEFAULT_ROLE='DATA_SCIENTIST'
DEFAULT_WAREHOUSE='DS_WH'
MUST_CHANGE_PASSWORD=FALSE;

GRANT ROLE DATA_SCIENTIST TO USER DS1;

--============================================================
-- FILE: All resources/Section 7 - Performance optimization/52 Clustering - Practice/Clustering.txt
--============================================================

-- Publicly accessible staging area
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
URL='s3://bucketsnowflakes3';

-- List files in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE;

-- Load data using copy command
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*OrderDetails.*';

-- Create table
CREATE OR REPLACE TABLE ORDERS_CACHING (
    ORDER_ID VARCHAR(30),
    AMOUNT NUMBER(38, 0),
    PROFIT NUMBER(38, 0),
    QUANTITY NUMBER(38, 0),
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30),
    DATE DATE
);

INSERT INTO
    ORDERS_CACHING
SELECT
    T1.ORDER_ID,
    T1.AMOUNT,
    T1.PROFIT,
    T1.QUANTITY,
    T1.CATEGORY,
    T1.SUBCATEGORY,
    DATE(UNIFORM(1500000000, 1700000000, (RANDOM())))
FROM
    ORDERS T1
    CROSS JOIN (
        SELECT
            *
        FROM
            ORDERS
    ) T2
    CROSS JOIN (
        SELECT
            TOP 100 *
        FROM
            ORDERS
    ) T3;

-- Query performance before cluster key
SELECT
    *
FROM
    ORDERS_CACHING
WHERE
    DATE = '2020-06-09';

-- Adding cluster key & compare the result
ALTER TABLE ORDERS_CACHING
CLUSTER BY
    (DATE);

SELECT
    *
FROM
    ORDERS_CACHING
WHERE
    DATE = '2020-01-05';

-- Not ideal clustering & adding a different cluster key using function
SELECT
    *
FROM
    ORDERS_CACHING
WHERE
    MONTH(DATE) = 11;

ALTER TABLE ORDERS_CACHING
CLUSTER BY
    (MONTH(DATE));

--============================================================
-- FILE: All resources/Section 8 - Loading from AWS/57 Creating integration object/Create Storage integration.txt
--============================================================

-- Create storage integration object
CREATE OR REPLACE STORAGE INTEGRATION S3_INT
TYPE=EXTERNAL_STAGE
STORAGE_PROVIDER=S3
ENABLED=TRUE
STORAGE_AWS_ROLE_ARN=''
STORAGE_ALLOWED_LOCATIONS=(
    's3://<your-bucket-name>/<your-path>/',
    's3://<your-bucket-name>/<your-path>/'
)
COMMENT='This an optional comment';

-- See storage integration properties to fetch external_id so we can update it in s3
DESC INTEGRATION S3_INT;

--============================================================
-- FILE: All resources/Section 8 - Loading from AWS/58 Loading from S3/Load data from S3.txt
--============================================================

-- Create table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.MOVIE_TITLES (
    SHOW_ID STRING,
    TYPE STRING,
    TITLE STRING,
    DIRECTOR STRING,
    CAST STRING,
    COUNTRY STRING,
    DATE_ADDED STRING,
    RELEASE_YEAR STRING,
    RATING STRING,
    DURATION STRING,
    LISTED_IN STRING,
    DESCRIPTION STRING
);

-- Create FILE FORMAT object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1
NULL_IF=('NULL','null')
EMPTY_FIELD_AS_NULL=TRUE;

-- Create stage object with integration object & FILE FORMAT object
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER
URL='s3://<your-bucket-name>/<your-path>/'
STORAGE_INTEGRATION=S3_INT
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT;

-- Use copy command
COPY INTO OUR_FIRST_DB.PUBLIC.MOVIE_TITLES
FROM @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER;

-- Create FILE FORMAT object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1
NULL_IF=('NULL','null')
EMPTY_FIELD_AS_NULL=TRUE
FIELD_OPTIONALLY_ENCLOSED_BY='"'    ;

SELECT * FROM OUR_FIRST_DB.PUBLIC.MOVIE_TITLES;

--============================================================
-- FILE: All resources/Section 8 - Loading from AWS/59 Handle JSON/Handling JSON.txt
--============================================================

-- Taming the json file

-- First query from s3 bucket

SELECT * FROM @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER;

-- Introduce columns
SELECT
    $1:ASIN,
    $1:HELPFUL,
    $1:OVERALL,
    $1:REVIEWTEXT,
    $1:REVIEWTIME,
    $1:REVIEWERID,
    $1:REVIEWTIME,
    $1:REVIEWERNAME,
    $1:SUMMARY,
    $1:UNIXREVIEWTIME
FROM
    @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER;

-- Format columns & use date function
SELECT
    $1:ASIN::STRING AS ASIN,
    $1:HELPFUL AS HELPFUL,
    $1:OVERALL AS OVERALL,
    $1:REVIEWTEXT::STRING AS REVIEWTEXT,
    $1:REVIEWTIME::STRING,
    $1:REVIEWERID::STRING,
    $1:REVIEWTIME::STRING,
    $1:REVIEWERNAME::STRING,
    $1:SUMMARY::STRING,
    DATE($1:UNIXREVIEWTIME::INT) AS REVIEWTIME
FROM
    @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER;

-- Format columns & handle custom date
SELECT
    $1:ASIN::STRING AS ASIN,
    $1:HELPFUL AS HELPFUL,
    $1:OVERALL AS OVERALL,
    $1:REVIEWTEXT::STRING AS REVIEWTEXT,
    DATE_FROM_PARTS( <YEAR>, <MONTH>, <DAY> ),
    $1:REVIEWTIME::STRING,
    $1:REVIEWERID::STRING,
    $1:REVIEWTIME::STRING,
    $1:REVIEWERNAME::STRING,
    $1:SUMMARY::STRING,
    DATE($1:UNIXREVIEWTIME::INT) AS REVIEWTIME
FROM
    @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER;

-- Use date_from_parts and see another difficulty
SELECT
    $1:ASIN::STRING AS ASIN,
    $1:HELPFUL AS HELPFUL,
    $1:OVERALL AS OVERALL,
    $1:REVIEWTEXT::STRING AS REVIEWTEXT,
    DATE_FROM_PARTS( RIGHT($1:REVIEWTIME::STRING,4), LEFT($1:REVIEWTIME::STRING,2), SUBSTRING($1:REVIEWTIME::STRING,4,2)),
    $1:REVIEWERID::STRING,
    $1:REVIEWTIME::STRING,
    $1:REVIEWERNAME::STRING,
    $1:SUMMARY::STRING,
    DATE($1:UNIXREVIEWTIME::INT) AS UNIX_REVIEWTIME
FROM
    @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER;

-- Use date_from_parts and handle the case difficulty
SELECT
    $1:ASIN::STRING AS ASIN,
    $1:HELPFUL AS HELPFUL,
    $1:OVERALL AS OVERALL,
    $1:REVIEWTEXT::STRING AS REVIEWTEXT,
    DATE_FROM_PARTS(
    RIGHT($1:REVIEWTIME::STRING,4),
    LEFT($1:REVIEWTIME::STRING,2),
    CASE WHEN SUBSTRING($1:REVIEWTIME::STRING,5,1)=','
    THEN SUBSTRING($1:REVIEWTIME::STRING,4,1) ELSE SUBSTRING($1:REVIEWTIME::STRING,4,2) END),
    $1:REVIEWERID::STRING,
    $1:REVIEWTIME::STRING,
    $1:REVIEWERNAME::STRING,
    $1:SUMMARY::STRING,
    DATE($1:UNIXREVIEWTIME::INT) AS UNIX_REVIEWTIME
FROM
    @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER;

-- Create destination table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.REVIEWS (
    ASIN STRING,
    HELPFUL STRING,
    OVERALL STRING,
    REVIEWTEXT STRING,
    REVIEWTIME DATE,
    REVIEWERID STRING,
    REVIEWERNAME STRING,
    SUMMARY STRING,
    UNIXREVIEWTIME DATE
);

-- Copy transformed data into destination table
COPY INTO OUR_FIRST_DB.PUBLIC.REVIEWS
FROM (
    SELECT
        $1:ASIN::STRING AS ASIN,
        $1:HELPFUL AS HELPFUL,
        $1:OVERALL AS OVERALL,
        $1:REVIEWTEXT::STRING AS REVIEWTEXT,
        DATE_FROM_PARTS(
        RIGHT($1:REVIEWTIME::STRING,4),
        LEFT($1:REVIEWTIME::STRING,2),
        CASE WHEN SUBSTRING($1:REVIEWTIME::STRING,5,1)=','
        THEN SUBSTRING($1:REVIEWTIME::STRING,4,1) ELSE SUBSTRING($1:REVIEWTIME::STRING,4,2) END),
        $1:REVIEWERID::STRING,
        $1:REVIEWERNAME::STRING,
        $1:SUMMARY::STRING,
        DATE($1:UNIXREVIEWTIME::INT) REVEWTIME
    FROM
        @MANAGE_DB.EXTERNAL_STAGES.JSON_FOLDER
);

-- Validate results
SELECT * FROM OUR_FIRST_DB.PUBLIC.REVIEWS    ;

--============================================================
-- FILE: All resources/Section 9 - Loading from Azure/63 Create integration object/Create Integration.txt
--============================================================

USE DATABASE DEMO_DB;

-- Create integration object that contains the access information
CREATE STORAGE INTEGRATION AZURE_INTEGRATION
TYPE=EXTERNAL_STAGE
STORAGE_PROVIDER=AZURE
ENABLED=TRUE
AZURE_TENANT_ID='9ecede0b-0e07-4da4-8047-e0672d6e403e'
STORAGE_ALLOWED_LOCATIONS=(
    'azure:--storageaccountsnow.blob.core.windows.net/snowflakecsv',
    'azure:--storageaccountsnow.blob.core.windows.net/snowflakejson'
);

-- Describe integration object to provide access
DESC INTEGRATION AZURE_INTEGRATION;

--============================================================
-- FILE: All resources/Section 9 - Loading from Azure/64 Create stage object/Create Stage.txt
--============================================================

-- create FILE FORMAT & stage objects --
-- Create FILE FORMAT
CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.FILEFORMAT_AZURE
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1;

-- Create stage object
CREATE OR REPLACE STAGE DEMO_DB.PUBLIC.STAGE_AZURE
STORAGE_INTEGRATION=AZURE_INTEGRATION
URL='azure:--storageaccountsnow.blob.core.windows.net/snowflakecsv'
FILE_FORMAT=FILEFORMAT_AZURE;

-- List files
LIST @DEMO_DB.PUBLIC.STAGE_AZURE;

--============================================================
-- FILE: All resources/Section 9 - Loading from Azure/65 Load CSV file/Load CSV.txt
--============================================================

-- query files & load data --
-- Query files
SELECT
    $1,
    $2,
    $3,
    $4,
    $5,
    $6,
    $7,
    $8,
    $9,
    $10,
    $11,
    $12,
    $13,
    $14,
    $15,
    $16,
    $17,
    $18,
    $19,
    $20
FROM
    @DEMO_DB.PUBLIC.STAGE_AZURE;

CREATE OR REPLACE TABLE HAPPINESS (
    COUNTRY_NAME VARCHAR,
    REGIONAL_INDICATOR VARCHAR,
    LADDER_SCORE NUMBER(4, 3),
    STANDARD_ERROR NUMBER(4, 3),
    UPPERWHISKER NUMBER(4, 3),
    LOWERWHISKER NUMBER(4, 3),
    LOGGED_GDP NUMBER(5, 3),
    SOCIAL_SUPPORT NUMBER(4, 3),
    HEALTHY_LIFE_EXPECTANCY NUMBER(5, 3),
    FREEDOM_TO_MAKE_LIFE_CHOICES NUMBER(4, 3),
    GENEROSITY NUMBER(4, 3),
    PERCEPTIONS_OF_CORRUPTION NUMBER(4, 3),
    LADDER_SCORE_IN_DYSTOPIA NUMBER(4, 3),
    EXPLAINED_BY_LOG_GPD_PER_CAPITA NUMBER(4, 3),
    EXPLAINED_BY_SOCIAL_SUPPORT NUMBER(4, 3),
    EXPLAINED_BY_HEALTHY_LIFE_EXPECTANCY NUMBER(4, 3),
    EXPLAINED_BY_FREEDOM_TO_MAKE_LIFE_CHOICES NUMBER(4, 3),
    EXPLAINED_BY_GENEROSITY NUMBER(4, 3),
    EXPLAINED_BY_PERCEPTIONS_OF_CORRUPTION NUMBER(4, 3),
    DYSTOPIA_RESIDUAL NUMBER(4, 3)
);

COPY INTO HAPPINESS
FROM @DEMO_DB.PUBLIC.STAGE_AZURE;

SELECT * FROM HAPPINESS;

--============================================================
-- FILE: All resources/Section 9 - Loading from Azure/66 Load JSON file/Load JSON.txt
--============================================================

-- load json --
CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.FILEFORMAT_AZURE_JSON
TYPE=JSON;


CREATE OR REPLACE STAGE DEMO_DB.PUBLIC.STAGE_AZURE
STORAGE_INTEGRATION=AZURE_INTEGRATION
URL='azure:--storageaccountsnow.blob.core.windows.net/snowflakejson'
FILE_FORMAT=FILEFORMAT_AZURE_JSON;

LIST  @DEMO_DB.PUBLIC.STAGE_AZURE;

-- Query from stage
SELECT * FROM @DEMO_DB.PUBLIC.STAGE_AZURE;

-- Query one attribute/column
SELECT $1:"Car Model" FROM @DEMO_DB.PUBLIC.STAGE_AZURE;

-- Convert data type
SELECT $1:"Car Model"::STRING FROM @DEMO_DB.PUBLIC.STAGE_AZURE;

-- Query all attributes
SELECT
    $1:"Car Model"::STRING,
    $1:"Car Model Year"::INT,
    $1:"car make"::STRING,
    $1:"first_name"::STRING,
    $1:"last_name"::STRING
FROM
    @DEMO_DB.PUBLIC.STAGE_AZURE;

-- Query all attributes and use aliases
SELECT
    $1:"Car Model"::STRING AS CAR_MODEL,
    $1:"Car Model Year"::INT AS CAR_MODEL_YEAR,
    $1:"car make"::STRING AS "car make",
    $1:"first_name"::STRING AS FIRST_NAME,
    $1:"last_name"::STRING AS LAST_NAME
FROM
    @DEMO_DB.PUBLIC.STAGE_AZURE;

CREATE OR REPLACE TABLE CAR_OWNER (
    CAR_MODEL VARCHAR,
    CAR_MODEL_YEAR INT,
    CAR_MAKE VARCHAR,
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR
);

COPY INTO CAR_OWNER
FROM (
    SELECT
        $1:"Car Model"::STRING AS CAR_MODEL,
        $1:"Car Model Year"::INT AS CAR_MODEL_YEAR,
        $1:"car make"::STRING AS "car make",
        $1:"first_name"::STRING AS FIRST_NAME,
        $1:"last_name"::STRING AS LAST_NAME
    FROM
        @DEMO_DB.PUBLIC.STAGE_AZURE
);

SELECT * FROM CAR_OWNER;

-- Alternative: using a raw file table step
TRUNCATE TABLE CAR_OWNER;

SELECT * FROM CAR_OWNER;

CREATE OR REPLACE TABLE CAR_OWNER_RAW (RAW VARIANT);

COPY INTO CAR_OWNER_RAW
FROM @DEMO_DB.PUBLIC.STAGE_AZURE;

SELECT * FROM CAR_OWNER_RAW;

INSERT INTO
    CAR_OWNER (
        SELECT
            $1:"Car Model"::STRING AS CAR_MODEL,
            $1:"Car Model Year"::INT AS CAR_MODEL_YEAR,
            $1:"car make"::STRING AS CAR_MAKE,
            $1:"first_name"::STRING AS FIRST_NAME,
            $1:"last_name"::STRING AS LAST_NAME
        FROM
            CAR_OWNER_RAW
    );

SELECT * FROM CAR_OWNER;

--============================================================
-- FILE: All resources/Section 10 - Loading from GCP/70 Create stage/Create integration object.txt
--============================================================

-- Create integration object that contains the access information
CREATE STORAGE INTEGRATION GCP_INTEGRATION
TYPE=EXTERNAL_STAGE
STORAGE_PROVIDER=GCS
ENABLED=TRUE
STORAGE_ALLOWED_LOCATIONS=('gcs:--bucket/path', 'gcs:--bucket/path2');

-- Describe integration object to provide access
DESC INTEGRATION GCP_INTEGRATION;

--============================================================
-- FILE: All resources/Section 10 - Loading from GCP/71 Query & load data/Query & Load data.txt
--============================================================

-- query files & load data --
-- Query files
SELECT
    $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,
    $12,$13,$14,$15,$16,$17,$18,$19,$20
FROM
    @DEMO_DB.PUBLIC.STAGE_GCP;

CREATE OR REPLACE TABLE HAPPINESS (
    COUNTRY_NAME VARCHAR,
    REGIONAL_INDICATOR VARCHAR,
    LADDER_SCORE NUMBER(4, 3),
    STANDARD_ERROR NUMBER(4, 3),
    UPPERWHISKER NUMBER(4, 3),
    LOWERWHISKER NUMBER(4, 3),
    LOGGED_GDP NUMBER(5, 3),
    SOCIAL_SUPPORT NUMBER(4, 3),
    HEALTHY_LIFE_EXPECTANCY NUMBER(5, 3),
    FREEDOM_TO_MAKE_LIFE_CHOICES NUMBER(4, 3),
    GENEROSITY NUMBER(4, 3),
    PERCEPTIONS_OF_CORRUPTION NUMBER(4, 3),
    LADDER_SCORE_IN_DYSTOPIA NUMBER(4, 3),
    EXPLAINED_BY_LOG_GPD_PER_CAPITA NUMBER(4, 3),
    EXPLAINED_BY_SOCIAL_SUPPORT NUMBER(4, 3),
    EXPLAINED_BY_HEALTHY_LIFE_EXPECTANCY NUMBER(4, 3),
    EXPLAINED_BY_FREEDOM_TO_MAKE_LIFE_CHOICES NUMBER(4, 3),
    EXPLAINED_BY_GENEROSITY NUMBER(4, 3),
    EXPLAINED_BY_PERCEPTIONS_OF_CORRUPTION NUMBER(4, 3),
    DYSTOPIA_RESIDUAL NUMBER(4, 3)
);

COPY INTO HAPPINESS
FROM @DEMO_DB.PUBLIC.STAGE_GCP;

SELECT * FROM HAPPINESS;

--============================================================
-- FILE: All resources/Section 10 - Loading from GCP/72 Unload data/Unload data.txt
--============================================================

-- unload data --
USE ROLE ACCOUNTADMIN;

USE DATABASE DEMO_DB;

-- Create integration object that contains the access information
CREATE STORAGE INTEGRATION GCP_INTEGRATION
TYPE=EXTERNAL_STAGE
STORAGE_PROVIDER=GCS
ENABLED=TRUE
STORAGE_ALLOWED_LOCATIONS=(
    'gcs:--snowflakebucketgcp',
    'gcs:--snowflakebucketgcpjson'
);

-- Create FILE FORMAT
CREATE OR REPLACE FILE FORMAT DEMO_DB.PUBLIC.FILEFORMAT_GCP
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1;

-- Create stage object
CREATE OR REPLACE STAGE DEMO_DB.PUBLIC.STAGE_GCP
STORAGE_INTEGRATION=GCP_INTEGRATION
URL='gcs:--snowflakebucketgcp/csv_happiness'
FILE_FORMAT=FILEFORMAT_GCP;

ALTER STORAGE INTEGRATION GCP_INTEGRATION
SET
    STORAGE_ALLOWED_LOCATIONS = (
        'gcs:--snowflakebucketgcp',
        'gcs:--snowflakebucketgcpjson'
    );

SELECT * FROM HAPPINESS;

COPY INTO @STAGE_GCP
FROM HAPPINESS;

--============================================================
-- FILE: All resources/Section 11 - Snowpipe/75 Creating stage/Create stage and pipe.txt
--============================================================

-- Create table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.EMPLOYEES (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    LOCATION STRING,
    DEPARTMENT STRING
);

-- Create FILE FORMAT object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1
NULL_IF=('NULL','null')
EMPTY_FIELD_AS_NULL=TRUE;

-- Create stage object with integration object & FILE FORMAT object
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER
URL='s3://snowflakes3bucket123/csv/snowpipe'
STORAGE_INTEGRATION=S3_INT
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT;

-- Create stage object with integration object & FILE FORMAT object
LIST @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER;

-- Create schema to keep things organized
CREATE OR REPLACE SCHEMA MANAGE_DB.PIPES;

-- Define pipe
CREATE OR REPLACE PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE
AUTO_INGEST=TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES
FROM @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER ;

-- Describe pipe
DESC PIPE EMPLOYEE_PIPE;

SELECT * FROM OUR_FIRST_DB.PUBLIC.EMPLOYEES    ;

--============================================================
-- FILE: All resources/Section 11 - Snowpipe/76 Creating pipe/Create pipe.txt
--============================================================

-- Define pipe
CREATE OR REPLACE PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE
AUTO_INGEST=TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES
FROM @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER;

-- Describe pipe
DESC PIPE EMPLOYEE_PIPE;

SELECT * FROM OUR_FIRST_DB.PUBLIC.EMPLOYEES;

--============================================================
-- FILE: All resources/Section 11 - Snowpipe/78 Error handling/Error handling.txt
--============================================================

-- Handling errors
-- Create FILE FORMAT object
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILEFORMAT
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1
NULL_IF=('NULL','null')
EMPTY_FIELD_AS_NULL=TRUE;

SELECT * FROM OUR_FIRST_DB.PUBLIC.EMPLOYEES   ;

ALTER PIPE EMPLOYEE_PIPE REFRESH;

-- Validate pipe is actually working
SELECT SYSTEM$PIPE_STATUS('employee_pipe');

-- Snowpipe error message
SELECT
    *
FROM
    TABLE (
        VALIDATE_PIPE_LOAD(
            PIPE_NAME => 'MANAGE_DB.pipes.employee_pipe',
            START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
        )
    );

-- Copy command history from table to see error massage
SELECT
    *
FROM
    TABLE (
        INFORMATION_SCHEMA.COPY_HISTORY (
            TABLE_NAME => 'OUR_FIRST_DB.PUBLIC.EMPLOYEES',
            START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
        )
    );

--============================================================
-- FILE: All resources/Section 11 - Snowpipe/79 Manage pipes/Manage pipes.txt
--============================================================

-- Manage pipes --
DESC PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE;

SHOW PIPES;

SHOW PIPES LIKE '%employee%';

SHOW PIPES IN DATABASE MANAGE_DB;

SHOW PIPES IN SCHEMA MANAGE_DB.PIPES;

SHOW PIPES LIKE '%employee%' IN DATABASE MANAGE_DB;

-- Changing pipe (alter stage or FILE FORMAT) --
-- Preparation table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.EMPLOYEES2 (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    LOCATION STRING,
    DEPARTMENT STRING
);

-- Pause pipe
ALTER PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE
SET
    PIPE_EXECUTION_PAUSED = TRUE;

-- Verify pipe is paused and has pendingfilecount 0
SELECT SYSTEM$PIPE_STATUS('MANAGE_DB.pipes.employee_pipe') ;

-- Recreate the pipe to change the copy statement in the definition
CREATE OR REPLACE PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE
AUTO_INGEST=TRUE
AS
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES2
FROM @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER;

ALTER PIPE  MANAGE_DB.PIPES.EMPLOYEE_PIPE REFRESH;

-- List files in stage
LIST @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER  ;

SELECT * FROM OUR_FIRST_DB.PUBLIC.EMPLOYEES2;

-- Reload files manually that were already in the bucket
COPY INTO OUR_FIRST_DB.PUBLIC.EMPLOYEES2
FROM @MANAGE_DB.EXTERNAL_STAGES.CSV_FOLDER;

-- Resume pipe
ALTER PIPE MANAGE_DB.PIPES.EMPLOYEE_PIPE
SET
    PIPE_EXECUTION_PAUSED = FALSE;

-- Verify pipe is running again
SELECT SYSTEM$PIPE_STATUS('MANAGE_DB.pipes.employee_pipe') ;

--============================================================
-- FILE: All resources/Section 12 - Time Travel/80 Using time travel/Using time travel.txt
--============================================================

-- Setting up table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILE
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1;

CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
URL='s3://data-snowflake-fundamentals/time-travel/'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILE;

LIST @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE;

COPY INTO OUR_FIRST_DB.PUBLIC.TEST
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

SELECT CURRENT_TIMESTAMP();

-- Use-case: update data (by mistake)
UPDATE OUR_FIRST_DB.PUBLIC.TEST
SET FIRST_NAME='Joyen';

-- Using time travel: method 1 - 2 minutes back
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST AT (
        OFFSET => -60 * 2
    );

-- Using time travel: method 2 - before timestamp
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST BEFORE (TIMESTAMP => '2026-06-29 22:09:30.610'::TIMESTAMP);

-- Setting up table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

COPY INTO OUR_FIRST_DB.PUBLIC.TEST
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

-- 2021-04-17 08:16:24.259
-- Setting up UTC time for convenience

ALTER SESSION SET TIMEZONE='UTC';

SELECT DATEADD(DAY, 1, CURRENT_TIMESTAMP);

UPDATE OUR_FIRST_DB.PUBLIC.TEST
SET JOB='Data Scientist';


SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST AT (TIMESTAMP => '2026-06-30 05:16:20.376 +0000'::TIMESTAMP);

-- -- -- Using time travel: method 3 - before query id

-- Preparing table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    PHONE STRING,
    JOB STRING
);

COPY INTO OUR_FIRST_DB.PUBLIC.TEST
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

SELECT CURRENT_TIMESTAMP();
-- 2026-06-30 05:16:20.376 +0000

-- Altering table (by mistake)
UPDATE OUR_FIRST_DB.PUBLIC.TEST
SET EMAIL=NULL;
-- 01c5637c-0109-a37c-002e-f967009e002a

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST BEFORE (
        STATEMENT => '01c5637c-0109-a37c-002e-f967009e002a'
    );

--============================================================
-- FILE: All resources/Section 12 - Time Travel/81 Restoring data/Restoring in time travel.txt
--============================================================

-- Setting up table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

COPY INTO OUR_FIRST_DB.PUBLIC.TEST
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

-- Use-case: update data (by mistake)
UPDATE OUR_FIRST_DB.PUBLIC.TEST
SET LAST_NAME='Tyson';
-- 01c5638b-0109-a713-002e-f967009dd066

UPDATE OUR_FIRST_DB.PUBLIC.TEST
SET JOB='Data Analyst';
-- 01c5638b-0109-a713-002e-f967009dd06a

SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST BEFORE (
        STATEMENT => '01c5638b-0109-a713-002e-f967009dd066'
    );

-- -- -- Bad method
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST AS
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST BEFORE (
        STATEMENT => '019b9eea-0500-845a-0043-4d830007402a'
    );

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST AS
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST BEFORE (
        STATEMENT => '019b9eea-0500-8473-0043-4d830007307a'
    );

-- -- -- Good method
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TEST_BACKUP AS
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST BEFORE (
        STATEMENT => '01c5638b-0109-a713-002e-f967009dd066'
    );

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.TEST;

INSERT INTO
    OUR_FIRST_DB.PUBLIC.TEST
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TEST_BACKUP;

SELECT * FROM OUR_FIRST_DB.PUBLIC.TEST;

--============================================================
-- FILE: All resources/Section 12 - Time Travel/82 UNDRPOP tables/Undrop tables.txt
--============================================================

-- Setting up table
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
URL='s3://data-snowflake-fundamentals/time-travel/'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILE;

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

COPY INTO OUR_FIRST_DB.PUBLIC.CUSTOMERS
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS;

-- Undrop command - tables
DROP TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS;

SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS;

UNDROP TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS;

-- Undrop command - schemas
DROP SCHEMA OUR_FIRST_DB.PUBLIC;

SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS;

UNDROP SCHEMA OUR_FIRST_DB.PUBLIC;

-- Undrop command - database
DROP DATABASE OUR_FIRST_DB;

SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS;

UNDROP DATABASE OUR_FIRST_DB;

-- Restore replaced table
UPDATE OUR_FIRST_DB.PUBLIC.CUSTOMERS
SET LAST_NAME='Tyson';

UPDATE OUR_FIRST_DB.PUBLIC.CUSTOMERS
SET JOB='Data Analyst';

-- -- -- undroping a table with a name that already exists
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS AS
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.CUSTOMERS BEFORE (
        STATEMENT => '019b9f7c-0500-851b-0043-4d83000762be'
    );

SELECT * FROM OUR_FIRST_DB.PUBLIC.CUSTOMERS;

UNDROP TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS;

ALTER TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS
RENAME TO OUR_FIRST_DB.PUBLIC.CUSTOMERS_WRONG;

DESC TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS;

--============================================================
-- FILE: All resources/Section 12 - Time Travel/84 Time travel cost/Time travel cost.txt
--============================================================

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE ORDER BY USAGE_DATE DESC;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

-- Query time travel storage
SELECT
    ID,
    TABLE_NAME,
    TABLE_SCHEMA,
    TABLE_CATALOG,
    ACTIVE_BYTES / (1024 * 1024 * 1024) AS STORAGE_USED_GB,
    TIME_TRAVEL_BYTES / (1024 * 1024 * 1024) AS TIME_TRAVEL_STORAGE_USED_GB
FROM
    SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY
    STORAGE_USED_GB DESC,
    TIME_TRAVEL_STORAGE_USED_GB DESC;

--============================================================
-- FILE: All resources/Section 13 - Fail Safe/86 Fail Safe storage/Fail Safe Storage.txt
--============================================================

-- Storage usage on account level
SELECT
    *
FROM
    SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
ORDER BY
    USAGE_DATE DESC;

-- Storage usage on account level formatted
SELECT
    USAGE_DATE,
    STORAGE_BYTES / (1024 * 1024 * 1024) AS STORAGE_GB,
    STAGE_BYTES / (1024 * 1024 * 1024) AS STAGE_GB,
    FAILSAFE_BYTES / (1024 * 1024 * 1024) AS FAILSAFE_GB
FROM
    SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
ORDER BY
    USAGE_DATE DESC;

-- Storage usage on table level
SELECT
    *
FROM
    SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

-- Storage usage on table level formatted
SELECT
    ID,
    TABLE_NAME,
    TABLE_SCHEMA,
    ACTIVE_BYTES / (1024 * 1024 * 1024) AS STORAGE_USED_GB,
    TIME_TRAVEL_BYTES / (1024 * 1024 * 1024) AS TIME_TRAVEL_STORAGE_USED_GB,
    FAILSAFE_BYTES / (1024 * 1024 * 1024) AS FAILSAFE_STORAGE_USED_GB
FROM
    SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY
    FAILSAFE_STORAGE_USED_GB DESC;

--============================================================
-- FILE: All resources/Section 14 - Types of tables/88 Permanent tables & databases/Permanent tables.txt
--============================================================

CREATE OR REPLACE DATABASE PDB;

CREATE OR REPLACE TABLE PDB.PUBLIC.CUSTOMERS (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

CREATE OR REPLACE TABLE PDB.PUBLIC.HELPER (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

-- Stage and FILE FORMAT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILE
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1;

CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
URL='s3://data-snowflake-fundamentals/time-travel/'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILE;

LIST  @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE;

-- Copy data and insert in table
COPY INTO PDB.PUBLIC.HELPER
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM PDB.PUBLIC.HELPER;

INSERT INTO
    PDB.PUBLIC.CUSTOMERS
SELECT
    T1.ID,
    T1.FIRST_NAME,
    T1.LAST_NAME,
    T1.EMAIL,
    T1.GENDER,
    T1.JOB,
    T1.PHONE
FROM
    PDB.PUBLIC.HELPER T1
    CROSS JOIN (
        SELECT
            *
        FROM
            PDB.PUBLIC.HELPER
    ) T2
    CROSS JOIN (
        SELECT
            TOP 100 *
        FROM
            PDB.PUBLIC.HELPER
    ) T3;


-- Show table and validate
SHOW TABLES;

-- Permanent tables
USE DATABASE OUR_FIRST_DB;

CREATE OR REPLACE TABLE CUSTOMERS (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

CREATE OR REPLACE DATABASE PDB;

SHOW DATABASES;

SHOW TABLES;

-- View table metrics (takes a bit to appear)
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

SELECT
    ID,
    TABLE_NAME,
    TABLE_SCHEMA,
    TABLE_CATALOG,
    ACTIVE_BYTES / (1024 * 1024 * 1024) AS ACTIVE_STORAGE_USED_GB,
    TIME_TRAVEL_BYTES / (1024 * 1024 * 1024) AS TIME_TRAVEL_STORAGE_USED_GB,
    FAILSAFE_BYTES / (1024 * 1024 * 1024) AS FAILSAFE_STORAGE_USED_GB,
    IS_TRANSIENT,
    DELETED,
    TABLE_CREATED,
    TABLE_DROPPED,
    TABLE_ENTERED_FAILSAFE
FROM
    SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
    -- Where table_catalog='pdb'
WHERE
    TABLE_DROPPED IS NOT NULL
ORDER BY
    FAILSAFE_BYTES DESC;

--============================================================
-- FILE: All resources/Section 14 - Types of tables/89 Transient tables & databases/Transient tables.txt
--============================================================

CREATE OR REPLACE DATABASE TDB;

CREATE
OR REPLACE TRANSIENT TABLE TDB.PUBLIC.CUSTOMERS_TRANSIENT (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

INSERT INTO
    TDB.PUBLIC.CUSTOMERS_TRANSIENT
SELECT
    T1.*
FROM
    OUR_FIRST_DB.PUBLIC.CUSTOMERS T1
    CROSS JOIN (
        SELECT
            *
        FROM
            OUR_FIRST_DB.PUBLIC.CUSTOMERS
    ) T2;

SHOW TABLES;

-- Query storage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

SELECT
    ID,
    TABLE_NAME,
    TABLE_SCHEMA,
    TABLE_CATALOG,
    ACTIVE_BYTES,
    TIME_TRAVEL_BYTES / (1024 * 1024 * 1024) AS TIME_TRAVEL_STORAGE_USED_GB,
    FAILSAFE_BYTES / (1024 * 1024 * 1024) AS FAILSAFE_STORAGE_USED_GB,
    IS_TRANSIENT,
    DELETED,
    TABLE_CREATED,
    TABLE_DROPPED,
    TABLE_ENTERED_FAILSAFE
FROM
    SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE
    TABLE_CATALOG = 'TDB'
ORDER BY
    TABLE_CREATED DESC;

-- Set retention time to 0
ALTER TABLE TDB.PUBLIC.CUSTOMERS_TRANSIENT
SET
    DATA_RETENTION_TIME_IN_DAYS = 0;

DROP TABLE TDB.PUBLIC.CUSTOMERS_TRANSIENT;

UNDROP TABLE TDB.PUBLIC.CUSTOMERS_TRANSIENT;

SHOW TABLES;

-- Creating transient schema and then table
CREATE OR REPLACE TRANSIENT SCHEMA TRANSIENT_SCHEMA;

SHOW SCHEMAS;

CREATE OR REPLACE TABLE TDB.TRANSIENT_SCHEMA.NEW_TABLE (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

ALTER TABLE TDB.TRANSIENT_SCHEMA.NEW_TABLE
SET
    DATA_RETENTION_TIME_IN_DAYS = 2;

SHOW TABLES;

--============================================================
-- FILE: All resources/Section 14 - Types of tables/90 Temporary tables & databases/Temporary tables.txt
--============================================================

USE DATABASE PDB;

-- Create permanent table
CREATE OR REPLACE TABLE PDB.PUBLIC.CUSTOMERS (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

INSERT INTO
    PDB.PUBLIC.CUSTOMERS
SELECT
    T1.*
FROM
    OUR_FIRST_DB.PUBLIC.CUSTOMERS T1;

SELECT * FROM PDB.PUBLIC.CUSTOMERS;

-- Create temporary table (with the same name)
CREATE OR REPLACE TEMPORARY TABLE PDB.PUBLIC.CUSTOMERS (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

-- Validate temporary table is the active table
SELECT * FROM PDB.PUBLIC.CUSTOMERS;

-- Create second temporary table (with a new name)
CREATE OR REPLACE TEMPORARY TABLE PDB.PUBLIC.TEMP_TABLE (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

-- Insert data in the new table
INSERT INTO
    PDB.PUBLIC.TEMP_TABLE
SELECT
    *
FROM
    PDB.PUBLIC.CUSTOMERS;

SELECT
    *
FROM
    PDB.PUBLIC.TEMP_TABLE;

SHOW TABLES;

--============================================================
-- FILE: All resources/Section 15 - Zero-Copy Cloning/92 Cloning tables/Cloning Schemas & Databases.txt
--============================================================

-- Cloning schema
CREATE TRANSIENT SCHEMA OUR_FIRST_DB.COPIED_SCHEMA CLONE OUR_FIRST_DB.PUBLIC;

SELECT * FROM COPIED_SCHEMA.CUSTOMERS;

CREATE TRANSIENT SCHEMA OUR_FIRST_DB.EXTERNAL_STAGES_COPIED CLONE MANAGE_DB.EXTERNAL_STAGES;

-- Cloning database
CREATE TRANSIENT DATABASE OUR_FIRST_DB_COPY CLONE OUR_FIRST_DB;

DROP DATABASE OUR_FIRST_DB_COPY;

DROP SCHEMA OUR_FIRST_DB.EXTERNAL_STAGES_COPIED;

DROP SCHEMA OUR_FIRST_DB.COPIED_SCHEMA;

--============================================================
-- FILE: All resources/Section 15 - Zero-Copy Cloning/94 Cloning with time travel/Cloning using time travel.txt
--============================================================

-- Cloning using time travel
-- Setting up table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILE
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1;

CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
URL='s3://data-snowflake-fundamentals/time-travel/'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILE;

LIST @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE;

COPY INTO OUR_FIRST_DB.PUBLIC.TIME_TRAVEL
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.TIME_TRAVEL;

-- Update data
UPDATE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL
SET FIRST_NAME='Frank';
-- 01c563ae-0109-a713-002e-f967009dd10a

-- Using time travel
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TIME_TRAVEL AT (
        OFFSET => -60 * 2
    )

-- Using time travel
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE
CLONE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL AT (OFFSET => -60*2);

SELECT * FROM OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE;

-- Update data again
UPDATE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE
SET JOB='Snowflake Analyst';


-- Using time travel: method 2 - before query
SELECT
    *
FROM
    OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE BEFORE (
        STATEMENT => '01c563ae-0109-a713-002e-f967009dd10a'
    );

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE_OF_CLONE
CLONE OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE BEFORE (STATEMENT => '01c563ae-0109-a713-002e-f967009dd10a');

SELECT * FROM OUR_FIRST_DB.PUBLIC.TIME_TRAVEL_CLONE_OF_CLONE;

--============================================================
-- FILE: All resources/Section 16 - Data Sharing/97 Using data sharing/Using data sharing.txt
--============================================================

CREATE OR REPLACE DATABASE DATA_S;

CREATE OR REPLACE STAGE AWS_STAGE
URL='s3://bucketsnowflakes3';

-- List files in stage
LIST @AWS_STAGE;

-- Create table
CREATE OR REPLACE TABLE ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT NUMBER(38, 0),
    PROFIT NUMBER(38, 0),
    QUANTITY NUMBER(38, 0),
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);

-- Load data using copy command
COPY INTO ORDERS
FROM @MANAGE_DB.EXTERNAL_STAGES.AWS_STAGE
FILE_FORMAT=(
    TYPE=CSV
    FIELD_DELIMITER=','
    SKIP_HEADER=1
)
PATTERN='.*OrderDetails.*';

SELECT * FROM ORDERS;

-- Create a share object
CREATE OR REPLACE SHARE ORDERS_SHARE;

-- setup grants --
-- Grant usage on database
GRANT USAGE ON DATABASE DATA_S TO SHARE ORDERS_SHARE;

-- Grant usage on schema
GRANT USAGE ON SCHEMA DATA_S.PUBLIC TO SHARE ORDERS_SHARE;

-- Grant select on table
GRANT SELECT ON TABLE DATA_S.PUBLIC.ORDERS TO SHARE ORDERS_SHARE;

-- Validate grants
SHOW GRANTS TO SHARE ORDERS_SHARE;

-- add consumer account --
ALTER SHARE ORDERS_SHARE
ADD ACCOUNT = <CONSUMER_ACCOUNT_ID>;

--============================================================
-- FILE: All resources/Section 16 - Data Sharing/100 Creating a reader account/Create reader account.txt
--============================================================

-- Create reader account --
CREATE MANAGED ACCOUNT TECH_JOY_ACCOUNT
ADMIN_NAME=TECH_JOY_ADMIN,
ADMIN_PASSWORD='set-pwd',
TYPE=READER;

-- Make sure to have selected the role of accountadmin
-- Show accounts
SHOW MANAGED ACCOUNTS;

-- Share the data --
ALTER SHARE ORDERS_SHARE
ADD ACCOUNT=<READER_ACCOUNT_ID>;

ALTER SHARE ORDERS_SHARE
ADD ACCOUNT=<READER_ACCOUNT_ID>
SHARE_RESTRICTIONS=FALSE;

-- Create database from share --
-- Show all shares (consumer & producers)
SHOW SHARES;

-- See details on share
DESC SHARE QNA46172.ORDERS_SHARE;

-- Create a database in consumer account using the share
CREATE DATABASE DATA_SHARE_DB
FROM
    SHARE <ACCOUNT_NAME_PRODUCER>.ORDERS_SHARE;

-- Validate table access
SELECT * FROM  DATA_SHARE_DB.PUBLIC.ORDERS;

-- Setup virtual warehouse
CREATE WAREHOUSE READ_WH WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND=180
AUTO_RESUME=TRUE
INITIALLY_SUSPENDED=TRUE;

-- Create and set up users --
-- Create user
CREATE USER MYRIAM PASSWORD='difficult_passw@ord=123';

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE READ_WH TO ROLE PUBLIC;

-- Granting privileges on a shared database for other users
GRANT IMPORTED PRIVILEGES ON DATABASE DATA_SHARE_DB TO ROLE PUBLIC;

--============================================================
-- FILE: All resources/Section 16 - Data Sharing/104 Secure vs. normal view/Secure view.txt
--============================================================

-- Create database & table --
CREATE OR REPLACE DATABASE CUSTOMER_DB;

CREATE OR REPLACE TABLE CUSTOMER_DB.PUBLIC.CUSTOMERS (
    ID INT,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
);

-- Stage and FILE FORMAT
CREATE OR REPLACE FILE FORMAT MANAGE_DB.FILE_FORMATS.CSV_FILE
TYPE=CSV
FIELD_DELIMITER=','
SKIP_HEADER=1;

CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
URL='s3://data-snowflake-fundamentals/time-travel/'
FILE_FORMAT=MANAGE_DB.FILE_FORMATS.CSV_FILE;

LIST  @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE;

-- Copy data and insert in table
COPY INTO CUSTOMER_DB.PUBLIC.CUSTOMERS
FROM @MANAGE_DB.EXTERNAL_STAGES.TIME_TRAVEL_STAGE
FILES=('customers.csv');

SELECT * FROM  CUSTOMER_DB.PUBLIC.CUSTOMERS;

-- Create view --
CREATE OR REPLACE VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW AS
SELECT
    FIRST_NAME,
    LAST_NAME,
    EMAIL
FROM
    CUSTOMER_DB.PUBLIC.CUSTOMERS
WHERE
    JOB != 'DATA SCIENTIST';

-- Grant usage & select --
GRANT USAGE ON DATABASE CUSTOMER_DB TO ROLE PUBLIC;

GRANT USAGE ON SCHEMA CUSTOMER_DB.PUBLIC TO ROLE PUBLIC;

GRANT SELECT ON TABLE CUSTOMER_DB.PUBLIC.CUSTOMERS TO ROLE PUBLIC;

GRANT SELECT ON VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW TO ROLE PUBLIC;

SHOW VIEWS LIKE '%CUSTOMER%';

-- Create secure view --
CREATE OR REPLACE SECURE VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW_SECURE AS
SELECT
    FIRST_NAME,
    LAST_NAME,
    EMAIL
FROM
    CUSTOMER_DB.PUBLIC.CUSTOMERS
WHERE
    JOB != 'DATA SCIENTIST';

GRANT SELECT ON VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW_SECURE TO ROLE PUBLIC;

SHOW VIEWS LIKE '%CUSTOMER%';

--============================================================
-- FILE: All resources/Section 16 - Data Sharing/105 Sharing a secure view/Sharing views.txt
--============================================================

SHOW SHARES;

-- Create share object
CREATE OR REPLACE SHARE VIEW_SHARE;

-- Grant usage on dabase & schema
GRANT USAGE ON DATABASE CUSTOMER_DB TO SHARE VIEW_SHARE;

GRANT USAGE ON SCHEMA CUSTOMER_DB.PUBLIC TO SHARE VIEW_SHARE;

-- Grant select on view
GRANT SELECT ON VIEW  CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW TO SHARE VIEW_SHARE;

GRANT SELECT ON VIEW  CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW_SECURE TO SHARE VIEW_SHARE;

-- Add account to share
ALTER SHARE VIEW_SHARE
ADD ACCOUNT=KAA74702;

--============================================================
-- FILE: All resources/Section 17 - Data Sampling/108 Sampling data (Hands-on)/Data Sampling.txt
--============================================================

CREATE OR REPLACE TRANSIENT DATABASE SAMPLING_DB;

CREATE OR REPLACE VIEW ADDRESS_SAMPLE AS
SELECT
    *
FROM
    SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS SAMPLE ROW (1) SEED (27);

SELECT * FROM ADDRESS_SAMPLE;

SELECT
    CA_LOCATION_TYPE,
    (COUNT(*) / 3254250) * 100
FROM
    ADDRESS_SAMPLE
GROUP BY
    CA_LOCATION_TYPE;

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE SYSTEM (1) SEED(23);

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE SYSTEM (10) SEED(23);

--============================================================
-- FILE: All resources/Section 18 - Scheduling Tasks/110 Creating tasks/Creating Tasks.txt
--============================================================

CREATE OR REPLACE TRANSIENT DATABASE TASK_DB;

-- Prepare table
CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID INT AUTOINCREMENT START = 1 INCREMENT = 1,
    FIRST_NAME VARCHAR(40) DEFAULT 'JENNIFER',
    CREATE_DATE DATE
);

-- Create task
CREATE OR REPLACE TASK CUSTOMER_INSERT
WAREHOUSE=BEETLE03_WH
SCHEDULE='1 MINUTE'
AS
INSERT INTO
    CUSTOMERS (CREATE_DATE)
VALUES
    (CURRENT_TIMESTAMP);

SHOW TASKS;

-- Task starting and suspending
ALTER TASK CUSTOMER_INSERT RESUME;

ALTER TASK CUSTOMER_INSERT SUSPEND;

SELECT * FROM CUSTOMERS;

--============================================================
-- FILE: All resources/Section 18 - Scheduling Tasks/111 Using CRON/Using CRON.txt
--============================================================

CREATE OR REPLACE TASK CUSTOMER_INSERT
WAREHOUSE=BEETLE03_WH
SCHEDULE='60 MINUTE'
AS
INSERT INTO
    CUSTOMERS (CREATE_DATE)
VALUES
    (CURRENT_TIMESTAMP);


CREATE OR REPLACE TASK CUSTOMER_INSERT
WAREHOUSE=COMPUTE_WH
SCHEDULE='USING CRON 0 7,10 * * 5L UTC'
AS
INSERT INTO
    CUSTOMERS (CREATE_DATE)
VALUES
    (CURRENT_TIMESTAMP);

-- __________ minute (0-59)
-- | ________ hour (0-23)
-- | | ______ day of month (1-31, or L)
-- | | | ____ month (1-12, JAN-DEC)
-- | | | | __ day of week (0-6, SUN-SAT, or L)
-- | | | | |
-- | | | | |
-- * * * * *
-- Examples
-- Every minute
-- SCHEDULE='USING CRON * * * * * UTC';
-- Every day at 6am UTC timezone
-- SCHEDULE='USING CRON 0 6 * * * UTC';
-- Every hour starting at 9 AM and ending at 5 PM on Sundays
-- SCHEDULE='USING CRON 0 9-17 * * SUN AMERICA/LOS_ANGELES';
CREATE OR REPLACE TASK CUSTOMER_INSERT
WAREHOUSE=BEETLE03_WH
SCHEDULE='USING CRON 0 9,17 * * * UTC'
AS
INSERT INTO
    CUSTOMERS (CREATE_DATE)
VALUES
    (CURRENT_TIMESTAMP);


--============================================================
-- FILE: All resources/Section 18 - Scheduling Tasks/113 Creating trees of tasks/Creating tree of tasks.txt
--============================================================

USE DATABASE TASK_DB;

SHOW TASKS;

SELECT * FROM CUSTOMERS;

-- Prepare a second table
CREATE OR REPLACE TABLE CUSTOMERS2 (
    CUSTOMER_ID INT,
    FIRST_NAME VARCHAR(40),
    CREATE_DATE DATE
);

-- Suspend parent task
ALTER TASK CUSTOMER_INSERT SUSPEND;

-- Create a child task
CREATE OR REPLACE TASK CUSTOMER_INSERT2
WAREHOUSE=COMPUTE_WH
AFTER CUSTOMER_INSERT
AS
INSERT INTO
    CUSTOMERS2
SELECT
    *
FROM
    CUSTOMERS;


-- Prepare a third table
CREATE OR REPLACE TABLE CUSTOMERS3 (
    CUSTOMER_ID INT,
    FIRST_NAME VARCHAR(40),
    CREATE_DATE DATE,
    INSERT_DATE DATE DEFAULT DATE(CURRENT_TIMESTAMP)
) ;


-- Create a child task
CREATE OR REPLACE TASK CUSTOMER_INSERT3
WAREHOUSE=COMPUTE_WH
AFTER CUSTOMER_INSERT2
AS
INSERT INTO
    CUSTOMERS3 (CUSTOMER_ID, FIRST_NAME, CREATE_DATE)
SELECT
    *
FROM
    CUSTOMERS2;

SHOW TASKS;

ALTER TASK CUSTOMER_INSERT
SET
    SCHEDULE = '1 MINUTE';

-- Resume tasks (first root task)
ALTER TASK CUSTOMER_INSERT RESUME;

ALTER TASK CUSTOMER_INSERT2 RESUME;

ALTER TASK CUSTOMER_INSERT3 RESUME;

SELECT * FROM CUSTOMERS2;

SELECT * FROM CUSTOMERS3;

-- Suspend tasks again
ALTER TASK CUSTOMER_INSERT SUSPEND;

ALTER TASK CUSTOMER_INSERT2 SUSPEND;

ALTER TASK CUSTOMER_INSERT3 SUSPEND;

--============================================================
-- FILE: All resources/Section 18 - Scheduling Tasks/114 Calling a stored procedure/Task with stored procedure.txt
--============================================================

-- Create a stored procedure
USE DATABASE TASK_DB;

SELECT * FROM CUSTOMERS;

CREATE OR REPLACE PROCEDURE CUSTOMERS_INSERT_PROCEDURE (CREATE_DATE VARCHAR)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    var sqlText='INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(:1);'
    snowflake.execute({sqlText, binds: [CREATE_DATE]});
    return "Successfully executed.";
$$;

CREATE OR REPLACE TASK CUSTOMER_TASK_PROCEDURE
WAREHOUSE=BEETLE03_WH
SCHEDULE='1 MINUTE'
AS CALL CUSTOMERS_INSERT_PROCEDURE (CURRENT_TIMESTAMP);

SHOW TASKS;

ALTER TASK CUSTOMER_TASK_PROCEDURE RESUME;

SELECT * FROM CUSTOMERS;

--============================================================
-- FILE: All resources/Section 18 - Scheduling Tasks/115 Task history & error handling/Task history.txt
--============================================================

SHOW TASKS;

USE DATABASE DEMO_DB;

-- Use the table function "task_history()"
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY SCHEDULED_TIME DESC;

-- See results for a specific task in a given time
SELECT
    *
FROM
    TABLE (
        INFORMATION_SCHEMA.TASK_HISTORY (
            SCHEDULED_TIME_RANGE_START => DATEADD('hour', -4, CURRENT_TIMESTAMP()),
            RESULT_LIMIT => 5,
            TASK_NAME => 'CUSTOMER_INSERT2'
        )
    );

-- See results for a given time period
SELECT
    *
FROM
    TABLE (
        INFORMATION_SCHEMA.TASK_HISTORY (
            SCHEDULED_TIME_RANGE_START => TO_TIMESTAMP_LTZ('2021-04-22 11:28:32.776 -0700'),
            SCHEDULED_TIME_RANGE_END => TO_TIMESTAMP_LTZ('2021-04-22 11:35:32.776 -0700')
        )
    );

SELECT
    TO_TIMESTAMP_LTZ(CURRENT_TIMESTAMP);

--============================================================
-- FILE: All resources/Section 19 - Streams/118 INSERT operation/Insert.txt
--============================================================

-- stream example: insert --
CREATE OR REPLACE TRANSIENT DATABASE STREAMS_DB;

-- Create example table
CREATE OR REPLACE TABLE SALES_RAW_STAGING (
    ID VARCHAR,
    PRODUCT VARCHAR,
    PRICE VARCHAR,
    AMOUNT VARCHAR,
    STORE_ID VARCHAR
);

-- Insert values
INSERT INTO
    SALES_RAW_STAGING
VALUES
    (1, 'Banana', 1.99, 1, 1),
    (2, 'Lemon', 0.99, 1, 1),
    (3, 'Apple', 1.79, 1, 2),
    (4, 'Orange Juice', 1.89, 1, 2),
    (5, 'Cereals', 5.98, 2, 1);

CREATE OR REPLACE TABLE STORE_TABLE (
    STORE_ID NUMBER,
    LOCATION VARCHAR,
    EMPLOYEES NUMBER
);

INSERT INTO
    STORE_TABLE
VALUES
    (1, 'Chicago', 33);

INSERT INTO
    STORE_TABLE
VALUES
    (2, 'London', 12);

CREATE OR REPLACE TABLE SALES_FINAL_TABLE (
    ID INT,
    PRODUCT VARCHAR,
    PRICE NUMBER,
    AMOUNT INT,
    STORE_ID INT,
    LOCATION VARCHAR,
    EMPLOYEES INT
);

-- Insert into final table
INSERT INTO
    SALES_FINAL_TABLE
SELECT
    SA.ID,
    SA.PRODUCT,
    SA.PRICE,
    SA.AMOUNT,
    ST.STORE_ID,
    ST.LOCATION,
    ST.EMPLOYEES
FROM
    SALES_RAW_STAGING SA
    JOIN STORE_TABLE ST ON ST.STORE_ID = SA.STORE_ID;

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM STORE_TABLE;

SELECT * FROM SALES_FINAL_TABLE;

-- Create a stream object
CREATE
OR REPLACE STREAM SALES_STREAM ON TABLE SALES_RAW_STAGING;

SHOW STREAMS;

DESC STREAM SALES_STREAM;

-- Get changes on data using stream (inserts)
SELECT * FROM SALES_STREAM;

SELECT * FROM SALES_RAW_STAGING;

-- Insert values
INSERT INTO
    SALES_RAW_STAGING
VALUES
    (6, 'Mango', 1.99, 1, 2),
    (7, 'Garlic', 0.99, 1, 1);

-- Get changes on data using stream (inserts)
SELECT * FROM SALES_STREAM;

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_FINAL_TABLE;

-- Consume stream object
INSERT INTO
    SALES_FINAL_TABLE
SELECT
    SA.ID,
    SA.PRODUCT,
    SA.PRICE,
    SA.AMOUNT,
    ST.STORE_ID,
    ST.LOCATION,
    ST.EMPLOYEES
FROM
    SALES_STREAM SA
    JOIN STORE_TABLE ST ON ST.STORE_ID = SA.STORE_ID;

-- Get changes on data using stream (inserts)
SELECT * FROM SALES_STREAM;

-- Insert values
INSERT INTO SALES_RAW_STAGING
VALUES
    (8,'Paprika',4.99,1,2),
    (9,'Tomato',3.99,1,2);

-- Consume stream object
INSERT INTO
    SALES_FINAL_TABLE
SELECT
    SA.ID,
    SA.PRODUCT,
    SA.PRICE,
    SA.AMOUNT,
    ST.STORE_ID,
    ST.LOCATION,
    ST.EMPLOYEES
FROM
    SALES_STREAM SA
    JOIN STORE_TABLE ST ON ST.STORE_ID = SA.STORE_ID;

SELECT * FROM SALES_FINAL_TABLE;

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

--============================================================
-- FILE: All resources/Section 19 - Streams/119 UPDATE operation/Update.txt
--============================================================

-- ******* UPDATE 1 ********
SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

UPDATE SALES_RAW_STAGING
SET
    PRODUCT = 'Potato'
WHERE
    PRODUCT = 'Banana';

MERGE INTO SALES_FINAL_TABLE F      -- Target table to merge changes from source table
    USING SALES_STREAM S                -- Stream that has captured the changes
    ON  F.ID=S.ID
    WHEN MATCHED
        AND S.METADATA$ACTION='INSERT'
        AND S.METADATA$ISUPDATE='TRUE'        -- Indicates the record has been updated
        THEN UPDATE
        SET F.PRODUCT=S.PRODUCT,
        F.PRICE=S.PRICE,
        F.AMOUNT=S.AMOUNT,
        F.STORE_ID=S.STORE_ID;

SELECT * FROM SALES_FINAL_TABLE;

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

-- ******* UPDATE 2 ********
UPDATE SALES_RAW_STAGING
SET
    PRODUCT = 'Green apple'
WHERE
    PRODUCT = 'Apple';

MERGE INTO SALES_FINAL_TABLE F      -- Target table to merge changes from source table
    USING SALES_STREAM S                -- Stream that has captured the changes
    ON  F.ID=S.ID
    WHEN MATCHED
        AND S.METADATA$ACTION='INSERT'
        AND S.METADATA$ISUPDATE='TRUE'        -- Indicates the record has been updated
        THEN UPDATE
        SET F.PRODUCT=S.PRODUCT,
        F.PRICE=S.PRICE,
        F.AMOUNT=S.AMOUNT,
        F.STORE_ID=S.STORE_ID;

SELECT * FROM SALES_FINAL_TABLE;

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

--============================================================
-- FILE: All resources/Section 19 - Streams/120 DELETE operation/Delete.txt
--============================================================

-- ******* DELETE  ********
SELECT * FROM SALES_FINAL_TABLE;

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

DELETE FROM SALES_RAW_STAGING
WHERE
    PRODUCT = 'Lemon';

-- ******* PROCESS STREAM  ********
MERGE INTO SALES_FINAL_TABLE F      -- Target table to merge changes from source table
    USING SALES_STREAM S                -- Stream that has captured the changes
    ON  F.ID=S.ID
    WHEN MATCHED
        AND S.METADATA$ACTION='DELETE'
        AND S.METADATA$ISUPDATE='FALSE'
        THEN DELETE;

--============================================================
-- FILE: All resources/Section 19 - Streams/121 Process all data changes/Process all data changes.txt
--============================================================

-- ******* process update,insert & delete simultaneously  ********
MERGE INTO SALES_FINAL_TABLE F      -- Target table to merge changes from source table
    USING (
        SELECT
            STRE.*,
            ST.LOCATION,
            ST.EMPLOYEES
        FROM
        SALES_STREAM STRE
        JOIN STORE_TABLE ST ON STRE.STORE_ID = ST.STORE_ID
    ) S
    ON F.ID=S.ID
    WHEN MATCHED                        -- DELETE condition
        AND S.METADATA$ACTION='DELETE'
        AND S.METADATA$ISUPDATE='FALSE'
        THEN DELETE
    WHEN MATCHED                        -- UPDATE condition
        AND S.METADATA$ACTION='INSERT'
        AND S.METADATA$ISUPDATE='TRUE'
        THEN UPDATE
        SET F.PRODUCT=S.PRODUCT,
        F.PRICE=S.PRICE,
        F.AMOUNT=S.AMOUNT,
        F.STORE_ID=S.STORE_ID
    WHEN NOT MATCHED
        AND S.METADATA$ACTION='INSERT'
        THEN INSERT
        (ID,PRODUCT,PRICE,STORE_ID,AMOUNT,EMPLOYEES,LOCATION)
        VALUES
        (S.ID, S.PRODUCT,S.PRICE,S.STORE_ID,S.AMOUNT,S.EMPLOYEES,S.LOCATION);

SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

SELECT * FROM SALES_FINAL_TABLE;

INSERT INTO
    SALES_RAW_STAGING
VALUES
    (2, 'Lemon', 0.99, 1, 1);

UPDATE SALES_RAW_STAGING
SET
    PRODUCT = 'Lemonade'
WHERE
    PRODUCT = 'Lemon';

DELETE FROM SALES_RAW_STAGING
WHERE
    PRODUCT = 'Lemonade';

-- example 2 --
INSERT INTO
    SALES_RAW_STAGING
VALUES
    (10, 'Lemon Juice', 2.99, 1, 1);

UPDATE SALES_RAW_STAGING
SET
    PRICE = 3
WHERE
    PRODUCT = 'Mango';

DELETE FROM SALES_RAW_STAGING
WHERE
    PRODUCT = 'Potato';

--============================================================
-- FILE: All resources/Section 19 - Streams/122 Combine streams & tasks/Streams & tasks.txt
--============================================================

-- Automate the updates using tasks --
CREATE OR REPLACE TASK ALL_DATA_CHANGES
WAREHOUSE=COMPUTE_WH
SCHEDULE='1 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('SALES_STREAM')
AS
MERGE INTO SALES_FINAL_TABLE F      -- Target table to merge changes from source table
USING ( SELECT STRE.*,ST.LOCATION,ST.EMPLOYEES
FROM SALES_STREAM STRE
JOIN STORE_TABLE ST
ON STRE.STORE_ID=ST.STORE_ID
) S
ON F.ID=S.ID
WHEN MATCHED                        -- DELETE condition
AND S.METADATA$ACTION='DELETE'
AND S.METADATA$ISUPDATE='FALSE'
THEN DELETE
WHEN MATCHED                        -- UPDATE condition
AND S.METADATA$ACTION='INSERT'
AND S.METADATA$ISUPDATE='TRUE'
THEN UPDATE
SET F.PRODUCT=S.PRODUCT,
F.PRICE=S.PRICE,
F.AMOUNT=S.AMOUNT,
F.STORE_ID=S.STORE_ID
WHEN NOT MATCHED
AND S.METADATA$ACTION='INSERT'
THEN INSERT
(ID,PRODUCT,PRICE,STORE_ID,AMOUNT,EMPLOYEES,LOCATION)
VALUES
(S.ID, S.PRODUCT,S.PRICE,S.STORE_ID,S.AMOUNT,S.EMPLOYEES,S.LOCATION);

ALTER TASK ALL_DATA_CHANGES RESUME;

SHOW TASKS;

-- Change data

INSERT INTO
    SALES_RAW_STAGING
VALUES
    (11, 'Milk', 1.99, 1, 2);

INSERT INTO
    SALES_RAW_STAGING
VALUES
    (12, 'Chocolate', 4.49, 1, 2);

INSERT INTO
    SALES_RAW_STAGING
VALUES
    (13, 'Cheese', 3.89, 1, 1);

UPDATE SALES_RAW_STAGING
SET
    PRODUCT = 'Chocolate bar'
WHERE
    PRODUCT = 'Chocolate';

DELETE FROM SALES_RAW_STAGING
WHERE
    PRODUCT = 'Mango';

-- Verify results
SELECT * FROM SALES_RAW_STAGING;

SELECT * FROM SALES_STREAM;

SELECT * FROM SALES_FINAL_TABLE;

-- Verify the history
SELECT
    *
FROM
    TABLE (INFORMATION_SCHEMA.TASK_HISTORY ())
ORDER BY
    NAME ASC,
    SCHEDULED_TIME DESC;

--============================================================
-- FILE: All resources/Section 19 - Streams/123 Types of streams/Types of stream.txt
--============================================================

-- append-only type --
USE DATABASE STREAMS_DB;

SHOW STREAMS;

SELECT * FROM SALES_RAW_STAGING;

-- Create stream with default
CREATE
OR REPLACE STREAM SALES_STREAM_DEFAULT ON TABLE SALES_RAW_STAGING;

-- Create stream with append-only
CREATE
OR REPLACE STREAM SALES_STREAM_APPEND ON TABLE SALES_RAW_STAGING
APPEND_ONLY = TRUE;

-- View streams
SHOW STREAMS;

-- Insert values
INSERT INTO
    SALES_RAW_STAGING
VALUES
    (14, 'Honey', 4.99, 1, 1);

INSERT INTO
    SALES_RAW_STAGING
VALUES
    (15, 'Coffee', 4.89, 1, 2);

INSERT INTO
    SALES_RAW_STAGING
VALUES
    (15, 'Coffee', 4.89, 1, 2);

SELECT * FROM SALES_STREAM_APPEND;

SELECT * FROM SALES_STREAM_DEFAULT;

-- Delete values
SELECT * FROM SALES_RAW_STAGING

DELETE FROM SALES_RAW_STAGING
WHERE
    ID = 7;

SELECT * FROM SALES_STREAM_APPEND;

SELECT * FROM SALES_STREAM_DEFAULT;

-- Consume stream via "create table ... as"
CREATE OR REPLACE TEMPORARY TABLE PRODUCT_TABLE AS
SELECT
    *
FROM
    SALES_STREAM_DEFAULT;

CREATE OR REPLACE TEMPORARY TABLE PRODUCT_TABLE AS
SELECT
    *
FROM
    SALES_STREAM_APPEND;

-- Update
UPDATE SALES_RAW_STAGING
SET
    PRODUCT = 'Coffee 200g'
WHERE
    PRODUCT = 'Coffee';

SELECT * FROM SALES_STREAM_APPEND;

SELECT * FROM SALES_STREAM;

--============================================================
-- FILE: All resources/Section 19 - Streams/124 Changes clause/Change clause.txt
--============================================================

-- change clause --
-- create example db & table --
CREATE OR REPLACE DATABASE SALES_DB;

CREATE OR REPLACE TABLE SALES_RAW (
    ID VARCHAR,
    PRODUCT VARCHAR,
    PRICE VARCHAR,
    AMOUNT VARCHAR,
    STORE_ID VARCHAR
);

-- Insert values
INSERT INTO
    SALES_RAW
VALUES
    (1, 'Eggs', 1.39, 1, 1),
    (2, 'Baking powder', 0.99, 1, 1),
    (3, 'Eggplants', 1.79, 1, 2),
    (4, 'Ice cream', 1.89, 1, 2),
    (5, 'Oats', 1.98, 2, 1);

ALTER TABLE SALES_RAW
SET CHANGE_TRACKING=TRUE;

SELECT
    *
FROM
    SALES_RAW CHANGES (INFORMATION => DEFAULT) AT (
        OFFSET => -0.5 * 60
    );

SELECT CURRENT_TIMESTAMP;
-- 2026-06-30 13:22:12.814 +0000

-- Insert values
INSERT INTO
    SALES_RAW
VALUES
    (6, 'Bread', 2.99, 1, 2);

INSERT INTO
    SALES_RAW
VALUES
    (7, 'Onions', 2.89, 1, 2);

SELECT
    *
FROM
    SALES_RAW CHANGES (INFORMATION => DEFAULT) AT (
        TIMESTAMP => '2026-06-30 13:22:12.814 +0000'::TIMESTAMP_TZ
    );

UPDATE SALES_RAW
SET
    PRODUCT = 'Toast2'
WHERE
    ID = 6;

-- Information value

SELECT
    *
FROM
    SALES_RAW CHANGES (INFORMATION => DEFAULT) AT (
        TIMESTAMP => '2026-06-30 13:22:12.814 +0000'::TIMESTAMP_TZ
    );

SELECT
    *
FROM
    SALES_RAW CHANGES (INFORMATION => APPEND_ONLY) AT (
        TIMESTAMP => '2026-06-30 13:22:12.814 +0000'::TIMESTAMP_TZ
    );

CREATE OR REPLACE TABLE PRODUCTS AS
SELECT
    *
FROM
    SALES_RAW CHANGES (INFORMATION => APPEND_ONLY) AT (TIMESTAMP => 'your-timestamp'::TIMESTAMP_TZ);

SELECT * FROM PRODUCTS;

--============================================================
-- FILE: All resources/Section 20 - Materialized Views/126 Using materialized views/Create materialized view.txt
--============================================================

-- Remove caching just to have a fair test -- part 1

ALTER SESSION
SET
    USE_CACHED_RESULT = FALSE;

-- disable global caching;
ALTER WAREHOUSE COMPUTE_WH SUSPEND;

ALTER WAREHOUSE COMPUTE_WH RESUME;

-- Prepare table
CREATE OR REPLACE TRANSIENT DATABASE ORDERS;

CREATE OR REPLACE SCHEMA TPCH_SF100;

CREATE OR REPLACE TABLE TPCH_SF100.ORDERS AS
SELECT
    *
FROM
    SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS;

SELECT * FROM ORDERS LIMIT 100;

-- Example statement view --
SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM
    ORDERS.TPCH_SF100.ORDERS
GROUP BY
    YEAR(O_ORDERDATE)
ORDER BY
    YEAR(O_ORDERDATE);

-- Create materialized view
CREATE
OR REPLACE MATERIALIZED VIEW ORDERS_MV AS
SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM
    ORDERS.TPCH_SF100.ORDERS
GROUP BY
    YEAR(O_ORDERDATE);

SHOW MATERIALIZED VIEWS;

-- Query view
SELECT
    *
FROM
    ORDERS_MV
ORDER BY
    YEAR;

-- Update or delete values
UPDATE ORDERS
SET
    O_CLERK = 'Clerk#99900000'
WHERE
    O_ORDERDATE = '1992-01-01';

-- Test updated data --
-- Example statement view --
SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM
    ORDERS.TPCH_SF100.ORDERS
GROUP BY
    YEAR(O_ORDERDATE)
ORDER BY
    YEAR(O_ORDERDATE);

-- Query view
SELECT
    *
FROM
    ORDERS_MV
ORDER BY
    YEAR;

SHOW MATERIALIZED VIEWS;

--============================================================
-- FILE: All resources/Section 20 - Materialized Views/127 Refresh materialized views/Refresh in materialized views.txt
--============================================================

-- Remove caching just to have a fair test -- part 2

ALTER SESSION
SET
    USE_CACHED_RESULT = FALSE;

-- disable global caching;
ALTER WAREHOUSE COMPUTE_WH SUSPEND;

ALTER WAREHOUSE COMPUTE_WH RESUME;

-- Prepare table
CREATE OR REPLACE TRANSIENT DATABASE ORDERS;

CREATE OR REPLACE SCHEMA TPCH_SF100;

CREATE OR REPLACE TABLE TPCH_SF100.ORDERS AS;
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS;

SELECT * FROM ORDERS LIMIT 100;

-- Example statement view --
SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM
    ORDERS.TPCH_SF100.ORDERS
GROUP BY
    YEAR(O_ORDERDATE)
ORDER BY
    YEAR(O_ORDERDATE);

-- Create materialized view
CREATE
OR REPLACE MATERIALIZED VIEW ORDERS_MV AS
SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM
    ORDERS.TPCH_SF100.ORDERS
GROUP BY
    YEAR(O_ORDERDATE);

SHOW MATERIALIZED VIEWS;

-- Query view
SELECT * FROM ORDERS_MV
ORDER BY YEAR;

-- Update or delete values
UPDATE ORDERS
SET
    O_CLERK = 'Clerk#99900000'
WHERE
    O_ORDERDATE = '1992-01-01';

-- Test updated data --
-- Example statement view --
SELECT
    YEAR(O_ORDERDATE) AS YEAR,
    MAX(O_COMMENT) AS MAX_COMMENT,
    MIN(O_COMMENT) AS MIN_COMMENT,
    MAX(O_CLERK) AS MAX_CLERK,
    MIN(O_CLERK) AS MIN_CLERK
FROM
    ORDERS.TPCH_SF100.ORDERS
GROUP BY
    YEAR(O_ORDERDATE)
ORDER BY
    YEAR(O_ORDERDATE);

-- Query view
SELECT
    *
FROM
    ORDERS_MV
ORDER BY
    YEAR;

SHOW MATERIALIZED VIEWS;

SELECT
    *
FROM
    TABLE (
        INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY ()
    );

--============================================================
-- FILE: All resources/Section 20 - Materialized Views/128 Maintenance costs/Maintenance costs.txt
--============================================================

SHOW MATERIALIZED VIEWS;

SELECT
    *
FROM
    TABLE (
        INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY ()
    );

--============================================================
-- FILE: All resources/Section 21 - Dynamic Data Masking/132 Creating a masking policy/Create masking policy.txt
--============================================================

USE DATABASE DEMO_DB;

USE ROLE ACCOUNTADMIN;

-- Prepare table --
CREATE OR REPLACE TABLE CUSTOMERS (
    ID NUMBER,
    FULL_NAME VARCHAR,
    EMAIL VARCHAR,
    PHONE VARCHAR,
    SPENT NUMBER,
    CREATE_DATE DATE DEFAULT CURRENT_DATE
);

-- Insert values in table --
INSERT INTO
    CUSTOMERS (ID, FULL_NAME, EMAIL, PHONE, SPENT)
VALUES
    (
        1,
        'Lewiss MacDwyer',
        'lmacdwyer0@un.org',
        '262-665-9168',
        140
    ),
    (
        2,
        'Ty Pettingall',
        'tpettingall1@mayoclinic.com',
        '734-987-7120',
        254
    ),
    (
        3,
        'Marlee Spadazzi',
        'mspadazzi2@txnews.com',
        '867-946-3659',
        120
    ),
    (
        4,
        'Heywood Tearney',
        'htearney3@patch.com',
        '563-853-8192',
        1230
    ),
    (
        5,
        'Odilia Seti',
        'oseti4@globo.com',
        '730-451-8637',
        143
    ),
    (
        6,
        'Meggie Washtell',
        'mwashtell5@rediff.com',
        '568-896-6138',
        600
    );

-- Set up roles
CREATE OR REPLACE ROLE ANALYST_MASKED;

CREATE OR REPLACE ROLE ANALYST_FULL;


-- Grant select on table to roles
GRANT SELECT ON TABLE DEMO_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_MASKED;

GRANT SELECT ON TABLE DEMO_DB.PUBLIC.CUSTOMERS TO ROLE ANALYST_FULL;

GRANT USAGE ON SCHEMA DEMO_DB.PUBLIC TO ROLE ANALYST_MASKED;

GRANT USAGE ON SCHEMA DEMO_DB.PUBLIC TO ROLE ANALYST_FULL;

-- Grant warehouse access to roles
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_MASKED;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_FULL;

-- Assign roles to a user
GRANT ROLE ANALYST_MASKED TO USER NIKOLAISCHULER;

GRANT ROLE ANALYST_FULL TO USER NIKOLAISCHULER;

-- Set up masking policy
CREATE
OR REPLACE
MASKING POLICY
    PHONE AS (VAL VARCHAR) RETURNS VARCHAR -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN VAL
        ELSE '##-###-##'
    END;

-- Apply policy on a specific column
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN PHONE
SET MASKING POLICY PHONE;

-- Validating policies
USE ROLE ANALYST_FULL;

SELECT * FROM CUSTOMERS;

USE ROLE ANALYST_MASKED;

SELECT * FROM CUSTOMERS;

--============================================================
-- FILE: All resources/Section 21 - Dynamic Data Masking/133 Unset & replace policy/Unset & replace policy.txt
--============================================================

-- More examples
USE ROLE ACCOUNTADMIN;

-- 1) apply policy to multiple columns

-- Apply policy on a specific column
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN FULL_NAME
SET MASKING POLICY PHONE;

-- Apply policy on another specific column
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN PHONE
SET MASKING POLICY PHONE;

-- 2) replace or drop policy
DROP MASKING POLICY PHONE;

CREATE
OR REPLACE
MASKING POLICY
    PHONE AS (VAL VARCHAR) RETURNS VARCHAR -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN VAL
        ELSE CONCAT(LEFT(VAL, 2), '*******')
    END;

-- List and describe policies
DESC MASKING POLICY PHONE;

SHOW MASKING POLICIES;

-- Show columns with applied policies
SELECT
    *
FROM
    TABLE (
        INFORMATION_SCHEMA.POLICY_REFERENCES (POLICY_NAME => 'phone')
    );

-- Remove policy before replacing/dropping
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN FULL_NAME
SET MASKING POLICY PHONE;

ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN EMAIL
UNSET MASKING POLICY;

ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN PHONE
UNSET MASKING POLICY;

-- Replace policy
CREATE
OR REPLACE
MASKING POLICY
    NAMES AS (VAL VARCHAR) RETURNS VARCHAR -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN VAL
        ELSE CONCAT(LEFT(VAL, 2), '*******')
    END;

-- Apply policy
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN FULL_NAME
SET MASKING POLICY NAMES;

-- Validating policies
USE ROLE ANALYST_FULL;

SELECT
    *
FROM
    CUSTOMERS;

USE ROLE ANALYST_MASKED;

SELECT
    *
FROM
    CUSTOMERS;

--============================================================
-- FILE: All resources/Section 21 - Dynamic Data Masking/134 Alter an existing policy/Alter existing policies.txt
--============================================================

-- Alter existing policie
USE ROLE ANALYST_MASKED;

SELECT * FROM CUSTOMERS;

USE ROLE ACCOUNTADMIN;

ALTER MASKING POLICY PHONE
SET
    BODY -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL', 'ACCOUNTADMIN') THEN VAL
        ELSE '**-**-**'
    END;

ALTER TABLE CUSTOMERS
MODIFY COLUMN EMAIL
UNSET MASKING POLICY;

--============================================================
-- FILE: All resources/Section 21 - Dynamic Data Masking/135 Real life examples/Real-life examples.txt
--============================================================

-- More examples - 1
USE ROLE ACCOUNTADMIN;

CREATE
OR REPLACE
MASKING POLICY
    EMAILS AS (VAL VARCHAR) RETURNS VARCHAR -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL') THEN VAL
        WHEN CURRENT_ROLE() IN ('ANALYST_MASKED') THEN REGEXP_REPLACE(VAL, '.+\@', '*****@') -- leave email domain unmasked
        ELSE '********'
    END;

-- Apply policy
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN EMAIL
SET MASKING POLICY EMAILS;

-- Validating policies
USE ROLE ANALYST_FULL;

SELECT
    *
FROM
    CUSTOMERS;

USE ROLE ANALYST_MASKED;

SELECT
    *
FROM
    CUSTOMERS;

USE ROLE ACCOUNTADMIN;

-- More examples - 2
CREATE
OR REPLACE
MASKING POLICY
    SHA2 AS (VAL VARCHAR) RETURNS VARCHAR -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL') THEN VAL
        ELSE SHA2(VAL) -- return hash of the column value
    END;

-- Apply policy
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN FULL_NAME
SET MASKING POLICY SHA2;

ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN FULL_NAME
UNSET MASKING POLICY;

-- Validating policies
USE ROLE ANALYST_FULL;

SELECT
    *
FROM
    CUSTOMERS;

USE ROLE ANALYST_MASKED;

SELECT
    *
FROM
    CUSTOMERS;

USE ROLE ACCOUNTADMIN;

-- More examples - 3
CREATE
OR REPLACE
MASKING POLICY
    DATES AS (VAL DATE) RETURNS DATE -> CASE
        WHEN CURRENT_ROLE() IN ('ANALYST_FULL') THEN VAL
        ELSE DATE_FROM_PARTS(0001, 01, 01)::DATE -- returns 0001-01-01 00:00:00.000
    END;

-- Apply policy on a specific column
ALTER TABLE IF EXISTS CUSTOMERS
MODIFY COLUMN CREATE_DATE
SET MASKING POLICY DATES;

-- Validating policies
USE ROLE ANALYST_FULL;

SELECT
    *
FROM
    CUSTOMERS;

USE ROLE ANALYST_MASKED;

SELECT
    *
FROM
    CUSTOMERS;

--============================================================
-- FILE: All resources/Section 22 - Access Management/139 ACCOUNTADMIN in practice/ACCOUNTADMIN.txt
--============================================================

-- user 1 --
CREATE USER MARIA
PASSWORD = '123'
DEFAULT_ROLE = ACCOUNTADMIN
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE ACCOUNTADMIN TO USER MARIA;

-- user 2 --
CREATE USER FRANK
PASSWORD = '123'
DEFAULT_ROLE = SECURITYADMIN
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE SECURITYADMIN TO USER FRANK;

-- user 3 --
CREATE USER ADAM
PASSWORD = '123'
DEFAULT_ROLE = SYSADMIN
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE SYSADMIN TO USER ADAM;

--============================================================
-- FILE: All resources/Section 22 - Access Management/141 SECURITYADMIN in practice/SECURITYADMIN.txt
--============================================================
-- Securityadmin role --
--  Create and manage roles & users --
-- Create sales roles & users for sales--
CREATE ROLE SALES_ADMIN;

CREATE ROLE SALES_USERS;

-- Create hierarchy
GRANT ROLE SALES_USERS TO ROLE SALES_ADMIN;

-- As per best practice assign roles to sysadmin
GRANT ROLE SALES_ADMIN TO ROLE SYSADMIN;

-- Create sales user
CREATE USER SIMON_SALES
PASSWORD = '123'
DEFAULT_ROLE = SALES_USERS
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE SALES_USERS TO USER SIMON_SALES;

-- Create user for sales administration
CREATE USER OLIVIA_SALES_ADMIN
PASSWORD = '123'
DEFAULT_ROLE = SALES_ADMIN
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE SALES_ADMIN TO USER OLIVIA_SALES_ADMIN;

-- -- Create sales roles & users for hr--
CREATE ROLE HR_ADMIN;

CREATE ROLE HR_USERS;

-- Create hierarchy
GRANT ROLE HR_USERS TO ROLE HR_ADMIN;

-- This time we will not assign roles to sysadmin (against best practice)
-- Grant role hr_admin to role sysadmin;
-- Create hr user
CREATE USER OLIVER_HR
PASSWORD = '123'
DEFAULT_ROLE = HR_USERS
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE HR_USERS TO USER OLIVER_HR;

-- Create user for sales administration
CREATE USER MIKE_HR_ADMIN
PASSWORD = '123'
DEFAULT_ROLE = HR_ADMIN
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE HR_ADMIN TO USER MIKE_HR_ADMIN;

--============================================================
-- FILE: All resources/Section 22 - Access Management/143 SYSADMIN  in practice/SYSADMIN.txt
--============================================================
-- Sysadmin --
-- Create a warehouse of size x-small
CREATE WAREHOUSE PUBLIC_WH
WITH
    WAREHOUSE_SIZE = 'X-SMALL' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE;

-- Grant usage to role public
GRANT USAGE ON WAREHOUSE PUBLIC_WH TO ROLE PUBLIC;

-- Create a database accessible to everyone
CREATE DATABASE COMMON_DB;

GRANT USAGE ON DATABASE COMMON_DB TO ROLE PUBLIC;

-- Create sales database for sales
CREATE DATABASE SALES_DATABASE;

GRANT OWNERSHIP ON DATABASE SALES_DATABASE TO ROLE SALES_ADMIN;

GRANT OWNERSHIP ON SCHEMA SALES_DATABASE.PUBLIC TO ROLE SALES_ADMIN;

SHOW DATABASES;

-- Create database for hr
DROP DATABASE HR_DB;

GRANT OWNERSHIP ON DATABASE HR_DB TO ROLE HR_ADMIN;

GRANT OWNERSHIP ON SCHEMA HR_DB.PUBLIC TO ROLE HR_ADMIN;

--============================================================
-- FILE: All resources/Section 22 - Access Management/145 Custom roles in practice/Custom roles.txt
--============================================================
USE ROLE SALES_ADMIN;

USE DATABASE SALES_DATABASE;

-- Create table --
CREATE OR REPLACE TABLE CUSTOMERS (
    ID NUMBER,
    FULL_NAME VARCHAR,
    EMAIL VARCHAR,
    PHONE VARCHAR,
    SPENT NUMBER,
    CREATE_DATE DATE DEFAULT CURRENT_DATE
);

-- Insert values in table --
INSERT INTO
    CUSTOMERS (ID, FULL_NAME, EMAIL, PHONE, SPENT)
VALUES
    (
        1,
        'Lewiss MacDwyer',
        'lmacdwyer0@un.org',
        '262-665-9168',
        140
    ),
    (
        2,
        'Ty Pettingall',
        'tpettingall1@mayoclinic.com',
        '734-987-7120',
        254
    ),
    (
        3,
        'Marlee Spadazzi',
        'mspadazzi2@txnews.com',
        '867-946-3659',
        120
    ),
    (
        4,
        'Heywood Tearney',
        'htearney3@patch.com',
        '563-853-8192',
        1230
    ),
    (
        5,
        'Odilia Seti',
        'oseti4@globo.com',
        '730-451-8637',
        143
    ),
    (
        6,
        'Meggie Washtell',
        'mwashtell5@rediff.com',
        '568-896-6138',
        600
    );

SHOW TABLES;

-- Query from table --
SELECT
    *
FROM
    CUSTOMERS;

USE ROLE SALES_USERS;

-- Grant usage to role
USE ROLE SALES_ADMIN;

GRANT USAGE ON DATABASE SALES_DATABASE TO ROLE SALES_USERS;

GRANT USAGE ON SCHEMA SALES_DATABASE.PUBLIC TO ROLE SALES_USERS;

GRANT
SELECT
    ON TABLE SALES_DATABASE.PUBLIC.CUSTOMERS TO ROLE SALES_USERS;

-- Validate privileges --
USE ROLE SALES_USERS;

SELECT
    *
FROM
    CUSTOMERS;

DROP TABLE CUSTOMERS;

DELETE FROM CUSTOMERS;

SHOW TABLES;

-- Grant drop on table
USE ROLE SALES_ADMIN;

GRANT
DELETE ON TABLE SALES_DATABASE.PUBLIC.CUSTOMERS TO ROLE SALES_USERS;

USE ROLE SALES_ADMIN;

--============================================================
-- FILE: All resources/Section 22 - Access Management/147 USERADMIN in practice/USERADMIN.txt
--============================================================
-- Useradmin --
-- user 4 --
CREATE USER BEN PASSWORD = '123' DEFAULT_ROLE = ACCOUNTADMIN MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE HR_ADMIN TO USER BEN;

SHOW ROLES;

GRANT ROLE HR_ADMIN TO ROLE SYSADMIN;