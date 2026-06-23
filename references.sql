-- ============================================================
-- SNOWFLAKE GENERIC QUERY TEMPLATES
-- Comprehensive Reference Guide
-- Covers Warehouses, Databases, Schemas, Tables,
-- Stages, File Formats, COPY INTO, JSON, Parquet,
-- Semi-Structured Data, Metadata, and Utility Queries.
-- ============================================================


-- ============================================================
-- 1. ROLE & CONTEXT MANAGEMENT
-- ============================================================

-- Use a specific role
USE ROLE <ROLE_NAME>;

-- Use a database
USE DATABASE <DATABASE_NAME>;

-- Use a schema
USE SCHEMA <SCHEMA_NAME>;
USE SCHEMA <DATABASE_NAME>.<SCHEMA_NAME>;


-- ============================================================
-- 2. NAMESPACE HIERARCHY
-- ============================================================

-- Snowflake object hierarchy:
-- DATABASE.SCHEMA.OBJECT_NAME

-- Example:
-- MY_DB.PUBLIC.CUSTOMERS


-- ============================================================
-- 3. WAREHOUSE OPERATIONS
-- ============================================================

-- Create or replace warehouse
CREATE OR REPLACE WAREHOUSE <WAREHOUSE_NAME>
WITH
    WAREHOUSE_SIZE = <XSMALL | SMALL | MEDIUM | LARGE>
    AUTO_SUSPEND = <SECONDS>
    AUTO_RESUME = <TRUE | FALSE>
    SCALING_POLICY = '<ECONOMY | STANDARD>';


-- Suspend warehouse
ALTER WAREHOUSE <WAREHOUSE_NAME> SUSPEND;


-- Resume warehouse
ALTER WAREHOUSE <WAREHOUSE_NAME> RESUME;


-- Modify warehouse settings
ALTER WAREHOUSE <WAREHOUSE_NAME>
SET
    AUTO_SUSPEND = <SECONDS>;


-- Drop warehouse
DROP WAREHOUSE <WAREHOUSE_NAME>;


-- ============================================================
-- 4. DATABASE OPERATIONS
-- ============================================================

-- Create database
CREATE OR REPLACE DATABASE <DATABASE_NAME>;


-- Rename database
ALTER DATABASE <OLD_DATABASE_NAME>
RENAME TO <NEW_DATABASE_NAME>;


-- Drop database
DROP DATABASE <DATABASE_NAME>;


-- ============================================================
-- 5. SCHEMA OPERATIONS
-- ============================================================

-- Create schema
CREATE OR REPLACE SCHEMA <DATABASE_NAME>.<SCHEMA_NAME>;


-- Drop schema
DROP SCHEMA <DATABASE_NAME>.<SCHEMA_NAME>;


-- ============================================================
-- 6. TABLE OPERATIONS
-- ============================================================

-- Create or replace table
CREATE OR REPLACE TABLE <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME> (
    <COLUMN_1> <DATA_TYPE>,
    <COLUMN_2> <DATA_TYPE>,
    <COLUMN_3> <DATA_TYPE>
)
COMMENT = '<TABLE_COMMENT>';


-- Create table if not exists
CREATE TABLE IF NOT EXISTS <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME> (
    <COLUMN_1> <DATA_TYPE>,
    <COLUMN_2> <DATA_TYPE>
);


-- Create table with VARIANT column for semi-structured data
CREATE OR REPLACE TABLE <TABLE_NAME> (
    RAW_DATA VARIANT
);


-- Truncate table
TRUNCATE TABLE <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>;


-- Drop table
DROP TABLE <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>;


-- ============================================================
-- 7. BASIC QUERY OPERATIONS
-- ============================================================

-- Select all records
SELECT *
FROM <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>;


-- Count rows
SELECT COUNT(*)
FROM <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>;


-- Filter rows
SELECT *
FROM <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
WHERE <COLUMN_NAME> = '<VALUE>';


-- Limit rows
SELECT *
FROM <TABLE_NAME>
LIMIT <N>;


-- ============================================================
-- 8. STAGE OPERATIONS
-- ============================================================

-- Create external stage with AWS credentials
CREATE OR REPLACE STAGE <DATABASE_NAME>.<SCHEMA_NAME>.<STAGE_NAME>
URL = '<S3_BUCKET_PATH>'
CREDENTIALS = (
    AWS_KEY_ID = '<AWS_KEY_ID>'
    AWS_SECRET_KEY = '<AWS_SECRET_KEY>'
);


