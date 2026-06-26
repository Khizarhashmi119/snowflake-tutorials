# LAB 4: TABLES, DATA TYPES AND LOADING DATA

👉 - In this lab, you will create a table to hold plant root depth values and write data into it using the `INSERT` statement. We will explore the use of `LIMIT` and the variations of `SELECT` star (*) to query data.

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

## Root Depth Table

### Based on the data in the image below, what should our table look like? 📓 

![Vegetable details table data (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_root_depth_1.png)

To read more about data types like `TEXT`, see Snowflake's online documentation [here](https://docs.snowflake.com/en/sql-reference/data-types-text#data-types-for-text-strings).

To read more about data types like `NUMBER`, see Snowflake's online documentation [here](https://docs.snowflake.com/en/sql-reference/data-types-numeric#number).

---

### Create your ROOT_DEPTH table. 🥋 

Review the code provided below to understand the "shape" of the table you are about to create.

Run the SQL cell. If everything goes well, you should receive the message, `Table ROOT_DEPTH successfully created. '

---

**Cell: `cell6`**

```sql
USE ROLE {{user}}_learner_rl;

CREATE TABLE IF NOT EXISTS {{user}}_GARDEN_PLANTS.VEGGIES.ROOT_DEPTH (
   ROOT_DEPTH_ID number(1), 
   ROOT_DEPTH_CODE text(1), 
   ROOT_DEPTH_NAME text(7), 
   UNIT_OF_MEASURE text(2),
   RANGE_MIN number(2),
   RANGE_MAX number(2)
   );
```

---

## Find the Table You Just Created in the Object Browser in the Notebooks Sidebar 🥋 

- Open the **Databases** Object Browser to the left of your notebook.

- Locate the **ROOT_DEPTH** table in the **VEGGIES** schema under the **(animal)_GARDEN_PLANTS** database.

- Click on the **Open Table details in new tab** icon (indicated) to launch this screen in a new tab window.

![Vegetable details table (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_locate_root_depth_1.png)

---

### What if you can't find it? 📓

- Refresh the Snowsight **Databases** object browser to the left of the notebook.

- Refresh the browser tab. 

- Check your role in Snowsight (bottom left). Is this the same role you created the table using the code above?

- Use the **Search objects** box at the top of the Snowsight **Databases** object browser to the notebook's left.

### What if you did something wrong? 📓 

- Did you name it wrong? Rename it!

- Does the wrong role own it? Transfer the ownership!

- Is it in the wrong database or schema? Move it!! 

For example:

- Use `ALTER TABLE` to change the name if you misspelled it.

- Use `ALTER TABLE` to MOVE the table if you put it in the wrong place.

💡 **TIP**: Use the example code below and amend, uncomment, and run, as necessary, to correct any issues.

💡 **HINT**: the `{{user}}` code will automatically write your animal username into the query, so you don't need to adjust this.

---

**Cell: `cell9`**

```sql
-- sample resolutions

-- ALTER TABLE {{user}}_garden_plants.veggies.rootdeath RENAME TO {{user}}_garden_plants.veggies.root_depth;

-- ALTER TABLE {{user}}_garden_plants.flowers.root_depth RENAME TO {{user}}_garden_plants.veggies.root_depth;
```

---

## View the Definition of Your Table 🥋 

Notice that the SQL code shown is **different** than the SQL code we ran. Snowflake made some changes behind the scenes!

- Can you spot the differences?

![ROOT_DEPTH table definition (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_view_root_depth_def_1_v2.png)

---

## Insert a Row of Data into Your New Table 

### Getting rows of data into a table. 📓

Now that you have a table, you'll want to put some data into it. There are many ways to get data into tables, but we'll start with the simplest and move through several options. Moving away from the simplest options, we will learn more efficient and effective data-loading methods. 

Before the end of this workshop, you will have experience loading data: 

- Using an `INSERT` statement from the Worksheet. 

- Using the Load Data Wizard.

- Using `COPY INTO` statements.

---

### Use the Data Preview option. 🥋  

Before you load a row of data into your table, first take note that currently, your table has zero rows. There are two ways we can quickly access this information:

**METHOD 1: Use Table Details**

1. Using the **Table Details** screen you opened in the example above, switch from the **Table Details** to the **Data Preview** tab.

1. If asked, then select a Warehouse you have access to. 

![Preview ROOT_DEPTH data 1 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_root_depth_zero_rows_1_v2.png)

**METHOD 2: Use the Object Browser**

1. Alternatively, find the table in the Object Browser under the Databases tab next to this notebook. 

1. Click the table name and an object details pane will appear below.

1. Click on the magnifying glass symbol to preview the data in the table (empty for this table now).

![Preview ROOT_DEPTH data 2 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_root_depth_zero_rows_2.png)

---

### Insert one row into your ROOT_DEPTH table using the insert statement below. 🥋 

1. Run the statement in the SQL cell below. 

1. **THEN** use one of the Data Preview methods above to view the row of data you just added.  

💡 **TIP**: you can set the context (database and schema) using code instead of entering the fully qualified name of an object each time you reference it.

---

**Cell: `cell14`**

```sql
USE SCHEMA {{user}}_GARDEN_PLANTS.VEGGIES;

INSERT INTO ROOT_DEPTH (
    ROOT_DEPTH_ID,
    ROOT_DEPTH_CODE,
    ROOT_DEPTH_NAME,
    UNIT_OF_MEASURE,
    RANGE_MIN,
    RANGE_MAX
)
VALUES (
    1,
    'S',
    'Shallow',
    'cm',
    30,
    45
);
```

---

## The Dreaded "Does Not Exist or Not Authorized" Error ❗ 

Sometimes, when running queries, you may see this message: **Table 'TABLE_NAME' does not exist or not authorized.**


It's not that hard to fix. You either change your role, change the context you are set in, or fully qualify the object name by adding its full location.

Sometimes, you need to change the ownership on something so it shows up. Sometimes, you have to rename or move it. Ask yourself "Where am I looking for this thing? Is that where it is? Is that what it's named?" and "Who is looking for it? Does that role have access to it?"

To fix the issue you can either:

1. Reset your context (consider issuing a `USE DATABASE` or `USE SCHEMA` command).

1. Use the long (full) name when referring to objects. E.g. `(animal)_GARDEN_PLANTS.VEGGIES.ROOT_DEPTH` _(database.schema.table)_.

---

## Select Stars and Limits 📓

A Select Star statement starts with "`SELECT *`" (which is technically an asterisk). "Select Asterisk" takes longer to say. A Select Star is a way to ask for all columns in the table without listing them one by one.

---

### How to run a select star on your new table. 🥋

See if you can modify the sample code in the following SQL cell to write a query to select all records from your new `ROOT_DEPTH` table.

- Replace the hash (`#`) characters in the following statement with the appropriate syntax.

---

**Cell: `cell18`**

```sql
-- USE SCHEMA {{user}}_GARDEN_PLANTS.VEGGIES;

-- modify this sample code
SELECT * FROM ROOT_DEPTH;
```

---

### Select star variations. 📓

When working with Select star, Snowflake offers some convenient SQL features - options to help you minimize the typing required and still tailor the output, which is super helpful when working with tables, table functions, and views with many columns. It's no fun manually typing out tens or hundreds of column names for a query. There are better things to do with your time!

When you specify `SELECT *`, you can include the following options: `EXCLUDE`, `REPLACE`, `RENAME`, and `ILIKE`.

- `EXCLUDE`: will return all columns, except those specified for exclusion.
- `REPLACE`: will return all columns and replace the value of the named column(s) with the value of an evaluated expression.
- `RENAME`:  will return all columns, and specifies the column aliases that should be used in the results.
- `ILIKE`:   will return all columns that match the specified pattern.

---

### Try the examples below on your new table to tailor the column output with these shorthand variations.

---

**Cell: `cell21`**

```sql
-- return all columns from your table, except those in the exclusion list, using EXCLUDE

SELECT * EXCLUDE (range_min, range_max)
FROM ROOT_DEPTH;
```

---

**Cell: `cell22`**

```sql
-- return all columns from your table, and append the String '-RDC' to the values in the root_depth_code column, using REPLACE

SELECT * REPLACE (root_depth_code||'-RDC' AS root_depth_code)
FROM ROOT_DEPTH;
```

---

**Cell: `cell23`**

```sql
-- return all columns from your table, and change the title/header for the range columns, using RENAME

SELECT * RENAME (range_min AS root_depth_range_min, 
                 range_max AS root_depth_range_max)
FROM ROOT_DEPTH;
```

---

**Cell: `cell24`**

```sql
-- return all columns from your table that contain the string `ROOT`, using ILIKE

SELECT * ILIKE '%ROOT%'
FROM ROOT_DEPTH;
```

---

### Learning about select stars & limits. 📓  

If you want all columns but not all rows, you can run a Select Star with a `LIMIT`. Limits make sure that you get just a small set of rows. That way, if there are millions of rows, you won't waste compute power, getting all of them, if all you want to see are a few.   

Of course, our table only has one row right now, but later it will have more rows, and later we'll have other tables we create that we load with many more.

---

**Cell: `cell26`**

```sql
SELECT *
FROM ROOT_DEPTH
LIMIT 1;
```

---

## Lesson 4 Challenge Exercise 🎯 

### Add two more rows to the ROOT_DEPTH table. 🎯 

Edit the original `INSERT` statement you used earlier in the following SQL cells, and run them both to add two rows to your **ROOT_DEPTH** table. 

- Replace the hash (`#`) characters with the values you can see in the image below for those rows.

![ROOT_DEPTH add rows (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_root_depth_add_rows_1.png)

---

**Cell: `cell28`**

```sql
-- Edit the values (replace the # characters) in the cell to match those in the SECOND row of the image above, then run 

INSERT INTO ROOT_DEPTH (
    ROOT_DEPTH_ID,
    ROOT_DEPTH_CODE,
    ROOT_DEPTH_NAME,
    UNIT_OF_MEASURE,
    RANGE_MIN,
    RANGE_MAX
)
VALUES (
    2,
    'S',
    'Shallow',
    'cm',
    45,
    60
);
```

---

**Cell: `cell29`**

```sql
-- Edit the values (replace the # characters) in the cell to match those in the THIRD row of the image above, then run

INSERT INTO ROOT_DEPTH (
    ROOT_DEPTH_ID,
    ROOT_DEPTH_CODE,
    ROOT_DEPTH_NAME,
    UNIT_OF_MEASURE,
    RANGE_MIN,
    RANGE_MAX
)
VALUES (
    3,
    'M',
    'Medium',
    'cm',
    60,
    90
);
```

---

### Review results. 🥋

- Run `SELECT *` to view all three rows of your **ROOT_DEPTH** table. 

- Compare your results with the image shown above.

---

**Cell: `cell31`**

```sql
SELECT *
FROM ROOT_DEPTH;
```

---

## New to SQL? Need Some Help? Check out the Code Samples Below 📓

These are just examples to show you how to perform certain actions using SQL. Please do not run this code without editing it to fit your needs.

### Example one - add more than one row at a time.

    INSERT INTO root_depth (
    
        root_depth_id, root_depth_code, root_depth_name, unit_of_measure, range_min, range_max)  

    VALUES
    
        (5,'X','short','in',66,77),
    
        (8,'Y','tall','cm',98,99);

    
### Example two - remove a row you do not want in the table.

    DELETE FROM root_depth

    WHERE root_depth_id = 9;

### Example three - change a value in a column for one particular row.

    UPDATE root_depth

        SET root_depth_id = 7

    WHERE root_depth_id = 9;

### Example four - remove all the rows from the table to start over.

    TRUNCATE TABLE root_depth;

---

## Lab 4 Review 🏁 

### Are you ready for lab 5?

- Does the **(animal)_GARDEN_PLANTS** database have 4 Schemas? 

- Does the **VEGGIES** Schema have a single table called **ROOT_DEPTH** with 3 rows in it? 

If you answer **YES** to all of these, you should proceed. If not, you should go back and fix anything that isn't right!

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

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_3`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_4`** — run in Snowflake notebook to answer the quiz question.

---

## Next Steps

If you have completed the lab steps and answered the **Knowledge Test** questions correctly, please proceed to the next Notebook when advised by your Snowflake instructor.