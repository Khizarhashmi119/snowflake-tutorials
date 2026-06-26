# LAB 6: THE LOAD WIZARD AND SNOWFLAKE MARKETPLACE

👉 In this lesson, we'll learn about loading files and the types of Snowflake objects that can make that process easier. We'll also get familiar with the Snowflake Marketplace, which is like an app store for data and data products.

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

## INSERT Statements Get Old Fast 📓 

### Vegetable_details table data.

Let's suppose that Business Analysts on our team decide to shorten the Rooting Depth column to a single letter and output to a Comma Separated Value (CSV) file. This change is fine as it stands, but there's trouble brewing... 
- Can you see the issue? 
- Why won't we be able to load this CSV? 
- How many commas are there in most rows? 
- How many commas are there in the row for Hot Peppers? 

![Vegetable_details table data (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_veg_details_table_1.png)

---

### Create a vegetable_details table. 🥋 

When working in a notebook cell, remember that we can explicitly specify our context with a `USE` statement: e.g. `USE SCHEMA db_name/schema_name`.

An alternative to this is to use **full object notation**. This means that we use the full path (or hierarchy) for an object each time we refer to an object in our SQL. It is more verbose, but it can help with clarity. The general structure of this naming convention follows the format: `<database_name>.<schema_name>.<object_name>`.

💡 **Hint**: If you do happen to create the table in the wrong database or schema, you can use an `ALTER TABLE - RENAME` statement to move it, or you can drop the table, update your drop menu context settings and recreate it.

---

**Cell: `cell6`**

```sql
-- Create a Vegetable_Details Table 

CREATE TABLE IF NOT EXISTS {{user}}_garden_plants.veggies.vegetable_details (
    plant_name VARCHAR(25),
    root_depth_code VARCHAR(1)
) 
DATA_RETENTION_TIME_IN_DAYS = 7;
```

---

## Load Table Rows from a File 

### Source the data. 

Two CSV (comma separated values) files named `veggie_details_a_to_k_comma_opt_enclosed.csv` and `veggie_details_k_to_z_pipe.csv` have been uploaded to the stage **COMMON_DB.RESOURCES.CLASS_FILES**. We want to load this data into the **VEGETABLE_DETAILS** table you created. 

### Download the first file. 🥋 

Run the following Python code cell and click on the link generated to download a file (Artichoke to Kale).

---

**Cell: `cell8`**

```python
import streamlit as st
snowpark_df = session.sql("SELECT GET_PRESIGNED_URL(@common_db.resources.course_files, 'veggie_details_a_to_k_comma_opt_enclosed.csv')")
collected_data = snowpark_df.collect()
st.write('Click the following link to download the file:')
st.write(collected_data[0][0])
```

---

### Load data dialog steps. 🥋 

1. Locate your **VEGETABLE_DETAILS** table in the Snowsight object browser.
1. Click the **Open Table details in new tab** icon to launch this screen in a new tab.

![Load Data dialog (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_open_table_details_1.png)

1. Click on the blue `Load Data` button, top right.
1. The following dialog will appear.
1. If you are prompted to use a warehouse, select your named warehouse - **(animal)_WH**.

![Load Data dialog (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_load_data_1.png)

1. Click the blue **Browse** button.
1. Locate the file you downloaded locally, named `veggie_details_a_to_k_comma_opt_enclosed.csv` and select it to open.
1. Then click the blue **Next** button in the lower right corner of the dialog.
1. An extended Load Data dialog appears.
1. We will accept many of the defaults chosen for our file, but click the dropdown arrow for **View options** in the **File format** box on the left side to adjust some options.

![Extended Load Data dialog (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_load_data_2.png)

1. Select "Skip first line" for **Header**.
1. Select "Double quotes (default)" for **Field optionally enclosed by**.
1. Click the blue **Load** button in the lower right corner of the dialog.

![Load Data file options (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_load_data_3.png)

1. All things going well, you should then see the following success dialog.
1. Click **View table details** and use the **Data Preview** option tab on the page that appears to review the data loaded into your table.

![Load Data success (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_load_data_success_1_v2.png)

---

### Recovering from mistakes when loading data. 📓

If you accidentally load the same file twice and want to start over, run a `TRUNCATE` command to empty the table. 

`TRUNCATE TABLE (animal)_GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS;`

Then, start the loading process over again.

---

## Load Table Rows from a File

### Download the second file. 🥋 

Run the following Python code cell and click on the link generated to download our second file (Kohlrabi to Zucchini).

---

**Cell: `cell12`**

```python
snowpark_df = session.sql("SELECT GET_PRESIGNED_URL(@common_db.resources.course_files, 'veggie_details_k_to_z_pipe.csv')")
collected_data = snowpark_df.collect()
st.write('Click the following link to download the file:')
st.write(collected_data[0][0])
```

---

## Challenge Lab: Load the File into the Table 🎯 

Load the file you downloaded into the same table using the same **Load Data** method you used. 

💡 **Note**: At least one setting under **View options** will be different when loading this file compared to the first. The columns are **NOT** separated by commas this time. In many cases, Snowflake is automatically able to detect the shape of files being loaded and respond with options to support correct loading. Is this the case with the load of your second file?

![Vegetable details table data (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_veg_details_csv_1.png)

💡 **TIP**: Don't use Excel to open CSV files if you want to see what characters are used to separate columns and rows. Use a simple text editor. On Windows, Notepad works well. On Mac, TextEdit works well. 

Once the file is loaded, check your table by running a `SELECT` statement and reviewing the output. You should see 42 rows. If you reverse the sort order (click the **PLANT_NAME** column header in the output table), you should be able to see Zucchini at the top, proving to yourself you loaded the second file.

---

**Cell: `cell14`**

```sql
SELECT * 
FROM {{user}}_garden_plants.veggies.vegetable_details;
```

---

## Viewing Our Table Data 🎯 

### View your vegetable_details table using SQL. 

This challenge lab does not include step-by-step details, only general guidance for achieving several goals.

1. View your data.
1. Isolate the records for "Spinach".
1. Notice a plant name that appears twice in the data set.
1. Find a way to get rid of it.
1. View your data again.

💡 **TIP**: **Replace** the hash characters (`#`) in the scaffolded queries below. Where you see one, your input is required. 

💡 **TIP**: If you are really stuck then **Expand** the clue cells under each of the "scaffolded" SQL statements by clicking **Code and results** from the **View display options** selector right next to the gray play button to the upper right of the cell. Be sure to try to figure it out first for yourself :grinning:.

---

### 1. View your data. 🎯

---

**Cell: `cell17`**

```sql
-- modify the following code and run to view all the table data after first setting your context (database and schema)
USE DATABASE ######_######_######;
USE ###### veggies;

SELECT #
FROM #########_details;
```

---

**Cell: `clue_for_cell17_expand_cell`**

```sql
/*
-- you could also hard code the following USE statement for your animal user instead of using the variable substitution
USE SCHEMA {{user}}_garden_plants.veggies;

SELECT *
FROM vegetable_details;
*/
```

---

### 2. Write a SQL query to return all rows where the **plant_name** is **Spinach**. 🎯 

We will make use of the [`UPPER()`](https://docs.snowflake.com/en/sql-reference/functions/upper) function. This means we don't have to concern ourselves with writing the test String we are checking for as `spinach`, or `Spinach`, or any other variation. Our input and the values stored in the column will be converted to `SPINACH`.

💡 **Hint**: we are surprised to see two Spinach rows!

---

**Cell: `cell20`**

```sql
SELECT *
FROM #########_#######
WHERE UPPER(plant_name) = UPPER('#######');
```

---

**Cell: `clue_for_cell20_expand_cell`**

```sql
/*
SELECT *
FROM vegetable_details
WHERE UPPER(plant_name) = UPPER('Spinach');
*/
```

---

### 3. One of the rows has an "S" for shallow roots, and the other has "D" for deep roots. 🎯 

We need to get rid of the row that says spinach roots are deep. First, let's isolate the "D" row.

---

**Cell: `cell23`**

```sql
SELECT *
FROM vegetable_details
WHERE UPPER(plant_name) = UPPER('#######')
AND root_depth_code = '#';
```

---

**Cell: `clue_for_cell23_expand_cell`**

```sql
/*
SELECT *
FROM vegetable_details
WHERE UPPER(plant_name) = UPPER('Spinach')
AND root_depth_code = 'D';
*/
```

---

### 4. Remove only the Spinach row with "D" in the ROOT_DEPTH_CODE column. 🎯

---

**Cell: `cell26`**

```sql
DELETE
FROM vegetable_details
WHERE UPPER(plant_name) = UPPER('#######')
AND root_depth_code = '#';
```

---

**Cell: `clue_for_cell26_expand_cell`**

```sql
/*
DELETE
FROM vegetable_details
WHERE UPPER(plant_name) = UPPER('Spinach')
AND root_depth_code = 'D';
*/
```

---

### 5. Look at all the data again and make sure there are no vegetable names that appear twice. 🎯

---

**Cell: `cell29`**

```sql
SELECT #
FROM #########_#######;
```

---

**Cell: `clue_for_cell29_expand_cell`**

```sql
/*
SELECT *
FROM vegetable_details;
*/
```

---

### A note on the file format object. 📓

In your work in this lab, you have used Snowsight's Load Data wizard to guide Snowflake in reading data from a file and inserting it into a table. As you saw, the dialog includes options to help Snowflake understand the "shape" of the data as it is in the source file and specify how the data in the file should be interpreted and processed. This includes the type (e.g. CSV), field delimiters, and whether it contains header lines that should be skipped.

These instructions can be bundled into a Snowflake object called a [FILE FORMAT](https://docs.snowflake.com/en/sql-reference/sql/create-file-format), referenced in the Load Data dialog, or when programmatically loading data into Snowflake via the [`COPY INTO`](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table) command. This saves time as you don't have to re-enter/re-code these instructions for repeated file loads with the same specifications.

---

## A Brief Introduction to Cloning 📓

Snowflake’s [zero-copy cloning](https://docs.snowflake.com/en/user-guide/object-clone) feature provides a convenient way to quickly take a “snapshot” of any table, schema, or database (and other objects) and create a derived copy of that object, which initially shares the underlying storage. This does not involve physically copying any underlying data but is an operation affecting metadata only. For this reason, it is generally very fast to clone tables, schemas, or even entire databases.

Clones are independent objects the moment they are created. You can perform the same operations on the cloned objects you perform on the source objects. For example, you can do anything to a table you cloned, including writing to it or changing parameters using the `ALTER TABLE` command.

Cloning can be extremely useful for creating instant backups without additional costs (until changes are made to the cloned object). This feature is often used in Snowflake for speedy provisioning of Dev and Test/QA environments and data backups.

---

### Clone a table. 🥋

You will create a new schema called **CLONED_OBJECTS** in the **(animal)_DB** database in the following. You will then `CLONE` the existing **VEGETABLE_DETAILS** table into this new schema with the name **VEGETABLE_DETAILS_CLONE**.

Execute the following code to perform these steps, and note the speed of this operation. Remember that cloning in Snowflake does not copy the table data, just the metadata (data about the data).

---

**Cell: `cell34`**

```sql
CREATE SCHEMA IF NOT EXISTS {{user}}_db.cloned_objects;

USE SCHEMA {{user}}_db.cloned_objects;

CREATE TABLE IF NOT EXISTS vegetable_details_clone
    CLONE {{user}}_garden_plants.veggies.vegetable_details;
```

---

### Review details about the cloned table.

Use the `SHOW` command to review the cloned table alongside the source table from which it originated. They are independent objects. Note, however, that they both share the same number of rows and bytes, although the storage will only be metered against the source table.

---

**Cell: `cell36`**

```sql
SHOW TABLES LIKE 'vegetable_details%' IN ACCOUNT;
```

---

### Query the cloned table.

Query the cloned table **VEGETABLE_DETAILS_CLONE** as we have done for the table from which it is sourced, **VEGETABLE_DETAILS**. This data should look familiar! This cloned object is just a standard Snowflake table, supporting all standard table operations despite the creation method.

---

**Cell: `cell38`**

```sql
SELECT * 
FROM vegetable_details_clone;
```

---

## Snowflake Marketplace 📓

### What is Snowflake Marketplace?

The Snowflake Marketplace is an integrated portal accessible within your Snowflake account. You can use the Snowflake Marketplace to discover and access third-party data and services and market your own data products across the Snowflake Data Cloud. As a consumer, you might use the data provided on the Snowflake Marketplace to explore and access the following:

- Historical data for research, forecasting, and machine learning.
- Up-to-date streaming data, such as current weather and traffic conditions.
- Specialized identity data for understanding subscribers and audience targets.
- New insights from unexpected sources of data. 

### What's easier than loading data into a table in Snowflake? Well, NOT LOADING at all!

Snowflake Marketplace enables you to search across a range of categories for data and data products meaningful to your business from a growing pool of global providers and leverage them within your account with the click of a button. There are hundreds of listings, including **Free/Unlimited Access** options. Provided you have the privileges to perform Marketplace transactions, the shared data can be available in your account within seconds and appear as a new database. It can be analyzed and utilized there, and even joined with your own data, to augment, enhance, and create new data products. No data loading required!

--- 

![Snowflake Marketplace (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_marketplace_v2.png)

---

### Navigate to the Snowflake Marketplace. 🥋 

1. On the main left-side menu select **Work with data** > **Marketplace**.
1. Use the Snowflake Marketplace search bar > type in "books" and hit Enter.
1. From the sub-menu that appears, select **Pricing** > **Free**.
1. Find the listing **AI Training Dataset from Goodreads Books**.
1. Click on the link and review the details provided for this data set, which includes a data dictionary specification and usage examples (SQL queries).

💡 **TIP**: Snowflake Marketplace listings require special privileges to acquire an account. Generally, this would be handled by a data or system administrator with access to elevated privilege roles in Snowflake.

---

## About Private Sharing with Data Exchange 📓

[Data Exchange](https://docs.snowflake.com/en/user-guide/data-exchange) provides a data hub for securely collaborating around data with a selected group of members that you invite. As a provider, it lets you publish data, which can then be discovered by the consumers participating in your exchange.

With Data Exchange, you can easily provide data to a specific group of consistent business partners taking part in the Data Exchange, such as internal departments in your company or vendors, suppliers, and partners external to your company. Suppose you want to share data with various consumers inside and outside your organization. In that case, you can also use listings offered to specific consumers or publicly on the Snowflake Marketplace.

---

### Work with Private Sharing. 🥋 

In addition to the "public" Snowflake Marketplace, it is also possible to share data and data products with a curated list of Snowflake accounts or even with users within an account. This feature is called a **Data Exchange**.

1. On the main left-side menu, select **Horizon Catalog** > **Data sharing** > **Private sharing** > **Shared With You**.
1. Review the listings shared with our account, many from Snowflake Education Services.
1. Click on the listing for **Alpine Peaks Publishing** and review.

We will write SQL queries against this data set in our Snowflake account to surface the top book recommendations for our favorite topic: **gardening**. There's always more to learn!!!

💡 **NOTE**: Snowflake Education Services has already acquired this private exchange data set in our account. You **DO NOT** need to click on the blue **Get** button or the **Get Access** link.

--- 

![Snowflake Data Exchange (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_pde_alpine_peaks_listing_1_v2.png)

- To make this shared data accessible to your role run the following SQL statement which will grant the appropriate permissions.

- Refresh your object browser and you should then see the `ALPINE_PEAKS_PUBLISHING` database appear.

---

**Cell: `cell43`**

```sql
CALL common_db.resources.access_alpine_peaks_publishing_data('{{user}}_learner_rl');
```

---

### Query private Data Exchange data. 🥋

The following description appears for the **Alpine Peaks Publishing** listing on the Data Exchange:

- _Alpine Peaks Publishing, a fictional book publisher, has unveiled its upcoming 2025 catalog to Snowflake Education. The collection features various titles across multiple genres, appealing to a wide audience. Showcasing the work of their acclaimed (but fictional) authors, this lineup promises to captivate readers with something for everyone._

Run the queries in the following SQL cells to explore this data set!

---

**Cell: `cell45`**

```sql
-- how many book reviews in this data set?
SELECT COUNT(*) 
FROM alpine_peaks_publishing.books.forthcoming_releases;
```

---

**Cell: `cell46`**

```sql
-- take a look at a subset of this data 
SELECT * 
FROM alpine_peaks_publishing.books.forthcoming_releases
LIMIT 10;
```

---

**Cell: `cell47`**

```sql
-- determine the number of unique categories in this data set 
SELECT DISTINCT category 
FROM alpine_peaks_publishing.books.forthcoming_releases
ORDER BY 1;
```

---

**Cell: `cell48`**

```sql
-- produce a count of the total number of books per category 
SELECT category, COUNT(*) 
FROM alpine_peaks_publishing.books.forthcoming_releases
GROUP BY category 
ORDER BY 2 DESC;
```

---

**Cell: `cell49`**

```sql
-- find books with 'garden' in their name
SELECT *
FROM alpine_peaks_publishing.books.forthcoming_releases
WHERE LOWER(title) LIKE '%garden%';
```

---

**Cell: `cell50`**

```sql
-- list the books from our favorite category 'gardening' and order them by the date they will become available in 2025
SELECT *
FROM alpine_peaks_publishing.books.forthcoming_releases
WHERE CONTAINS(LOWER(category),'garden')
ORDER BY release_date;
```

---

## Lesson 6 Wrap Up 🏁 

### Ready to finish lesson 6? 🏁 

- Does your **ROOT_DEPTH** table have 3 rows? 

- Does your **VEGETABLE_DETAILS** table have 41 rows?

- Are both tables in the **VEGGIES** schema of your **(animal)_GARDEN_PLANTS** database? 

If you answer YES to all of these, you should mark this lesson complete! If not, you should go back and fix anything that isn't right!

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

## Next Steps

If you have completed the lab steps and answered the **Knowledge Test** questions correctly, please proceed to the next Notebook when advised by your Snowflake instructor.