-- Create public external stage
CREATE OR REPLACE STAGE <DATABASE_NAME>.<SCHEMA_NAME>.<STAGE_NAME>
URL = '<S3_BUCKET_PATH>';


-- Create stage with file format attached
CREATE OR REPLACE STAGE <DATABASE_NAME>.<SCHEMA_NAME>.<STAGE_NAME>
URL = '<S3_BUCKET_PATH>'
FILE_FORMAT = <FILE_FORMAT_NAME>;


-- Alter stage credentials
ALTER STAGE <STAGE_NAME>
SET
    CREDENTIALS = (
        AWS_KEY_ID = '<NEW_AWS_KEY>'
        AWS_SECRET_KEY = '<NEW_AWS_SECRET>'
    );


-- Describe stage
DESC STAGE <DATABASE_NAME>.<SCHEMA_NAME>.<STAGE_NAME>;
DESCRIBE STAGE <DATABASE_NAME>.<SCHEMA_NAME>.<STAGE_NAME>;


-- List files inside stage
LIST @<DATABASE_NAME>.<SCHEMA_NAME>.<STAGE_NAME>;


-- ============================================================
-- 9. FILE FORMAT OPERATIONS
-- ============================================================

-- Create CSV file format
CREATE OR REPLACE FILE FORMAT <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
TYPE = CSV
FIELD_DELIMITER = '<DELIMITER>'
SKIP_HEADER = <NUMBER>;


-- Create JSON file format
CREATE OR REPLACE FILE FORMAT <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
TYPE = JSON
TIME_FORMAT = AUTO;


-- Create Parquet file format
CREATE OR REPLACE FILE FORMAT <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
TYPE = PARQUET;


-- Alter file format
ALTER FILE FORMAT <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
SET
    SKIP_HEADER = <NUMBER>;

-- Alter file format type
-- Note: You cannot change type after creation
ALTER FILE FORMAT <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
SET
    TYPE = <TYPE>;


-- Describe file format
DESC FILE FORMAT <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>;


-- ============================================================
-- 10. COPY INTO OPERATIONS
-- ============================================================

-- Basic COPY INTO from S3
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM '<S3_BUCKET_PATH>'
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
);


-- COPY INTO from stage
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
);


-- COPY INTO using named file format
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
FILE_FORMAT = (
    FORMAT_NAME = <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
);


-- COPY INTO with file format override options
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
FILE_FORMAT = (
    FORMAT_NAME = <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
    SKIP_HEADER = 1
);


-- COPY INTO loading specific files
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
FILES = (
    'file1.csv',
    'file2.csv'
);


-- COPY INTO using pattern matching
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
PATTERN = '.*[.]csv';


-- COPY INTO with validation mode
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
VALIDATION_MODE = 'RETURN_5_ROWS';


-- Other validation mode options
-- VALIDATION_MODE = 'RETURN_ERRORS';
-- VALIDATION_MODE = 'RETURN_ALL_ERRORS';
-- VALIDATION_MODE = 'RETURN_2_ROWS';
-- VALIDATION_MODE = 'RETURN_5_ROWS';


-- COPY INTO with error handling
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
ON_ERROR = 'CONTINUE';


-- Other ON_ERROR options
-- ON_ERROR = 'ABORT_STATEMENT';
-- ON_ERROR = 'SKIP_FILE';
-- ON_ERROR = 'SKIP_FILE_3';
-- ON_ERROR = 'SKIP_FILE_10%';


-- COPY INTO with truncate columns option
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
TRUNCATECOLUMNS = TRUE;


-- COPY INTO using column mapping
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME> (
    <COLUMN_1>,
    <COLUMN_2>
)
FROM (
    SELECT
        $1,
        $2
    FROM @<STAGE_NAME>
)
FILE_FORMAT = (
    TYPE = CSV
);


-- COPY INTO using stage alias
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM (
    SELECT
        s.$1,
        s.$2
    FROM @<STAGE_NAME> s
)
FILE_FORMAT = (
    TYPE = CSV
);


-- COPY INTO with transformations
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM (
    SELECT
        $1,
        CONCAT($2, ' ', $3),
        CASE
            WHEN $4 > 0 THEN TRUE
            ELSE FALSE
        END
    FROM @<STAGE_NAME>
)
FILE_FORMAT = (
    TYPE = CSV
);


