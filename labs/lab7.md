# LAB 7: CHECK YOUR CODE

## Preparing for Code Checks

To begin, let's grab **context information** we will use throughout this lab. 

- Click the **Start** button to activate this notebook.

- Run the following Python cell.

---

#### :warning: Each time a new session is started for this notebook, you need to rerun the cell below to configure "variables" for use in later cells. :warning:

---

**Cell: `cell3`**

```python
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

### Using the INFORMATION_SCHEMA to query metadata. 🥋

The word "metadata" means "data about data." 

The `INFORMATION_SCHEMA` created in every Snowflake Database holds metadata. In other words, it holds statistics about the number of databases, schemas, tables, views, and more. It also holds data about the object names and other object details. 

We can use the `INFORMATION_SCHEMA` to double-check our work and ensure we completed the tasks correctly. 

Let's get a readout of all the schemas present in the **(animal)_GARDEN_PLANTS** database you have been working with by querying its `INFORMATION_SCHEMA`.

---

**Cell: `cell5`**

```sql
SELECT * 
FROM {{user}}_garden_plants.information_schema.schemata;
```

---

### Using code to check your work. 🥋 

You were asked to set up 3 schemas in your **(animal)_GARDEN_PLANTS** database. You were also asked to delete a schema. Let's run some code to check if those tasks have been completed.

💡 **TIP**: The code in the following check makes use of [CTE (common table expression)](https://docs.snowflake.com/en/user-guide/queries-cte) structures. You can think of a CTE as a "temporary view" that can be used in a statement. CTEs are particularly useful for breaking down complex SQL statements, making them more readable and easier to manage. By organizing logic into distinct, reusable parts, CTEs simplify the query structure, improve clarity, and enhance maintainability.

---

**Cell: `cell7`**

```sql
WITH schema_check_1 AS (
    -- do the following three schemas exist?
    SELECT COUNT(*) AS count_1
    FROM {{user}}_garden_plants.information_schema.schemata
    WHERE schema_name IN ('FLOWERS','VEGGIES','FRUITS')
),
schema_check_2 AS (   
    -- the following schema SHOULD NOT exist (count of zero)
    SELECT COUNT(*) AS count_2
    FROM {{user}}_garden_plants.information_schema.schemata
    WHERE schema_name = ('PUBLIC')
) 
SELECT IFF((count_1=3) AND (count_2=0),'\u2705 Correct','\u26D4 Incorrect. Please review and try again') AS schema_check
from schema_check_1, schema_check_2;
```

---

## How Many Schemas Does Your `(animal)_GARDEN_PLANTS` Database Have 

### What did I do wrong? 📓 

Did you run the query above only to find a failure reported? Here are some potential mistakes:

- You have a typo in the schema name, like "WEGGIES" instead of "VEGGIES".

- You put the schemas in the wrong database, like UTIL_DB, instead of (user)_GARDEN_PLANTS.

- You don't have your role set so that you can see the objects, as you created them using `(animal)_LEARNER_RL`, but your worksheet is set to `PUBLIC`. 

---

### How can I fix things? 📓 

**Typo**: `ALTER SCHEMA (animal)_GARDEN_PLANTS.WEGGIES RENAME TO (animal)_GARDEN_PLANTS.VEGGIES;`

**Wrong Place**: `ALTER SCHEMA DEMO_DB.VEGGIES RENAME TO (animal)_GARDEN_PLANTS.VEGGIES;`

**Cannot Find**: Change the Role Setting on your worksheet or transfer the ownership of your object.

---

### Checking for schemas by name. 🥋 

Now let's check to see if the schemas you created have the correct names. You might have named your schemas differently if this code doesn't return **3** rows.

---

**Cell: `cell10`**

```sql
SELECT schema_name 
FROM {{user}}_GARDEN_PLANTS.INFORMATION_SCHEMA.SCHEMATA
WHERE schema_name IN ('FLOWERS','FRUITS','VEGGIES');
```

---

## Check Your Work 🔎

### :mag_right: Check 1 (OB01). 🔎

- Have you created 3 Garden Plant database schemas (**FLOWERS**, **VEGGIES**, **FRUITS**)?
- Call the grading stored procedure to check your work.

---

**Cell: `cell12`**

```sql
CALL common_db.resources.local_grader('OB01', '{{user}}');
```

---

### :mag_right: Check 2 (OB02). 🔎

- Have you deleted (dropped) the Garden Plant database schema named **PUBLIC**?
- Call the grading stored procedure to check your work.

---

**Cell: `cell14`**

```sql
CALL common_db.resources.local_grader('OB02', '{{user}}');
```

---

### :mag_right: Check 3 (OB03). 🔎

- Have you created the **ROOT_DEPTH** table in the **VEGGIES** schema of your Garden Plant database?
- Call the grading stored procedure to check your work.

---

**Cell: `cell16`**

```sql
CALL common_db.resources.local_grader('OB03', '{{user}}');
```

---

### Use Query History to review your test results. 📓

Snowflake retains a record of queries and statements executed in the system, known as Query History, and provides UI and programmatic ways to access this. Query History provides a convenient place to see queries you (or others, if you have the privileges) have run over time.

We can access Query History from a cell in a Snowflake Notebook.

---

### Access Query History from a Snowflake notebook SQL cell. 🥋

1. Hover over the query execution time readout in the **Check 3** SQL cell that you just ran.
1. You will see the message **View run details** appear.
1. Click on the query execution time readout and a dialog box appears.
1. Click on the blue **ID** field UUID, which contains a link to the Snowsight Query History page.
1. This will launch the Snowsight Query History page in a new browser window.

![Access query history (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_query_history_1_v2.png)

1. This will open into the **Query Profile** screen, where you can review the execution steps for your query.
1. Click on the **Query Details** tab at the top of the screen.
1. Review the various details related to the query execution.
1. Check the **Results** section at the bottom of the page. 

![Query details (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_query_details_1_v2.png)

:warning: **DO NOT PROCEED** past this point unless you see a green check ✅ in the in the Results section of Query Details (Query History) for Check 3. :warning:

---

### Access Query History programmatically. 🥋

We can also retrieve Query History information using code, with options available for both Python and SQL. 

`INFORMATION_SCHEMA` contains a collection of [table functions](https://docs.snowflake.com/en/sql-reference/functions/query_history) that can be used to query Snowflake query history along various dimensions. In the following example, we will use `QUERY_HISTORY_BY_USER()` to return queries submitted by a specified user (you!) within the last seven days. 

We will identify the `DELETE` operation you ran in **Lab 6: The Load Wizard and Snowflake Marketplace** that removed a single row from the **VEGETABLE_DETAILS** table (...plant_name = 'Spinach' AND root_depth_code = 'D').

---

**Cell: `cell20`**

```sql
SELECT *
FROM TABLE(information_schema.query_history_by_user(
    USER_NAME => '{{user}}',
    RESULT_LIMIT => 10000
))
WHERE query_type = 'DELETE'
AND execution_status = 'SUCCESS'
ORDER BY end_time DESC
LIMIT 1;
```

---

Let's save the Query ID for this operation into a SQL variable that we will make use of later in this lab.

**:warning: `INFORMATION_SCHEMA.QUERY_HISTORY_BY_USER` and its variations only retain data for seven days. If you run the query above outside of this window then no results will be returned. You will need to complete the steps in Lab 6 again.  :warning:**

---

**Cell: `cell22`**

```sql
SET delete_query_id = (
    SELECT query_id
    FROM TABLE(information_schema.query_history_by_user(
        USER_NAME => '{{user}}',
        RESULT_LIMIT => 10000
    ))
    WHERE query_type = 'DELETE'
    AND execution_status = 'SUCCESS'
    ORDER BY end_time DESC
    LIMIT 1
);

