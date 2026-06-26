# LAB 9: UNSTRUCTURED DATA AND CORTEX LLM FUNCTIONS

👉 In this lesson we'll review PDF documents that have been supplied, and make use of a Snowflake Cortex function to parse these documents, and write the information to a table. A second Cortex function will be employed to label (or classify) the rows of data in the table. We will construct an analytical query and the visualize this using Streamlit to show the breakdown of information across categories. And, finally we will take a quick tour through the capabilities of three other Cortex functions. 

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
session.use_database(f'{user}_GARDEN_PLANTS')
session.use_schema('VEGGIES')
print('Your current CONTEXT information:')
print('---------------------------------')
print(session)
print('Your current USER is ' + user)
```

---

## Work with Unstructured Data in Snowflake 📓

In previous sections of this course, we examined both structured data (think rows and columns) and semi-structured data (think JSON format). Snowflake also includes features and functions for working with [**unstructured data**](https://docs.snowflake.com/en/user-guide/unstructured-intro), which analysts estimate now makes up around 80% of the world's data.

So, what is it exactly?

**Unstructured data** is information that does not fit into a predefined data model or schema. Typically text-heavy, such as form responses and social media conversations, unstructured data also encompasses images, video, and audio. Industry-specific file types such as VCF (genomics), KDF (semiconductors), or HDF5 (aeronautics) are included in this category.

The Snowflake AI Data Cloud can help access, share, and process **unstructured data** files.

---

## An Unstructured Data Scenario 📓

Just imagine for a moment that over time you have collected dozens of interesting facts and details about the plants you enjoy tending and exported these "snippets" of information as PDF files on your laptop. Wouldn't it be great to find a way to bring that data into Snowflake to use it alongside the information you have already built out?

This is precisely the scenario we will work through in the exercises in this lab. You will:
1. Parse the information from staged PDF files using a Cortex LLM function.
1. Extract and ingest the data to a new table in Snowflake.
1. Explore Snowflake Cortex LLM functions to analyze and generate using this data. :robot_face:

---

### Produce a listing of the supplied PDF files. 🥋

A collection of ~130 PDF files containing interesting facts and details about plants has been uploaded to **course_files** stage in **common_db.resources** for you by the Education Services team.

**Modify** the SQL following code extract below and **run the cell** to `LIST` the supplied PDF files in the designated stage:
- Replace the hash `(#)` characters with the appropriate command and syntax to build the correct SQL statement.
- Run the SQL cell.

---

**Cell: `cell7`**

```sql
#### @common_db.resources.course_files/garden_kb;
```

---

## Directory Tables 📓

When working with unstructured data, **directory tables** are really helpful, and in many ways superior to working with the `LIST` command.

A [directory table](https://docs.snowflake.com/en/user-guide/data-load-dirtables) is an implicit object layered on a stage (not a separate database object) and is conceptually similar to an external table because it stores file-level metadata about the data files in the stage. Both internal and external stages are supported. The great thing is that these objects enable us to query the contents of a directory as if it were a table! The process of creating a directory table is as simple as enabling the option during the creation of a stage or altering the stage after creation. 

- In fact, you created a directory table back in Lab 8, though you may not have even realized it, as it is a default option included when using the Snowsight wizard to create a stage object.


You can access the directory table output with a table function, and pass names and file locations with ease to various Snowflake functions for processing.

---

### Query a directory table. 🥋

Take a look at the structure of the following query:
- It is a regular `SELECT` statement.
- Note the use of the **DIRECTORY** keyword to access the table function.
- We can choose columns to return `*` ("star all") in this case.
- We can also filter our results (as we do to only return those files under the "garden_kb" subdirectory of this stage).

Run this query and review the output, noting the types of information it returns about the files contained in this stage location.

---

**Cell: `cell10`**

```sql
SELECT *    
FROM DIRECTORY('@common_db.resources.course_files')
WHERE CONTAINS(relative_path, 'garden_kb/');
```

---

## Review the Supplied PDF Files 🥋

### What gardening insights have been collected?

As mentioned earlier, a collection of ~130 PDF files containing interesting facts and details about plants has been uploaded for you by the Education Services team.

- The collection of PDF files is named **snippet_1.pdf** through **snippet_129.pdf**. 

You might be interested to know what sort of information these "factoid" files contain!

Here's an example from this PDF file collection of plant and gardening knowledge. The text comes from the first file in the collection and relates to **artichokes**.

Growing **artichokes**? Some good tips here!

![snippet sample (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_artichokes_1.png)

---

### Download one of the plant "factoid" PDF files and review. 📓

You have seen an example of the content in a PDF file in our plant and gardening knowledge collection above. But let's download and open another PDF file and review.

- In the following example, we will examine the file: **snippet_9.pdf**.

- The SQL code (embedded inside Python) in this example makes use of a Snowflake function that generates links to files stored in stages, that can even be accessed "outside" of Snowflake. This is helpful when working with **unstructured** data. Please refer to the Snowflake documentation to learn more about the [GET_PRESIGNED_URL](https://docs.snowflake.com/en/sql-reference/functions/get_presigned_url) function.

---

### Run the following Python code cell and use the link generated to download the file. 🥋

**Right-click** on the link generated and **Open** in new tab or browser window (clicking the link will NOT work).

**Open** the file in a PDF viewer application on your local machine if not opened automatically in your browser.

- Let's see what nuggets of information are in this PDF file about your favorite veggie - Asparagus! :leafy_green:

- Feel free to examine some of the other files, numbered 1 through 129, after working through the first example.

---

**Cell: `cell14`**

```python
snowpark_df = session.sql("SELECT GET_PRESIGNED_URL(@common_db.resources.course_files, 'garden_kb/snippet_9.pdf')")
collected_data = snowpark_df.collect()
st.write('Open the following link in a new browser tab or window and review.')
st.write(collected_data[0][0])
st.write('Asparagus. Who knew!!!')
```

---

## Introducing Snowflake Cortex AI 📓

The Snowflake AI Data Cloud contains a suite of features and functions that give you instant access to industry-leading large language models (LLMs) trained by researchers at companies like Mistral, Reka, Meta, and Google, including Snowflake Arctic, an open enterprise-grade model developed by Snowflake.

Since these LLMs are fully hosted and managed by Snowflake, using them requires **NO SETUP**. Your data stays within Snowflake, giving you the performance, scalability, and governance you expect.

💡 Please refer to the Snowflake documentation for the [release status and availability](https://docs.snowflake.com/en/guides-overview-ai-features) of the following features.

![Snowflake generative AI (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_gen_ai_1_v2.png)

### Snowflake Cortex LLM functions.

One subset of the Snowflake AI options available is **Cortex LLM functions**. These are provided as SQL functions and are also available in Python, making accessing their powerful capabilities easy!

Cortex LLM Functions can be grouped into the following categories:

- Task-specific functions

- Helper functions

- `COMPLETE` function

👉 We will work some of these functions to ingest and "process" our plant and gardening data in the remainder of this lab.

---

## Utilize `PARSE_DOCUMENT()` to Extract Text 📓

Cortex [parse_document()](https://docs.snowflake.com/user-guide/snowflake-cortex/parse-document) is a Cortex LLM task-specific function that provides the ability to extract text or layout from documents stored in an internal or external stage. 

It is a SQL function. Because it is fully hosted and managed by Snowflake, using it requires no setup. This means you simply point the `PARSE_DOCUMENT` function to a stage where PDF documents are stored to extract text or layout data. In short, all it requires is:

- The name of a stage to read from.

- The PDF document within that stage you want to extract text from (it only supports PDF files at this point).

- It can read document layouts, but we will select the **OCR** mode to work with, which is great for handling text extraction.

💡 **Tip**: for even more sophisticated document extraction use cases you might want to check out the **LAYOUT** mode of this function or review Snowflake's [Document AI](https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai/overview) service.

---

### Text extraction example. 🥋

Review the following SQL statement:

- It uses a fully-qualified reference to the `PARSE_DOCUMENT()` function.

- We have provided a reference to the PDF document stage and a single file within that (this is the "Asparagus" example you opened earlier).

It's that easy. All you are doing is calling this "built-in" SQL function, and behind the scenes, Snowflake will open and read the file content and return it.

Go ahead and run the following code:

---

**Cell: `cell18`**

```sql
SELECT SNOWFLAKE.CORTEX.PARSE_DOCUMENT (
        @common_db.resources.course_files,
        'garden_kb/snippet_9.pdf',
        {'mode': 'OCR'}
    ) AS output;
```

---

### Review the `PARSE_DOCUMENT()` output. 🥋

Notice that the output from this function is provided in a semi-structured data format:

![Parse_document() output (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_parse_document_1.png)

There are **content** and **metadata** fields. 

💡 **Tip**:  remember, as you learned in **Lab 8**, that we can drill down into the nested fields contained within these semi-structured data structures using the `:` operator!

---

## Build a Text Extraction Workflow 📓

Now that we have a method to extract the text from the supplied plant and gardening PDF documents, we want to bring it into Snowflake so that we can use it.

👉 We want to create a **knowledge base** out of all the plant and gardening information that we have collected, and we can see many potential uses for this data.

Here is the workflow:

- Our knowledge base information begins as **UNSTRUCTURED** data in PDF files.

- The Cortex `PARSE_DOCUMENT()` function is run to extract the text from the PDF files and into a **SEMI-STRUCTURED** data format.

- Using Snowflake's syntax we can parse the output from the Cortex function to return **STRUCTURED** data content.

---

### Create a table to hold the knowledge base data. 🥋 

First, we need to create a table to hold the reference information extracted from the PDF documents.

Go ahead and run the following code to do so in the **(animal)_GARDEN_PLANTS.VEGGIES** schema. Note that we will include a column for the plant's name, which the content in the PDF file refers to.

---

**Cell: `cell22`**

```sql
CREATE OR REPLACE TABLE vegetable_knowledge_base (
    source_document STRING, -- the document name
    insight STRING,         -- the "factoid" contained with the file
    plant_name STRING       -- the name of the plant the "factoid" references
);
```

---

### Extract then `INSERT` data into the new table. 🥋

Let's begin bringing some of the features and functions we have learned about in this lab together.

The following `INSERT` statement leverages **directory tables** and the `PARSE_DOCUMENT()` function 

- The **directory table** listing returns the name of each of our PDF files in the **garden_kb** subdirectory of the **common_db.resources.course_files** stage.

- The location of each PDF document is passed to the `PARSE_DOCUMENT()` function so that text is extracted.

- Extracted text is returned in a semi-structured format and the **content** element is isolated and cast to a `STRING` with: `:content::STRING as extract`.

**Run** the code below to write the file name and extracted text for each PDF file to your new table.

---

**Cell: `cell24`**

```sql
INSERT INTO vegetable_knowledge_base (source_document, insight)
    SELECT 
        split_part(relative_path,'/',-1) as file_name, 
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT (
            @common_db.resources.course_files,
            relative_path,
            {'mode': 'OCR'}
        ):content::STRING as extract    
    from directory('@common_db.resources.course_files')
    where contains(relative_path, 'garden_kb/')
;
```

---

### Check your work. 🎯

**129** rows should be inserted into your new table. Now take a look at the "shape" of this data in the table.

- **Rewrite** the following query fragment to return **all** rows from your new knowledge base table.

---

**Cell: `cell26`**

```sql
SELECT #
FROM #########_#########_####;
```

---

### We have a problem!

We have managed to extract data from the supplied PDF files and write this to a table, but here is a problem...

Without reviewing the content of the **INSIGHT** column, we can't tell which plant each row of information relates to. All of the **PLANT_NAME** columns are empty. That's a problem when implementing a knowledge base!

We _could_ read each row and update the **PLANT_NAME** column manually, but that will take a long time with 129 rows in this table - and it's untenable with a much larger data set.

![Knowledge base table 1 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_kb_table_query_1.png)

---

## Utilize `CLASSIFY_TEXT()` on Text You Have Extracted 📓

Thankfully, Snowflake Cortex includes an LLM function called [CLASSIFY_TEXT()](https://docs.snowflake.com/en/sql-reference/functions/classify_text-snowflake-cortex). As its name suggests, this classifies free-form text data you provide.

- It is straightforward to invoke from SQL and, like the other Cortex LLM functions, doesn't require any setup - it's included as part of the Snowflake offering.

- The function returns a string that contains a JSON object. The JSON object contains the category that the input prompt was classified as. If invalid arguments are given, an error is returned.

![Classify text usage (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_classify_text_1.png)

---

### Classification example. 🥋

Review the following example that relates to our use case. We are passing the input string **apple** to the Cortex LLM function to review and, hopefully, categorize correctly as a **fruit**, **veggie**, or **flower**.

Go ahead and run the following code.

- Was it accurate?

- Try it with **tomato** as an input. :grinning:

---

**Cell: `cell30`**

```sql
SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT('apple', ['fruit', 'veggies', 'flowers']);
```

---

### An expanded classification use case. 📓

This is GREAT! This means we don't have to manually update the 129 rows in our table - we can have Snowflake do the heavy lifting.

- We need to write an `UPDATE` statement. 

- For each row in the table we pass the **INSIGHT** column as input.

- We can construct a list of names of all the known plants we store references to from the **VEGETABLE_DETAILS** table, which was created and loaded in an earlier lab.

- We can drill down into the semi-structured data output to extract the label value.

---

### Run classification. 🥋

Review the following SQL statement:

- It uses a fully-qualified reference to the `CLASSIFY_TEXT()` function.

 - The syntax in **LINE 4** may be new to you, but all this is doing is creating an `ARRAY` of plant names from the **vegetable_details** table to pass to the Cortex LLM function
    - this saves time rather than typing `Artichoke...Zucchini` manually!

Go ahead and run the following code:

---

**Cell: `cell33`**

```sql
UPDATE vegetable_knowledge_base
SET plant_name = SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    insight, 
    (SELECT ARRAY_AGG(plant_name) WITHIN GROUP (ORDER BY plant_name ASC) FROM vegetable_details) -- ASSEMBLE CATEGORIES
):label::STRING
WHERE insight IS NOT NULL 
AND insight <> '';
```

---

### Check your work. 🥋

**129** rows should have been **updated** in your knowledge base table. Take a look at the data in the table now.

- Run the following query to return all rows from the knowledge base table.

- Confirm that the **PLANT_NAME** column is now populated for **ALL** rows.

---

**Cell: `cell35`**

```sql
SELECT *
FROM vegetable_knowledge_base;
```

---

## Analyze Your Knowledge Base Data 📓

With the knowledge base table loaded from the supplied PDF files and each row categorized according to plant name, it would be helpful to understand the distribution of this data.

- How many "factoids" do we have per plant? 

- Do we have more information on some plants than others?

- Are we missing data for some of our plant collection?

All of this is useful to know to help us prioritize our efforts to expand this knowledge base.

---

### Run an analytical query. 🥋

The following query is an example of one of the types of [JOIN](https://docs.snowflake.com/en/sql-reference/constructs/join) operations that Snowflake supports.

In this, we want to get the full list of plant names from the **vegetable_details** table. For each plant, we want to produce a count of the number of rows in the **vegetable_knowledge_base** table. Using a `LEFT OUTER JOIN` means that even if there are no rows for a particular plant in **vegetable_knowledge_base**, we can still assign zero value to it - instead of it being omitted completely from the results.

Run and review the following query to understand the count of articles per plant.

💡 **Tip**:  We will name this cell, **knowledge_base_analytical_query**, in order easily reference its output later.

---

**Cell: `knowledge_base_analytical_query`**

```sql
SELECT a.plant_name, 
       nvl(count(b.*),0) AS kb_article_count
FROM vegetable_details a
LEFT OUTER JOIN vegetable_knowledge_base b
ON a.plant_name = b.plant_name
GROUP BY a.plant_name
ORDER BY 1;
```

---

## Streamlit in Snowflake 📓

[Streamlit](https://streamlit.io/) is an open-source Python library that makes it easy to create and share custom web apps for machine learning and data science.

[Streamlit in Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit) is an implementation of this technology on the Snowflake AI Data Cloud. 

- Snowflake manages the underlying compute and storage for Streamlit apps.

- Streamlit apps are Snowflake objects and use Role-based Access Control (RBAC) to manage access to Streamlit apps.

- Streamlit apps run on Snowflake warehouses and use internal stages to store files and data.

---

### Visualize data with Streamlit. 🥋

One of the great strengths of Streamlit is the ease with which it allows you to interact with and visualize data. You have already used it in the **Quiz** sections at the end of each lab in this course. With just a few lines of Python code, you can create clean and compelling charts and graphs that bring your data to life.

Run the following Python cell to produce a Streamlit bar chart that visualizes the results of the analytical query just run. Note how few lines of code are required to create this chart.

- Which plants lack knowledge base articles?

- Which plants have the most?

💡 **Tip**: As you learned earlier in this course, you can reference the results of previous cells in a later cell in a Snowflake notebook. The following code uses this capability, drawing on the output from the analytical SQL query cell (**knowledge_base_analytical_query**) just executed, to create a **pandas** DataFrame, which is then passed into Streamlit.

---

**Cell: `cell41`**

```python
import streamlit as st
import pandas as pd

chart_data = knowledge_base_analytical_query.to_pandas() # UTILIZES OUTPUT FROM AN EARLIER SQL CELL !!!

st.header("Knowledge Base Articles Per Plant")
st.bar_chart(chart_data, x="PLANT_NAME", y="KB_ARTICLE_COUNT", color=['#33C4FF'])
```

---

## There's a Lot More to Snowflake AI and LLM Functions 📓

There's a lot more to know about Snowflake's AI (and ML!) capabilities and much more than we could cover in this course. 

However, a couple of task-specific Cortex LLM functions that are useful are `TRANSLATE()` and `SUMMARIZE()`. Let's take a quick look at these:

- [TRANSLATE()](https://docs.snowflake.com/en/sql-reference/functions/translate-snowflake-cortex) - translates the given input text from one supported language to another.

- [SUMMARIZE()](https://docs.snowflake.com/en/sql-reference/functions/summarize-snowflake-cortex) - summarizes the given English-language input text.

Let's take a look at a couple of quick examples, utilizing our knowledge base data.

---

### Run a `TRANSLATE()` example. 🥋 

As you saw in previous examples, accessing the Cortex LLM functions using SQL is straightforward. We can call `TRANSLATE()` as we would any other SQL function, providing the following inputs:

- A string containing the text to be translated.

- A string specifying the language code for the language the text is currently in. Options include French, German, Italian, Japanese, Korean, Spanish, and more.

- A string specifying the language code into which the text should be translated.

**Run** the following example code to translate information in the knowledge base for any plants whose name begins with `'C'` from **English** into **Spanish** and then back into **English** from that translated version.

---

**Cell: `cell44`**

```sql
SELECT plant_name, 
       insight AS original_english_text,
       SNOWFLAKE.CORTEX.TRANSLATE(original_english_text, 'en', 'es') AS spanish_text,
       SNOWFLAKE.CORTEX.TRANSLATE(spanish_text, 'es', 'en') AS english_text_from_spanish,
FROM vegetable_knowledge_base
WHERE LEFT(plant_name,1) = 'C'; -- all the plant names beginning with C
```

---

### Run a `SUMMARIZE()` example. 🥋 

As its name suggests, the `SUMMARIZE()` function generates a summary, and this is of the given English-language input text. It takes just one parameter, and this is a string of the text you want summarized. 

**Run** the following example, which focuses on a single plant from our collection, the **Pumpkin**:

- We use [LISTAGG](https://docs.snowflake.com/en/sql-reference/functions/listagg) to bring together all the "factoids" (insights) we have for this plant as a single body of text.

- `SUMMARIZE()` is run across this single body of text, from which a summary is generated.

- We employ a Cortex LLM helper function [COUNT_TOKENS()](https://docs.snowflake.com/en/sql-reference/functions/count_tokens-snowflake-cortex) to indicate the relative size of the text **before** and **after** summarization - but you can, of course, review the outputs yourself.

💡 **Tip**: A token is the smallest unit of text processed by Snowflake Cortex LLM functions, approximately equal to four characters. The equivalence of raw input or output text to tokens can vary by model.

Go ahead and run the following code, and review the output:

---

**Cell: `cell46`**

```sql
SELECT listagg(insight) AS all_insights,
        SNOWFLAKE.CORTEX.count_tokens('summarize', all_insights) AS all_insights_tokens,
        SNOWFLAKE.CORTEX.SUMMARIZE(listagg(insight)) AS summary,
        SNOWFLAKE.CORTEX.count_tokens('summarize', summary) AS summary_tokens
FROM vegetable_knowledge_base
WHERE plant_name = 'Pumpkin';
```

---

## Last but Not Least, `COMPLETE()` 🥋

The most sophisticated of the Cortex LLM functions is [COMPLETE](https://docs.snowflake.com/en/sql-reference/functions/complete-snowflake-cortex). In its simplest form, the function takes a **prompt** (text and instructions on what we would like done with that text) and generates a **response** (completion) using your choice of supported language model.

To get a sense of how this works take a look at the following example:

- Here we make use of the **snowflake-arctic** model.

- We provide instructions to the model to help shape its response (e.g. "You are an I.T expert").

- We pose a question (e.g., "Explain what Snowflake is").

- The model's response will be based on its **innate** knowledge - that is, the data on which it has been trained - not additional information that we provide.

Run the following code, and review the output:

---

**Cell: `cell48`**

```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE('snowflake-arctic', 'You are an I.T expert. Explain what Snowflake is.') AS complete_response;
```

---

### Use our knowledge base data with `COMPLETE()`. 🥋

For our final example, let's aggregate **ALL** of the garden and plant insights we have in our knowledge base and pose questions which we want `COMPLETE()` to generate answers to, based on this information. 

### The `COMPLETE()` query explained.

The following query may look a little intimidating, so let's break it down into its part and explain what's happening:

#### Section one.

- The first section contains sample questions for you to run.

- Uncomment one each time you execute this SQL cell to ask a new question.

- Note that these queries may take a little time to run - please be patient.

![Complete query section 1 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_complete_query_1.png)

#### Section two.

- In the second section we define the prompt - which is our instructions and our ask of model accessed via the `COMPLETE()` function.

- Note that we have included tags in the prompt to clearly identify different blocks of text within the prompt for the model's "consumption".

![Complete query section 2 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_complete_query_2.png)

#### Section three.

- The third section is the actual call to the Cortex function.

- Note that we make use of the variables defined earlier in the cell, which makes it more flexible to iterate on.

![Complete query section 3 (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_complete_query_3.png)

---

**Cell: `cell50`**

```sql
-- example questions 
SET my_question  = 'which plant would take the shortest amount of time to cook';
--SET my_question  = 'which plants are best for beginner gardeners';


-- the prompt
SET prompt = 'You are a helpful gardening expert. Use only the supplied information <information> to answer the question posed <question>' || 
              $my_question || '</question> ' ||                 
             ' If you have no supplied information do not answer'; 
                
-- the Cortex function call
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mixtral-8x7b', --32K context window
    $my_question || 
    '<information>' ||
    (SELECT LISTAGG(insight, ' ') FROM vegetable_knowledge_base) ||
    '</information>'
) AS cortex_output;
```

---

## Final Quiz :mag_right:

## Test Your Knowledge :mag_right:

Check your understanding with interactive quiz questions below. Each `RUN_THIS_QUIZ_QUESTION_` cell has a Streamlit widget that presents a multiple‑choice question about Snowflake functionality.  

**Instructions:**  
1. Hover your cursor over the notebook cell to reveal additional controls.
1. Click the ▶️ **Play button** on the right side of each quiz cell to run it.  
1. Select your answer from the options provided.  
1. Review the feedback before moving on.  

💡 **Note:** You can expand the cell to view the code if you’re curious, but it’s not required. These quizzes aren’t mandatory — they’re here to challenge your knowledge transfer and give you a chance to practice.  

:point_right: These questions may be on any content you have covered in this course.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_1`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_2`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_3`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_4`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_5`** — run in Snowflake notebook to answer the quiz question.

---

## Congratulations :tada: :confetti_ball:

You have completed this course - well done!