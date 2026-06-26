# LAB 2: IDENTITY AND ACCESS

👉 In this lesson, we'll learn how to create databases and administer access to objects such as databases, schemas, and tables using code. We'll also show comparable options for Snowsight (Snowflake's web UI).

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
print(f'Your db is {your_db}')
```

---

## Create a New Database 📓

In this lab you will create a new database. The steps are listed below, but first, please read this important note about your lab permissions.

💡 **A Note on Your Role: `(animal)_LEARNER_RL`.**

- For all the exercises in this lab, you will use a special role called `(animal)_LEARNER_RL`.
- This role has already been set as your default, so you don't need to select it or change anything. We are just letting you know what it is called in case you see it referenced.
- This role was pre-created by the Education Services team with the exact privileges you need for the lab exercises.

---

---

### Determine your new database name. 

Name the database according to the animal username you have been assigned for this class. Run the Python code block in the cell below to confirm this name.
- You don't have to understand the details of what this is doing for now. 
- Just go ahead, run the code, and note the output.

---

**Cell: `cell6`**

```python
print('Use this name for your new database: ' + your_db)
```

---

### Create the new database using SQL code. 🥋

To create your new database, execute the following SQL code, which includes the name highlighted in the previous cell. 

👉 The `IF NOT EXISTS` clause is an option you can add when [creating databases](https://docs.snowflake.com/en/sql-reference/sql/create-database#syntax) (and other objects). Think of it as telling Snowflake:

* "If a database with this name **doesn't** exist, create it."
* "If it **already** exists, just do nothing and don't stop my script with an error."

---

**Cell: `cell8`**

```sql
USE ROLE {{user}}_LEARNER_RL;

CREATE DATABASE IF NOT EXISTS {{your_db}};
```

---

### Create a database using Snowsight.

Alternatively, it is possible to create databases and other objects using Snowflake's UI, Snowsight. 

- Expand the following **OPTIONAL** cell and review the details to learn more about this approach, if you are interested.

:information_source: There is no requirement to go through the steps in the following cell; they are provided only as an alternative for your information.

---

### Create the new database using Snowsight. 🥋

1. Ensure you are set to `(animal)_LEARNER_RL` in the role selector, bottom left (where **animal** is your assigned username).

1. Click the blue **+ Database** button, top right.

1. Enter the name for your database in the **Name** field in the dialog box (leave Comment empty). Use the name provided a few cells above this one.

1. Click the **Create** button.

![Create Databases path (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_create_database_dialog_1_v2.png)

---

### Run code to confirm the database has been created. 🥋

We can run SQL commands to confirm that your database object has been created. Try out the `SHOW` command. This is useful for viewing general information about objects in your Snowflake environment.

:flashlight:  We saved the name of your database in a Python variable earlier. We can use this in cells in our notebook by referencing it inside two sets of squiggly brackets {{}}. Snowflake will replace this placeholder with the saved value before running the command in the cell.

---

**Cell: `cell12`**

```sql
-- SHOW DATABASES;
SHOW DATABASES LIKE '%{{your_db}}%';
```

---

### Review the new database in the Object Browser.

Alternatively, you can review newly created objects, such as a database, using Snowflake's UI, Snowsight. 

- Expand the following **OPTIONAL** cell and review the details to learn more about this approach, if you are interested.

:information_source: There is no requirement to go through the steps in the following cell; they are provided only as an alternative for your information.

---

### Review objects in the Object Browser.

1. Hover over the Catalog icon to the left of your Notebook, in the main menu.

1. Right-click on the **Database Explorer** link under **Catalog** in the dialog that appears 

1. Select your preferred target from the options that appear - a "New Tab" or a "New Window" - to open the Snowsight Object Browser in a new browser tab or window.

    - Taking this action means we leave this Snowflake Notebook page uninterrupted and can switch back to its instructions easily.

1. Ensure you are set to `(animal)_LEARNER_RL` in the role selector, bottom left (where animal is your assigned username).

![Open Databases page (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_open_databases_page_1_v2.png)

---

:eyes: :point_right: Your new database should appear under the Object Browser and as a line item under the Databases listing page to the right of the middle column.

![Databases listing page (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_databases_listing_page_1_v2.png)

#### Switch your role to `(animal)_CREATE_DB_RL`. 🥋

1. Using the **Databases** page you opened in a new window or tab, locate the role selector in the bottom-left of the Snowsight interface.

1. Change the currently selected role from `(animal)_LEARNER_RL` to `(animal)_CREATE_DB_RL`.

You may need to refresh the Object Browser (circular arrow at top) or even the web browser tab to see the role change effects.

:eyes: :point_right:  Your new database should **DISAPPEAR** from view in the Object Browser and Database listing panes.

	
:information_source: Note that the role `(animal)_CREATE_DB_RL` does **not** have permissions to access the new database you created. 

![Databases listing page 2 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_databases_listing_page_2_v2.png)

#### Switch your role back to `(animal)_LEARNER_RL`.

1. Locate the role selector in the bottom-left of the Snowsight interface.

1. Change the currently selected role from `(animal)_CREATE_DB_RL` to `(animal)_LEARNER_RL`.

You may need to refresh the Object Browser (circular arrow at top) or even the web browser tab to see the role change effects.

:eyes: :point_right: Your new database should **REAPPEAR** in the Object Browser and Database listing panes.

![Databases listing page (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_databases_listing_page_1_v2.png)

---

## Explore Your Database 🥋

### Run code to display additional information about the new database created.

In addition to the `SHOW` command we tried earlier, we can run a `DESCRIBE` command against the new database to get a readout on the schemas it contains. Try this with the following:

---

**Cell: `cell16`**

```sql
USE ROLE {{user}}_LEARNER_RL;

-- This will provide you with a list of schemas (automatically created for you!) inside your new database.
DESCRIBE DATABASE {{your_db}};
-- DESC DATABASE {{your_db}};
```

---

## Databases and Schemas 📓

Databases group datasets (tables and other objects) together. A second-level organizational grouping within a database is called a **schema**. Every time you create a database, Snowflake will **automatically** create two schemas for you.

1. The `INFORMATION_SCHEMA` schema holds a collection of views. The `INFORMATION_SCHEMA` schema cannot be deleted (dropped), renamed, or moved.

1. The `PUBLIC` schema is created empty, and you can populate it with tables, views, and other objects over time. The `PUBLIC` schema can be dropped, renamed, or moved anytime.

---

### Run code to display information about schemas in the new database created.

The `SHOW` command can also be used to view general information about the schemas contained within databases in Snowflake. Try it with the following:

---

**Cell: `cell19`**

```sql
SHOW SCHEMAS IN DATABASE {{your_db}};
```

---

### Explore the database using Snowsight. 🥋

Alternatively, you can review newly created objects, such as schemas, using Snowflake's UI, Snowsight. 

- Expand the following **OPTIONAL** cell and review the details to learn more about this approach, if you are interested.

:information_source: There is no requirement to go through the steps in the following cell; they are provided only as an alternative for your information.

---

### Explore the database you created using Snowflake's UI, Snowsight.

1. Hover over the Catalog icon to the left of your Notebook, in the main menu.

1. Right-click on the **Database Explorer** link under **Catalog** in the dialog that appears 

1. Select your preferred target from the options that appear - a "New Tab" or a "New Window" - to open the Snowsight Object Browser in a new browser tab or window.

    - Taking this action means we leave this Snowflake Notebook page uninterrupted and can switch back to its instructions easily.

1. Ensure you are set to `(animal)_LEARNER_RL` in the role selector, bottom left (where animal is your assigned username).

![Open Databases page (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_open_databases_page_1_v2.png)

---

1. Using the Database Explorer page click on your new database name in the middle column.

1. :eyes: :point_right: A list of schemas for your new database unfolds, and related information for both **Database Details** and **Schemas** can be accessed in the right panel.

1. Note also that when we select a database in the Object Browser, a blue `+ Schema` schema-creation button appears at the top right.

![Databases listing page 3(image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_databases_listing_page_3_v2.png)

---

## How Does Changing Your Role Affect What Databases You Can See? 📓 

We noted this behavior earlier in the lab:

- when you change your role...you change what you can **SEE** and **DO** with databases, schemas, tables, views, and more! 

This is easily observable with a couple of code examples in which we will explicitly switch roles.

---

### Switch roles.

- Notice that for some roles, not all databases are visible as they have **not** been granted specific permission to access these objects.

- When using Snowflake, sometimes objects might seem to disappear. You may see a **" Does Not Exist error"** when you know the item has been created. In those instances, you should begin by checking your role!!


Try this out below.

- Switch your role to `(animal)_CREATE_DB_RL` and observe the list of databases it has access to by executing the `SHOW` command.

---

**Cell: `cell24`**

```sql
USE ROLE {{user}}_CREATE_DB_RL;

SHOW DATABASES;
```

---

### Switch roles once more.

This time we will revert to the `(animal)_LEARNER_RL` role used throughout this lab. 

Try this out below and observe the list of databases this has access to. Can it "see" more or less?

---

**Cell: `cell26`**

```sql
USE ROLE {{user}}_LEARNER_RL;

SHOW DATABASES;
```

---

## Challenge Exercise 🎯 

### Create a New Database 🎯 

Create a new database named **(animal)_**`UTIL_DB`. This database should be owned by `(animal)_LEARNER_RL`. 

1. Verify your selected role is `(animal)_LEARNER_RL`.

1. Add the missing SQL keyword at the start of the code in the cell below (hint: refer to the example earlier in this lab for clues).

1. Run the SQL code in the cell below to create the new database.

**HINT**: 

- If you set your role to `(animal)_LEARNER_RL` before you create the database, it will automatically be owned by this role. You won't have to do any transfers of ownership! 

- If you forget to set your role to `(animal)_LEARNER_RL` before creating the database, you will need to transfer ownership to it.

---

**Cell: `cell28`**

```sql
USE ROLE {{user}}_LEARNER_RL;

CREATE DATABASE IF NOT EXISTS {{user}}_UTIL_DB;
```

---

### Check your work. 🎯 

The following three named databases (and perhaps more if you are running this lab more than once), each prefixed with your unique animal username, should be accessible by `(animal)_LEARNER_RL`:

- (animal)**_DB**

- (animal)**_RESOURCES_DB**

- (animal)**_UTIL_DB**

You can review the listings in the Databases page in Snowsight, as you have done previously, or you could run a SQL query to confirm. Try it out in the following cell:

---

**Cell: `cell30`**

```sql
USE ROLE {{user}}_learner_rl;

SHOW databases like '{{user}}%';
```

---

### Challenge exercise review.

- What databases do you see? You may need to refresh the list.

- Are your two newly created databases listed?

If not, review the earlier steps in this lesson and see if you can correct the issue.

When you have confirmed your databases, the task is complete, and you can proceed.

---

## Challenge Exercise 🎯 

In Snowflake, roles don't need to own objects to view or interact with them. Permission to perform certain actions with objects can also be delegated to roles using the `GRANT` command. The Snowsight interface provides options to perform actions to change access to objects. 

Take a look at the following Snowsight screen: 

![Grant privileges (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_grant_privileges_1_v2.png)

The following explanation will help you understand how to perform these steps yourself shortly.

- Selecting a schema in the Object Browser reveals the Schema details panel to the right.

- Note the `+ Privilege` button - click this to launch the **Grant new privileges on** dialog.

- The **Role** dropdown is the name of the role you would like to give (grant) permissions on the schema to. When you click into this, a **Search roles** option appears - use this to locate your role.

- The **Privileges** dropdown contains a list of Snowflake permissions across a wide range of objects.

- **USAGE** provides basic access to view and interact with a schema.

---

### Use your knowledge to perform the following actions.

### Grant `USAGE` on a schema to a role.

- Work as the `(animal)_LEARNER_RL`.
- Use Snowsight to grant `USAGE` on the schema **(animal)_DB.PUBLIC**.
- Grant this to the role `(animal)_CREATE_DB_RL`.

### Grant `USAGE` on a database to a role.

- Work as the `(animal)_LEARNER_RL`. 
- Use Snowsight to grant `USAGE` on the database **(animal)_DB**. 
- Grant this to the role `(animal)_CREATE_DB_RL`.

---

### Challenge exercise review.

- When working as the role `(animal)_CREATE_DB_RL`, can you see both the **(animal)_DB** database and its **PUBLIC** schema in the Snowsight Object Browser?

If not, then review the earlier steps in this lesson and see if you can correct the issue.

When you have confirmed, the task is complete, and you can proceed.

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