SELECT $delete_query_id;
```

---

### :mag_right: Check 4 (OB04). 🔎

- Does your database **(animal)_UTIL_DB** contain 2 (and only 2) schemas?
- Call the grading stored procedure to check your work.

---

**Cell: `cell24`**

```sql
CALL common_db.resources.local_grader('OB04', '{{user}}');
```

---

### :mag_right: Check 5 (OB05). 🔎

- Have you created the **VEGETABLE_DETAILS** table in the **VEGGIES** schema of the Garden Plant database?
- Call the grading stored procedure to check your work.

---

**Cell: `cell26`**

```sql
CALL common_db.resources.local_grader('OB05', '{{user}}');
```

---

### :mag_right: Check 6 (OB06). 🔎

- Does your **ROOT_DEPTH** table contain **3** rows?
- Call the grading stored procedure to check your work.

---

**Cell: `cell28`**

```sql
CALL common_db.resources.local_grader('OB06', '{{user}}');
```

---

### :mag_right: Check 7 (OB07). 🔎

- Does your **VEGETABLE_DETAILS** table contain **41** rows?
- Call the grading stored procedure to check your work.

---

**Cell: `cell30`**

```sql
CALL common_db.resources.local_grader('OB07', '{{user}}');
```

---

## Time Travel 📓

Snowflake Time Travel enables accessing historical data (i.e., data that has been changed or deleted) at any point within a defined period. To support Time Travel, a number of [SQL extensions](https://docs.snowflake.com/en/user-guide/data-time-travel#time-travel-sql-extensions) are available.

When data in a table is modified, including deletion of data or dropping an object containing data, Snowflake preserves the state of the data before the update. A parameter called `DATA_RETENTION_TIME_IN_DAYS` specifies the number of days for which this historical data is preserved and, therefore, Time Travel operations (`SELECT`, `CREATE` … `CLONE`, `UNDROP`) can be performed on the data.

---

### View a historical version of the **VEGETABLE_DETAILS** table. 🥋

When the **VEGETABLE_DETAILS** table was created early in **Lab 6: The Load Wizard and Snowflake Marketplace**, it was configured with seven days of data retention. This means any changes made to the table are retained for a seven-day window. This allows us to navigate back in time to view the data associated with the table at a particular point, whether chronological or before a specific operation executed against the table.

In **Lab 6**, you then deleted a second Spinach row from the **VEGETABLE_DETAILS** table. Earlier in this lab we identified the Query ID associated with that operation and saved it in a local variable: `$delete_query_id`. We can use Time Travel to view the data before this operation. 

Run the following code to view and label the Spinach rows before the `DELETE` **unioned** with the Spinach data from the current version of the table. Note the [special syntax](https://docs.snowflake.com/en/user-guide/data-time-travel#querying-historical-data) used to query historical data using Time Travel: `BEFORE( STATEMENT => $delete_query_id )`

---

**Cell: `cell33`**

```sql
-- Time Travel query 
SELECT plant_name, root_depth_code, 'HISTORICAL (Time Travel)' as table_version 
FROM {{user}}_garden_plants.veggies.vegetable_details
BEFORE( STATEMENT => $delete_query_id )
WHERE plant_name = 'Spinach'

UNION

-- current version query
SELECT plant_name, root_depth_code, 'CURRENT' as table_version
FROM {{user}}_garden_plants.veggies.vegetable_details
WHERE plant_name = 'Spinach';
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

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_3`** — run in Snowflake notebook to answer the quiz question.

---

## Next Steps

If your grading checks (1-7) have passed, and you have answered the **Knowledge Test** questions correctly, then please proceed to the next Notebook when advised by your Snowflake instructor.