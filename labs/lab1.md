# LAB 1: INTERACTING WITH SNOWFLAKE

👉 In this lesson, we'll introduce you to a number of the visual interfaces you can use to interact with Snowflake. We will explore Snowflake Notebooks, which will be used throughout this course.

---

## Snowsight User Interfaces 📓 

Snowsight, the web UI you are logged into, contains several different interfaces to interact with Snowflake, depending on your preferences.

### An object-based UI navigator.

- This is the Main or Home interface for managing and viewing objects.
    
- When you click on the Snowflake logo (top-left) in this interface, the Home screen displays. This offers a search bar, **Quick actions** links, and a list of **Recently viewed** projects.

![Snowsight home (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_snowsight_main_1_v2.png)

---

### Workspaces.
    
[Workspaces](https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces) provides a unified editor for creating, organizing, and managing code across multiple file types that you can use to analyze data, develop models, and build pipelines.

- Streamlined interface to write and run SQL statements and queries and view results.

- Import and manage files and folders.

- Has an embedded object browser, which is a hierarchical tree that allows you to find and select the objects you want to work with.

![SQL worksheet (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_snowsight_workspaces_1.png)

---

### Python-based worksheets.

- Use to write and run Python, with an option to deploy this code as a Python stored procedure.

- Also has an embedded object browser.

![Python worksheet (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_python_worksheet_1_v2.png)

---

### Snowflake notebooks.

- Contains markdown cells for annotation, along with executable SQL and Python cells.

- Also has an embedded object browser.
    
![Snowsight home (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_snowflake_notebook_1_v2.png)

👉 **Snowflake Notebooks** are the primary vehicle by which you will interact with the lab content for this course. We will spend a little time exploring their capabilities before entering the course content.

---

## Snowflake Notebook Capabilities 📓 

### Starting a notebook session.

Snowflake notebooks require **active** compute resources to execute code in the SQL and Python cells they contain. These compute resources (a Snowflake virtual warehouse, which we will explain later) are assigned to a Snowflake Notebook at creation time. But they do not start when you enter a notebook. A new `session` can be triggered in one of two ways:

1. Click the **Start** button at the top-right of the notebook interface. This may take several seconds to complete, and the button will display **Active** once complete.
1. Try running an executable (SQL or Python) notebook cell. This system will establish a new session before running the code in that cell.

![Start session (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_start_session.png)

💡 **Tip:** The dropdown to the right of this button contains an option to `End` a session. When you have finished your work in a notebook, it's good practice to end your notebook session manually. Notebooks shut down automatically after a configurable idle timeout period expires, but doing this manually once your work is done will save on compute costs.

---

### Notebook cell basics. 📓 

- **Add cells**
    - Hover over the lower border of an existing cell, then click on the button for desired cell type. 

- **Change cell types**
    - In the existing cell, select the down arrow next to cell type.

- **Delete cells**
    - Select ellipsis and choose appropriate action.

- **Duplicate cells**
    - Select ellipsis and choose appropriate action.    

- **Move cells**
    - Select ellipsis (three stacked vertical dots) and choose appropriate action (Move cell up, Move cell down).
    - Hover over the cell to move, select drag and drop icon, move cell to the new location.

---

### Try it yourself! 🥋

1. Click the dropdown next to the **Markdown** label at the top-left of this notebook cell and see how easy it is to change this cell type to either SQL or Python.
1. Rename this markdown cell by clicking on the name and entering a new label. Note that there are certain limitations on characters that can be used in a cell name.
1. Select the ellipsis top-right of this markdown cell and note the options to move, duplicate, or delete this cell.
1. Click on the horizontal bar icon to the left of the ellipsis, top right of this cell, to **Collapse** or **Expand** this cell in the notebook.

---

### Running notebook cells. 📓 

![Notebook run options (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_notebook_run_options_1.png)

Common cell actions are listed below for your awareness:

- **Run a single cell**
    - Select gray play arrow in top right corner of cell.
    - Use standard Run shortcut keys:
        - Cmd + Return - Mac.
        - Ctrl + Enter - Windows.
    
- **Run all notebook cells sequentially**
    - Select **Run all** (option at top of notebook to the right of the **Start** button).
    - Use shortcut keys:
        - Cmd + Shift + Return – Mac.
        - Ctrl + Shift + Enter – Windows.

- **Run cell and advance (to next)**
    - Select ellipsis at the top of a SQL or Python cell, click on **Run cell and advance**.
    - Use shortcut keys:
        - Shift + Return – Mac.
        - Shift + Enter – Windows.

- **Run all above or Run all below (current cell)**
    - Select ellipsis at the top of a SQL or Python cell, click **Run all above** or **Run all below**.

---

## Running SQL Cells

Notebook SQL cells let you write and run SQL statements, review some query details, and examine results.

### Try it yourself! 🥋

1. Start the notebook session if it is not already **Active**.
1. Run the **SQL** cell immediately below this markdown cell using the grey **Run** button in that cell.
1. See if you can re-run the same cell using the keyboard shortcut instead of the **Run** button.
1. If you feel comfortable, edit the SQL in the cell (change **date** for **time** and `current_date()` for `current_timestamp()`) and rerun.

💡 **Tip:** As you enter SQL into the cell, note that the **autocomplete** feature runs, offering contextual suggestions.

---

**Cell: `cell11`**

```sql
SELECT current_timestamp() as "What is the current date?";
```

---

## Running Python Cells

Notebook Python cells enable you to write code to:
- Extract data from stages or database objects.
- Transform and store data.
- Conduct data analysis and manipulation.
- Create data visualizations.
- Access SQL results as Snowpark or Pandas DataFrames.

And you can even use your favorite Python libraries! :snake:

### Try it yourself! 🥋 

1. Run the Python cell immediately below this markdown cell using the grey Run button in that cell.
1. See if you can re-run the same cell using the keyboard shortcut instead of the Run button.

💡 Tip: Observe that the Python code used to produce the same result is slightly more verbose than the SQL statement you ran above. It requires a little more setup before execution but is incredibly flexible. Don't worry if you don't understand the details of the code at this stage. We will explain more throughout this course!

---

**Cell: `cell13`**

```python
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import current_date
session = get_active_session()
session.create_dataframe([1]).select(current_date().alias("What is the current date?")).collect()
```

---

## Python Variable Substitution across Notebook Cells 🥋

In Snowflake Notebooks, we can make use of Jinja syntax `{{..}}` to reference Python variables defined earlier in both Python and SQL cells that occur later.

Let's demonstrate that by first defining a Python variable, and printing this out to screen in the cell. Execute the following Python cell to do so:

---

**Cell: `cell15`**

```python
greeting = 'Welcome to this course!'
print(greeting)
```

---

We can reuse this stored variable in a later Python cell. Run the following.

---

**Cell: `cell17`**

```python
print("This is the \"greeting\" that was defined in an earlier cell:")
print(greeting)
```

---

We can use this variable substitution in **SQL** cells by leveraging the Jinja syntax! Try this out:

---

**Cell: `cell19`**

```sql
SELECT '{{greeting}}' AS "This is the greeting that was defined in an earlier cell:";
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

To do so, click the navigation button on the top left of the Notebook interface to return to the Notebook listing page.

![Notebook navigation (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_notebook_nav_4_v2.png)

- A dialog may appear confirming that you want to **End session?** Click on the red **End session** button to do so. 

- To save credits, you should end your session when exiting. If you plan to come back, you can keep the session running until it times out from inactivity.