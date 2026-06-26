# LAB 3: DATABASE OBJECT HIERARCHY

👉 In this lab, we will review the use of Snowsight's Object Browsers to view and create objects, take a look at the `SHOW` command to access information on Snowflake objects and start querying data.

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

## Snowsight Object Browsers 📓 

Object Browsers in Snowsight help you locate and pick objects. "Objects" is a generic term for databases, schemas, tables, views, and much more! 

Read through the following examples to understand how to access and use these essential Snowsight components.

### 1. Object browser accessed from the databases area in the main left-side menu.

1. Click **Catalog** on the main left-side menu in Snowsight.
1. Select **Database Explorer**. This reveals the Object Browser (middle column in the image below).
1. Refresh this output when you have made object changes using the **refresh** option at the top (indicated with an orange arrow).
1. Click object names to reveal object details in the right panel and unfold nested objects in the Object Browser itself.

![Object browser from the main menu (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_object_browser_1_v2.png)

### 2. Accessing the object browser when working in a Snowflake notebook.

- Click the **Databases** tab link at the top of the column to the left of your notebook.

![Object browser access from notebooks (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_object_browser_2_v2.png)

- This reveals a convenient navigable Object Browser that you can use and access in parallel with your Snowflake Notebook.
- When hovering over object names in the Object Browser a dialog appears with a link you can use to open the object details page in a new tab/window.

![Object browser access from notebooks 2 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_object_browser_3_v2.png)

---

## Lab Exercise Step-by-Step 🥋

Use the Snowsight Object Browser to perform the following actions. 

1. Open Snowsight in a new web browser tab or window (leave this Snowflake Notebook open).

1. Ensure your role is set to `(animal)_LEARNER_RL` in the lower left corner.

1. Click on **Catalog** > **Database Explorer** in the main left-side menu.

1. Click the blue `+ Database` button, top-right, to open the **New Database** dialog.

1. Enter the name **(animal)_GARDEN_PLANTS** for the new database (where `animal` refers to the one assigned to you) and click the **Create** button.

### Use the object browser and object details pages to perform the following actions yourself. 🎯 

1. **Drop** the `PUBLIC` schema automatically created when you created your **(animal)_GARDEN_PLANTS** database. 

1. Use the blue `+ Schema` button, top right, to open the **New Schema** dialog. **Create** three new schemas in your **(animal)_GARDEN_PLANTS** database. Name them: 
    
    - **VEGGIES**
    
    - **FRUITS**
    
    - **FLOWERS**

💡 **Tip:** In database terminology, "Drop" means to remove/delete an entire database object (like a schema or table).

---

## How to Run Your Code 📓

Snowflake offers multiple utilities for interacting with the platform. We will make use of the Snowsight UI throughout this course. The Snowsight UI contains three primary interfaces:

- Workspaces

- Python worksheets

- Notebooks - they provide the ability to run both SQL and Python code in cells, and will be our main focus in this course.

---

### Try the following in the SQL cell below. 🥋

Type `SELECT 'hello'`

- Be sure to put the word **hello** in single quotes - this is a String to output to screen, whereas `SELECT` is a keyword-command.

- End your statement with a semi-colon - this defines the end of a statement for Snowflake to execute.

---

**Cell: `cell8`**

```sql
-- enter your code in this cell - rewrite the fragment below
-- once complete then hit the cell Run button (or cmd/Return) to execute the cell

replace 'this';
```

---

### Now try this in the SQL cell below. 🥋

Type `SELECT 'hello' AS Greeting` 

- Use `AS` to create a column name - this is a Snowflake keyword.

- Be sure to put the word **hello** in single quotes.

- Be sure to put the word **Greeting** in DOUBLE quotes - using double quotes preserves the case of the text assigned for the column name.

- End your statement with a semi-colon.

---

**Cell: `cell10`**

```sql
-- enter your code in this cell - rewrite the fragment below
-- once complete then hit the cell Run button (or cmd/Return) to execute the cell

GO 'ahead' REPLACE "this";
```

---

## Knowing What Will Run and What Has Run 📓 

In a notebook cell, whether Python or SQL, **ALL** statements listed in a cell will be run in a block when the cell is executed. This means the output displayed will relate to the final statement in the block if there are multiple statements unless there is some error.

The status of the cell run is indicated by the colors displayed by the cell. This status color is displayed in two places: the cell's left wall and the right cell navigation map.

**Cell status color**:

- **Blue dot** - Indicates a cell has been modified but hasn’t run yet.

- **Red** - An error has occurred.

- **Green** - Run was successful.

- **Moving green** - The cell is currently running.

- **Blinking gray** - The cell is waiting to be run. This status occurs when multiple cells are triggered to run.

**Note**: Markdown cells do not show any status.

---

## `SHOW` Commands

### Run the `SHOW DATABASES` command. 🥋 

Running a `SHOW DATABASES` command is just like being at the first level of an Object Browser (but with more details, and the ability to cut and paste the info into a spreadsheet).

Execute this command in the following SQL cell to see the databases your `(animal)_LEARNER_RL` role has access to:

---

**Cell: `cell13`**

```sql
USE ROLE {{user}}_learner_rl;
SHOW DATABASES;
```

---

### Run the `SHOW SCHEMAS` command. 🥋 

Running a `SHOW SCHEMAS` command is somewhat like being at the second level of an Object Browser. The difference is that the **context** in which you are set dictates which database you will get the SCHEMAS from. 

What are the names of the schemas listed as a result of running this SQL code?

---

**Cell: `cell15`**

```sql
USE DATABASE {{user}}_GARDEN_PLANTS;
SHOW SCHEMAS;
```

---

### Change the database context and run the `SHOW SCHEMAS` command again. 🥋 

Snowflake provides [sample data sets](https://docs.snowflake.com/en/user-guide/sample-data), such as the industry-standard TPC-DS and TPC-H benchmarks, for evaluating and testing a broad range of Snowflake’s SQL support. Sample data sets are provided in a database named SNOWFLAKE_SAMPLE_DATA, which has been shared with your account. We will make use of this in the following example.

Change your context to use this database:

---

**Cell: `cell17`**

```sql
USE DATABASE snowflake_sample_data;
```

---

### Run the `SHOW SCHEMAS` command again.

How many schemas does this sample database contain?

---

**Cell: `cell19`**

```sql
SHOW SCHEMAS;
```

---

### Run the `SHOW TABLES` command. 🥋 

We can use the `SHOW` command to explore objects further down the hierarchy. 

Let's take a look at the tables in one of the schemas in the `SNOWFLAKE_SAMPLE_DATA` database, `TPCH_SF1`.

---

**Cell: `cell21`**

```sql
USE SCHEMA snowflake_sample_data.tpch_sf1;
SHOW TABLES;
```

---

## Query Data in Snowflake 📓

Snowflake supports querying using standard `SELECT` statements. You can read more about the basic syntax [here](https://docs.snowflake.com/en/sql-reference/constructs).

You will have plenty of opportunities to write and understand SQL throughout this course.

---

### Run sample queries. 🥋

For now, review and run the following queries, which provide a taster of Snowflake's SQL capabilities across the sample data in the `TPCH_SF1` schema.

---

**Cell: `cell24`**

```sql
USE SCHEMA snowflake_sample_data.tpch_sf1;

-- retrieve all records from one of the smaller tables
SELECT * 
FROM NATION;
```

---

**Cell: `cell25`**

```sql
-- get a row count of the largest table
SELECT COUNT(*) 
FROM LINEITEM;
```

---

**Cell: `cell26`**

```sql
-- find the earliest and latest dates for orders placed
SELECT MIN(O_ORDERDATE),
       MAX(O_ORDERDATE) 
FROM ORDERS;
```

---

**Cell: `cell27`**

```sql
-- filter records in the SUPPLIER table using a WHERE clause
SELECT * 
FROM SUPPLIER
WHERE s_acctbal > 9995;
```

---

**Cell: `cell28`**

```sql
-- use GROUP BY to get a count of customers by their market segment 
SELECT c_mktsegment, 
       count(*)
FROM customer
GROUP BY c_mktsegment
ORDER BY c_mktsegment;
```

---

## Check Your Work So Far 🔎 

Use the Object Browser to make sure your `(animal)_LEARNER_RL` can see all the databases and schemas that have been created. These are listed below. You may need to refresh the Object Browser first. 

- (animal)_GARDEN_PLANTS
    - VEGGIES schema
    - FRUITS schema
    - FLOWERS schema
    
Also, make sure there is no `PUBLIC` schema in the `(animal)_GARDEN_PLANTS` database. You were supposed to delete that, remember?

You will encounter issues later if this is not fixed.

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