-- Fully featured COPY INTO template
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>
FILE_FORMAT = (
    FORMAT_NAME = <DATABASE_NAME>.<SCHEMA_NAME>.<FILE_FORMAT_NAME>
)
FILES = ('file1.csv')
PATTERN = '.*[.]csv'
ON_ERROR = 'CONTINUE'
VALIDATION_MODE = 'RETURN_ERRORS'
TRUNCATECOLUMNS = TRUE;


-- COPY INTO when stage already has file format attached
COPY INTO <DATABASE_NAME>.<SCHEMA_NAME>.<TABLE_NAME>
FROM @<STAGE_NAME>;


-- ============================================================
-- 11. QUERYING STAGED FILES
-- ============================================================

-- Query files directly from stage
SELECT *
FROM @<STAGE_NAME>
LIMIT 10;


-- Query stage using file format
SELECT *
FROM @<STAGE_NAME> (
    FILE_FORMAT => '<FILE_FORMAT_NAME>'
)
LIMIT 10;


-- Query semi-structured data directly from stage
SELECT
    $1:<FIELD_NAME>::STRING
FROM @<STAGE_NAME>;


-- ============================================================
-- 12. SEMI-STRUCTURED DATA OPERATIONS
-- ============================================================

-- Positional column access
SELECT
    $1,
    $2,
    $3
FROM @<STAGE_NAME>;


-- Access JSON/object keys
SELECT
    $1:key_name
FROM @<STAGE_NAME>;


-- Access nested JSON keys
SELECT
    $1:job:title::STRING AS job_title
FROM <TABLE_NAME>;


-- Dot notation access
SELECT
    $1:job.salary::STRING AS salary
FROM <TABLE_NAME>;


-- Cast values
SELECT
    $1:key_name::STRING
FROM @<STAGE_NAME>;


-- Query VARIANT column directly
SELECT
    RAW_DATA:first_name::STRING
FROM <TABLE_NAME>;


-- Access JSON arrays
SELECT
    $1:Skills[0]::STRING AS skill_1,
    $1:Skills[1]::STRING AS skill_2
FROM <TABLE_NAME>;


-- Count array elements
SELECT
    ARRAY_SIZE($1:spoken_languages) AS language_count
FROM <TABLE_NAME>;


-- Flatten JSON arrays
SELECT
    s.value:language::STRING AS language,
    s.value:level::STRING AS level
FROM <TABLE_NAME>,
TABLE(FLATTEN(RAW_DATA:spoken_languages)) s;


-- ============================================================
-- 13. JSON LOADING & PARSING
-- ============================================================

-- Create JSON table
CREATE OR REPLACE TABLE <TABLE_NAME> (
    RAW_FILE VARIANT
);


-- Load JSON data
COPY INTO <TABLE_NAME>
FROM @<STAGE_NAME>
FILE_FORMAT = <JSON_FILE_FORMAT>;


-- Query JSON fields
SELECT
    RAW_FILE:<FIELD_1> AS <FIELD_1>
FROM <TABLE_NAME>;


-- Query JSON fields with casting
SELECT
    RAW_FILE:<FIELD_1>::INT AS <FIELD_1>,
    RAW_FILE:<FIELD_2>::STRING AS <FIELD_2>,
    RAW_FILE:<FIELD_3>::STRING AS <FIELD_3>
FROM <TABLE_NAME>;


-- Insert parsed JSON into structured table
INSERT INTO <TARGET_TABLE>
SELECT
    RAW_FILE:<FIELD_1>::STRING,
    RAW_FILE:<FIELD_2>::STRING
FROM <SOURCE_TABLE>;


-- ============================================================
-- 14. PARQUET OPERATIONS
-- ============================================================

-- Create parquet file format
CREATE OR REPLACE FILE FORMAT <FILE_FORMAT_NAME>
TYPE = PARQUET;


-- Query parquet staged data
SELECT
    $1:<COLUMN_1>,
    $1:<COLUMN_2>,
    $1:<COLUMN_3>
FROM @<STAGE_NAME>
LIMIT 5;


-- Query parquet data with casting and aliases
SELECT
    $1:<COLUMN_1>::VARCHAR(50) AS <COLUMN_1>,
    DATE($1:<COLUMN_2>::INT) AS <COLUMN_2>,
    $1:<COLUMN_3>::INT AS <COLUMN_3>,
    METADATA$FILENAME AS file_name,
    METADATA$FILE_LAST_MODIFIED AS last_modified
FROM @<STAGE_NAME>
LIMIT 5;


