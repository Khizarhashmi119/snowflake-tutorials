# LAB 8: STAGES AND SEMI-STRUCTURED DATA

## Create a Snowflake Stage Object

👉 In this lesson, we'll create a stage that points to an **S3** (Amazon Simple Storage Service) bucket the Education Services team created for you to use. 

To begin, let's grab **context information** we will use throughout this lab. 

- Click the **Start** button to activate this notebook.

- Run the following Python cell.

---

#### :warning: Each time a new session is started for this notebook, you need to rerun the cell below to configure "variables" for use in later cells. :warning:

---

**Cell: `cell3`**

```python
import streamlit as st
from snowflake.snowpark.context import get_active_session
session = get_active_session()
user = session.get_current_user().strip('"')
your_db = user + '_DB'
print('Your current CONTEXT information:')
print('---------------------------------')
print(session)
print('Your current USER is ' + user)
```

---

### Stage creation. 🥋

1. In the Snowsight Object Browser, go to **Catalog** > **Database Explorer** and select the **(animal)_UTIL_DB** database you created in an earlier lab.
1. Then select the schema named **PUBLIC**.
1. Click on the blue **Create** button top right.
1. Select **Stage** > **External Stage** > **Amazon S3**.

![Create stage option (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_create_stage_new_1.png)

A stage creation dialog will appear.

![Stage creation dialog (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_create_stage_dialog_1.png)

1. In the **Stage Name** text box, enter: `like_a_window_into_an_s3_bucket`.
1. Enter the following name into the **URL** text box: `s3://uni-lab-files`.
1. Ensure that the **Directory table** option remains selected.
1. Click the blue **Create** button in the lower right corner.
1. The following screen may request the name of a Snowflake Virtual Warehouse to use - choose your named warehouse **(animal)_WH**.

---

### The object browser shows the files available in this new stage you have created. 📓

![Stage files (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_new_stage_files.png)


💡 **Tip**: These files and folders are sitting in an AWS S3 bucket that is owned and managed by the Snowflake Education Services team that is providing you with this course. You can see the list of files here because you created a stage, which acts like a window to allow you to see and access the files in that bucket. Our bucket is public, but the buckets your company creates will likely require credentials.

---

### A stage or not a stage? 📓 

One potentially confusing aspect of stages in Snowflake is that the stage object you created is not a location. The location (the S3 bucket that holds the files) already existed. So, what did you just create? 

Well, you created something that tells Snowflake some information about a location where some files are already staged. You didn't create the actual stage location; you created something more like a window into that stage location. Your Snowflake stage object is almost like a File Format in that it holds configuration information that makes loading files easier.

Sometimes, when we define a Snowflake stage, we also provide access credentials, but in this case, we did not. Our stage is just an object we named that points to an S3 bucket where some files are already staged.

---

## Use the `LIST` Command from a SQL Cell 🥋 

### Use the `LIST` command to view the files in your new stage. 🥋 

The `LIST` command returns a list of files that have been staged (that is uploaded from a local file system or unloaded from a table) in a Snowflake stage. 
- This command can also be abbreviated to `LS`.
- You refer to a Stage object in Snowflake by its name, prefixed with an ampersand `@` character.

Try the following `LIST` command yourself.

---

**Cell: `cell8`**

```sql
USE SCHEMA {{user}}_UTIL_DB.PUBLIC;

LIST @like_a_window_into_an_s3_bucket;
```

---

### Snowflake Object naming conventions. 📓

Notice that Snowflake doesn't care about capitalization. We entered the name of our new Stage object in lowercase. Snowflake always assumes you really mean to type everything in **UPPER CASE**, so it converts it for you. Because of this, you can type lowercase or mixed case when creating or querying objects, and Snowflake will convert it to all uppercase behind the scenes.

(Unless you use quotes when creating things, and then you'll have to use quotes forever after that to deal with the object.)

So, when running commands on the Stage, any case spelling will work. However, S3 is very particular, so you must be very disciplined once you get past the Stage Object name. You have to use the exact spelling - with correct cases, even for the file extension.  

![Stage files (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_list_command_2.png)

---

### :mag_right: Check 8 (OB08). 🔎

- Do you have an external stage created, named `like_a_window_into_an_s3_bucket`?
- Call the grading stored procedure to check your work.

---

**Cell: `cell11`**

```sql
CALL common_db.resources.local_grader('OB08', '{{user}}');
```

---

## Use the `COPY INTO` Statement to Load Data 🥋 

### Create a table for soil types. 🥋 

Make sure you create it in the **(animal)_GARDEN_PLANTS** database, in the **VEGGIES** schema. To do so, you must alter LINE 2 in the following SQL cell, replacing the hash `('#')` characters with the correct schema name, before executing the cell.

---

**Cell: `cell13`**

```sql
-- replace the hash characters ('#') on the next line
USE SCHEMA {{user}}_GARDEN_PLANTS.#######;

CREATE OR REPLACE TABLE vegetable_details_soil_type
( plant_name VARCHAR(25)
 ,soil_type NUMBER(1,0)
);
```

---

### Load a file from the S3 bucket into the new table. 📓

Previously you used the Snowsight **Load Data** screen to copy data from a staged file into a table. When using this "wizard-driven" approach Snowflake generates and executes code behind the scenes to perform this action. For this data load, we will explore the programmatic approach.

You will use a `COPY INTO` statement, run from within a notebook SQL cell.

To use the `COPY INTO` statement, it is best to have four things in place:

1. A table 

1. A stage object

1. A file

1. A file format (optional)

The **file format** is optional because there is an alternative, but it's a cleaner process if you have one. As mentioned earlier, the file format is an object that provides Snowflake with instructions on handling the data being loaded from a stage. In the following example, we will provide these "instructions" inline rather than defining a file format.

---

### A `COPY INTO` statement you can run. 🥋

---

**Cell: `cell16`**

```sql
COPY INTO vegetable_details_soil_type
FROM @{{user}}_util_db.public.like_a_window_into_an_s3_bucket
FILES = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
FILE_FORMAT = (
    TYPE=csv
    FIELD_DELIMITER = '|'
    SKIP_HEADER=1
);
```

---

### :mag_right: Check 9 (OB09). 🔎

- Do you have 42 rows loaded into the **vegetable_details_soil_type** table in the **(animal)_garden_plants.veggies** schema?
- Call the grading stored procedure to check your work.

---

**Cell: `cell18`**

```sql
CALL common_db.resources.local_grader('OB09', '{{user}}');
```

---

## Data Loading Tips and Tricks 📓

- All flat files are loaded using file formats that have a type of CSV (Comma Separated Values). So, use `TYPE = CSV` for any flat file (TSV, Pipe Delimited, .txt, and so on).

- The **FIELD_DELIMITER** property is very important. It should match the actual Column Separator being used in the file. 

- The Data Load Wizard can help you write your file format (named or inline). Just choose the settings you need in the drop lists, then click the Show SQL link to access the SQL code for those settings.

---

## Challenge Exercise: Create a Soil Type Look up Table 🎯 

In this challenge exercise, you are going to create a new table named **lu_soil_type** and load it with data from a supplied file in one of the following ways:
- using the **Load Data** wizard **OR**
- writing your own `COPY INTO` statement and executing this

:warning: Only high-level instructions will be supplied for this exercise, and you will be expected to "figure out the steps" based on the material we have covered already. :warning:

First, set about creating the table. Make sure you create it in the **(animal)_GARDEN_PLANTS** database in the **VEGGIES** schema.

---

**Cell: `cell21`**

```sql
USE SCHEMA {{user}}_GARDEN_PLANTS.VEGGIES;

CREATE OR REPLACE TABLE lu_soil_type(
    soil_type_id NUMBER,	
    soil_type VARCHAR(15),
    soil_description VARCHAR(75)
);
```

---

### Download the source data file. 🎯 

Run the following Python code cell and click on the link generated to download the **LU_SOIL_TYPE.tsv** file.

---

**Cell: `cell23`**

```python
snowpark_df = session.sql("SELECT GET_PRESIGNED_URL(@common_db.resources.course_files, 'LU_SOIL_TYPE.tsv')")
collected_data = snowpark_df.collect()
st.write('Click the following link to download the file:')
st.write(collected_data[0][0])
```

---

### Load table rows from the downloaded file. 🎯

The file **LU_SOIL_TYPE.tsv** shares many of the file format properties with the file you loaded previously, **VEG_NAME_TO_SOIL_TYPE_PIPE.txt**, with one major exception. Let's outline these:
- **TYPE**: the file has an extension of **.tsv** (so you should be able to figure out it's [type](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table#type-csv)).
- **SKIP_HEADER**: the file has one header row.
- **FIELD_DELIMITER**: the file **IS NOT** pipe delimited (`'|'`) it is **TAB** delimited, which is represented by the following characters: `'\t'`.


#### Option 1:
- Use the **Load Data** wizard in Snowsight.

#### OR

#### Option 2:
- Using the notes above, modify and run the following SQL `COPY INTO` fragment.
- Supply the target table name (line 1).
- Supply the file format options (lines 5-7).

---

**Cell: `cell25`**

```sql
COPY INTO ##_####_####
FROM @{{user}}_util_db.public.like_a_window_into_an_s3_bucket
FILES = ( 'LU_SOIL_TYPE.tsv')
FILE_FORMAT = (
    ####=###
    #####_######### = ###
    ####_######=#
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
);
```

---

### :mag_right: Check 10 (OB10). 🔎

- Do you have 8 rows loaded into the **lu_soil_type** table in the **(animal)_garden_plants.veggies** schema?
- Call the grading stored procedure to check your work.

---

**Cell: `cell27`**

```sql
CALL common_db.resources.local_grader('OB10', '{{user}}');
```

---

## Work with Semi-structured Data 📓

Semi-structured data is data that does not conform to the standards of traditional structured data but contains tags (labels) or other types of mark-up that identify individual, distinct entities within the data. Two key attributes that distinguish semi-structured data from structured data are nested data structures and the lack of a fixed schema:

- Semi-structured data does not require a prior definition of a schema and can constantly evolve (new attributes can be added at any time).
- Unlike structured data, which represents data as a flat table, semi-structured data can contain N-level hierarchies of nested information.

Here's an example of JSON data, which is one of the semi-structured types supported by Snowflake.

![Vegetable details table data (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_json_data_extract.png)

### The `VARIANT` data type.

Snowflake offers the [`VARIANT`](https://docs.snowflake.com/en/sql-reference/data-types-semistructured#label-data-type-variant) data type to support the storage of semi-structured data. This is a data type that can hold a value of any other data type, including [`ARRAY`](https://docs.snowflake.com/en/sql-reference/data-types-semistructured#array) and [`OBJECT`](https://docs.snowflake.com/en/sql-reference/data-types-semistructured#object) (which are also often used in conjunction with semi-structured data). Using this data type, we can preserve semi-structured data's hierarchical/nested format when ingesting it to Snowflake.

---

### Create a table including a `VARIANT` column. 🥋

Create a table called **VEGETABLE_DETAILS_PLANT_HEIGHT** in the **VEGGIES** schema of the **(animal)_GARDEN_PLANTS** database. This contains a single column - of the `VARIANT` data type.

---

**Cell: `cell30`**

```sql
CREATE OR REPLACE TABLE {{user}}_GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS_PLANT_HEIGHT (
	record VARIANT
);
```

---

### Download the JSON source data file. 🥋

Run the following Python code cell and click on the link generated to download the JSON **veg_plant_height.json** file.

Depending on your browser, this may open directly in a new tab/window or download. If downloaded, open the file in a text editor on your local system to review its structure.

💡 **Tip**: You are downloading this file to review its structure and content. When loading the data from this file, we will use the file already located in the stage.

---

**Cell: `cell32`**

```python
snowpark_df = session.sql("SELECT GET_PRESIGNED_URL(@common_db.resources.course_files, 'veg_plant_height.json')")
collected_data = snowpark_df.collect()
st.write('Click the following link to download the file:')
st.write(collected_data[0][0])
```

---

### A `COPY INTO` statement you can run to load JSON data. 🥋 

Now run the following statement to load this JSON data into your new table.

- What has changed in the following **file format** specifications to accommodate the loading of the semi-structured, rather than structured, data?

---

**Cell: `cell34`**

```sql
COPY INTO vegetable_details_plant_height
FROM @common_db.resources.course_files/veg_plant_height.json
FILE_FORMAT = (TYPE = 'JSON');
```

---

### Query the table loaded from JSON data. 🥋

Snowflake has special operators and functions to query complex hierarchical data stored in a `VARIANT`. We will introduce those shortly, but for now, let's review a single row of data from the **vegetable_details_plant_height** table using regular SQL syntax of the type we would use against structured data sets.

---

**Cell: `cell36`**

```sql
SELECT *
FROM vegetable_details_plant_height
LIMIT 1;
```

---

### Query semi-structured data. 

What you will have observed in the query above is that the `VARIANT` column named **RECORD** contains a set of four key-pair values. This is fine, with the data retained in the format in which it was ingested. However, there are likely times when you will want to isolate individual elements for processing and use in a structured format for reporting. 

Here are some high-level guidelines for **traversing** semi-structured data in Snowflake. 
- Insert a colon `:` between a `VARIANT` column name and any first-level element
    - <column>:<level1_element>
- Use dot notation to access subsequent elements nested further down the hierarchical path in a JSON object: 
    - <column>:<level1_element>.<level2_element>.<level3_element>
- The **column name** is case-insensitive, but element names **are** case-sensitive.
- You can optionally enclose element names in double quotes.

Try this simple example to **flatten** (which means to represent as structured data) the rows in the **vegetable_details_plant_height** table.

---

**Cell: `cell38`**

```sql
//Returns the data in a way that makes it look like a normalized table
SELECT 
    record:PLANT_NAME::STRING AS plant_name,
    record:UOM AS uom, -- no casting 
    record:LOW_END_OF_RANGE::INTEGER AS low_end_of_range,
    record:HIGH_END_OF_RANGE::INTEGER AS high_end_of_range
FROM vegetable_details_plant_height;
```

---

### Casting `VARIANT` values. 📓

What you may have noticed when running the query above was that the **UOM** column values were not **cast** (converted to other datatypes) like the others, so they looked slightly different. They were wrapped in double quotes, like this: "F".

This does not mean the column values are `VARCHAR` or `STRING` (its synonym); instead, it indicates that it is still a `VARIANT` value. The `VARIANT` values are not strings; rather, the `VARIANT` values contain strings.

In Snowflake SQL, you can cast datatypes from one to another in the following ways:
- using the [`CAST()`](https://docs.snowflake.com/en/sql-reference/functions/cast) function
- using the `::` operator as an alternative syntax (e.g. **record:PLANT_NAME::STRING**)

---

## Challenge Exercise: Create a View to Showcase Semi-structured Data 🎯 

In this challenge exercise you are going to create a new [View](https://docs.snowflake.com/en/user-guide/views-introduction) object. A View allows the result of a query to be accessed as if it were a table. The aim is to present the data in the **vegetable_details_plant_height** in a normalized fashion.

1. Modify the scaffolded SQL in the cell below - the three lines requiring changes have been identified with `-- ***`.
1. **CAST** the **UOM** column to `VARCHAR`.
1. **SWAP** the order of the **LOW_END_OF_RANGE** and **HIGH_END_OF_RANGE** columns.

---

**Cell: `cell41`**

```sql
-- modify the following code according to the instructions above, then run to create the object
CREATE OR REPLACE VIEW vegetable_details_plant_height_vw AS 
SELECT 
    record:PLANT_NAME::STRING AS plant_name,
    record:UOM AS uom, -- *** 
    record:LOW_END_OF_RANGE::INTEGER AS low_end_of_range, -- ***
    record:HIGH_END_OF_RANGE::INTEGER AS high_end_of_range -- ***
FROM vegetable_details_plant_height;
```

---

**Cell: `cell42`**

```sql
-- then run this query against your new view to confirm the output
SELECT *
FROM vegetable_details_plant_height_vw;
```

---

### :mag_right: Check 11 (OB11). 🔎

- Have you created a view named **vegetable_details_plant_height_vw** in the **VEGGIES** schema of the **(animal)_GARDEN_PLANTS** database?
- Has the **UOM** been cast to a `VARCHAR` (text) column, with the **HIGH_END_OF_RANGE** column in the third position and **LOW_END_OF_RANGE** fourth?
- Call the grading stored procedure to check your work.

---

**Cell: `cell44`**

```sql
CALL common_db.resources.local_grader('OB11', '{{user}}');
```

---

## Test Your Knowledge :mag_right:

Check your understanding with interactive quiz questions below. Each `RUN_THIS_QUIZ_QUESTION_` cell has a Streamlit widget that presents a multiple‑choice question about Snowflake functionality.  

**Instructions:**  
1. Hover your cursor over the notebook cell to reveal additional controls.
1. Click the ▶️ **Play button** on the right side of each quiz cell to run it.  
1. Select your answer from the options provided.  
1. Review the feedback before moving on. 

💡 **Note:** You can expand the cell to view the code if you’re curious, but it’s not required. These quizzes aren’t mandatory — they’re here to challenge your knowledge transfer and give you a chance to practice.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_1`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_2`** — run in Snowflake notebook to answer the quiz question.

---

## Next Steps

If you have completed the lab steps and answered the **Knowledge Test** questions correctly, please proceed to the next Notebook when advised by your Snowflake instructor.