-- ============================================================
-- 15. INSERT OPERATIONS
-- ============================================================

-- Insert from select
INSERT INTO <TABLE_NAME>
SELECT
    <COLUMN_1>,
    <COLUMN_2>
FROM <SOURCE_TABLE>;


-- ============================================================
-- 16. METADATA COLUMNS
-- ============================================================

-- Query file metadata
SELECT
    METADATA$FILENAME AS file_name,
    METADATA$FILE_LAST_MODIFIED AS last_modified
FROM @<STAGE_NAME>;


-- ============================================================
-- 17. DATE & TIME FUNCTIONS
-- ============================================================

-- Current date/time/user functions
SELECT
    CURRENT_DATE() AS loaded_at,
    CURRENT_TIMESTAMP() AS loaded_at_timestamp,
    TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP()) AS loaded_at_timestamp_ntz,
    CURRENT_TIME() AS loaded_at_time,
    CURRENT_USER() AS loaded_by;


-- Convert integer to date
-- Snowflake interprets integer as epoch days
SELECT DATE(<INTEGER_EXPRESSION>);


-- Convert timestamp
SELECT TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP());


-- ============================================================
-- 18. UTILITY FUNCTIONS
-- ============================================================

-- CASE statement
CASE
    WHEN <CONDITION> THEN <VALUE>
    ELSE <VALUE>
END


-- CONCAT strings
CONCAT(<COLUMN_1>, ' ', <COLUMN_2>);


-- ARRAY_SIZE
ARRAY_SIZE(<ARRAY_COLUMN>);


-- ============================================================
-- 19. COMMON COPY INTO OPTIONS CHEAT SHEET
-- ============================================================

-- FILE_FORMAT       -> Defines parsing rules
-- FILES             -> Loads specific files
-- PATTERN           -> Regex-based file selection
-- ON_ERROR          -> Error handling strategy
-- VALIDATION_MODE   -> Validate data without loading
-- TRUNCATECOLUMNS   -> Trims oversized column values
-- SKIP_HEADER       -> Skips header rows
-- FIELD_DELIMITER   -> Column separator
-- FORMAT_NAME       -> Reusable named file format


-- ============================================================
-- 20. DIRECT STAGE QUERY SUPPORT
-- ============================================================

-- Snowflake allows direct querying from stages for
-- specific file formats.

-- Supported formats:
-- CSV
-- JSON
-- PARQUET
-- AVRO
-- ORC
-- XML

-- Unsupported formats:
-- XLSX / EXCEL
-- PDF
-- IMAGES
-- ZIP
-- DOCX


-- ============================================================
-- DIRECT CSV STAGE QUERY
-- ============================================================

-- Query CSV files directly from stage
-- Uses positional columns because no table schema exists yet
SELECT
    $1,
    $2,
    $3
FROM @<CSV_STAGE_NAME>;


-- ============================================================
-- DIRECT JSON STAGE QUERY
-- ============================================================

-- Query JSON files directly from stage
SELECT
    $1:<COLUMN_1>::STRING AS <COLUMN_1>,
    $1:<COLUMN_2>::INT AS <COLUMN_2>
FROM @<JSON_STAGE_NAME>;


-- ============================================================
-- DIRECT PARQUET STAGE QUERY
-- ============================================================

-- Query parquet files directly from stage
SELECT
    $1:<COLUMN_1>::INT AS <COLUMN_1>,
    $1:<COLUMN_2>::STRING AS <COLUMN_2>
FROM @<PARQUET_STAGE_NAME>;


-- ============================================================
-- QUERY STAGE WITH FILE FORMAT
-- ============================================================

-- Attach file format during query
SELECT *
FROM @<STAGE_NAME> (
    FILE_FORMAT => <FILE_FORMAT_NAME>
);


-- ============================================================
-- COMMON STAGE QUERY USE CASES
-- ============================================================

-- Preview staged files
-- Validate file structure
-- Debug COPY INTO operations
-- Build ETL transformations
-- Test parsing rules


-- ============================================================
-- RECOMMENDED DATA FLOW
-- ============================================================

-- Preferred production flow:
-- External File
--      -> Stage
--      -> COPY INTO Table
--      -> Query Table

-- Direct stage querying is useful for:
-- Exploration
-- Validation
-- ETL development
-- Small previews

-- Table querying is preferred for:
-- Analytics
-- Reporting
-- Production workloads
-- Performance optimization


-- ============================================================
-- END OF FILE
-- ============================================================
