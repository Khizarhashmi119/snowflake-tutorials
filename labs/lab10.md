# LAB 10: CORTEX CODE IN SNOWSIGHT - YOUR AI CODING ASSISTANT

![New Features (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_new_features_small.png)

👉 In this lab we will use **Cortex Code** - Snowflake's AI-powered coding assistant built into Snowsight - to build an interactive "Garden Expert" application, right here in this notebook.

**What you will learn:**

1. How to open and use the **Cortex Code panel** in Snowsight
2. How to give natural language prompts to generate working SQL and Python code
3. How to build **interactive Streamlit widgets** in notebook cells using Cortex Code's help
4. How to leverage Snowflake AI functions such as `AI_COMPLETE` and `AI_FILTER` in a polished, visual application

**What makes this lab different:**

Unlike previous labs where we gave you the code to run, in this lab **you will use Cortex Code as your coding partner**. 
- You will describe what you want in plain English, and Cortex Code will generate the code for you. 
- You will then paste that code into a notebook cell and run it.

:robot_face: This is the future of development on Snowflake - natural language to working code in seconds.

---

To begin, let's grab **context information** we will use throughout this lab.

- Click the **Start** button to activate this notebook.

- Run the following Python cell.

---

#### :warning: Each time a new session is started for this notebook, you need to rerun the cell below to configure "variables" for use in later cells. :warning:

---

**Cell: `cell_setup`**

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

## What is Cortex Code?

**Cortex Code** is an AI-driven intelligent agent integrated into the Snowflake platform, and exposed in the Snowsight interface. It is optimized for complex data engineering, analytics, machine learning, and agent-building tasks. It uses an autonomous agent framework to interact directly with your Snowflake environment, with deep understanding of Snowflake’s Role-Based Access Control (RBAC), schemas, and best practices.

It can:

- **Generate SQL and Python code** from natural language descriptions
- **Explain existing code** - paste something in and ask "what does this do?"
- **Help with data exploration** - ask it about your tables, stages, and schemas
- **Debug errors** - paste an error message and ask for help

---

### How to open Cortex Code.

1. Look for the **Cortex Code icon** in the **right** of your Snowsight window (it looks like a small AI/sparkle icon)
2. **Click it** to open the panel on the right side of the screen

![Open Cortex Code (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_open_coco_panel.png)

> **Tip:** The Cortex Code panel opens alongside your notebook. You can type prompts in Cortex Code while keeping this notebook visible. If you want to open Cortex Code in a wider view, you can resize the panel by dragging its left edge.

3. The panel has a **message box** at the bottom where you type your prompts
4. Press **Enter** or click the send icon to submit your prompt

![Cortex Code interface (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_get_started.png)

**Cortex Code chat interface tour:**

- A. new chat
- B. chat history 
- C. close panel
- D. search and/or upload
- E. toggle plan mode
- F. model selector

---

### Cortex Code Panel Icons.

When Cortex Code generates code, you will notice several icons in the code block header:

![Cortex Code block header (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_code_block_header.png)

- **+ (Insert)** — Inserts the generated code into a new notebook cell
- **Replace** — Replaces the currently selected notebook cell with the generated code
- **Expand** — Expands the code block for easier viewing and copying
- **Copy** - Copy the code block

:warning: **For this lab:** To keep things simple, we recommend **copying and pasting** the generated code manually rather than using these buttons. This gives you more control over where code is placed and avoids accidentally overwriting existing cells.

:bulb: **Remember:** If you ever need to restore your notebook to its original state, simply re-run the **Workshop Configurator**.



---

:point_right: **Go ahead and open the Cortex Code panel now.** We will use it throughout this lab.

---

## Part A: Explore Your Data with Cortex Code

Let's start with a simple task to get comfortable with Cortex Code. 

In Lab 9, we worked with 39 plant images stored in a stage. Let's ask Cortex Code to help us list them.

### 1. Your first Cortex Code prompt.

:point_right: **In the Cortex Code panel**, type the following prompt and press enter.

- _Note that you can **copy** to the clipboard by hovering over the following statement and clicking the copy icon which appears._

![Copy to clipboard (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_copy_clipboard.png)

```
Write a select query to display all the plant image file names (and file paths) stored in 
the @common_db.resources.course_files stage under the plant_images/ folder. Show the output.
```

---

### Review results.

On the basis of the instructions entered in our prompt Cortex Code should generate a list directly in the chat panel. What you should also notice preceding this output is that it generated a SQL query to answer your natural language question. 

- Click **Expand** on the inline widget to expand and view the SQL code it generated and then ran, in response to your prompting.

- **Review the SQL generated** - it should look something like a `SELECT` from a `DIRECTORY` table function.

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_expand_sql.png)

### Run generated SQL.

:point_right: **Copy** the SQL that Cortex Code generates and **paste** it into the empty cell below, then **run** it.

> **Note:** If Cortex Code's output doesn't work perfectly, don't worry! A working version that Cortex Code generated earlier is provided in the cell after the empty one.

---

**Cell: `cortex_code_listing_cell`**

```sql
-- PASTE Cortex Code's generated SQL here and run it
```

---

**Cell: `cortex_code_listing_reference_solution`**

```sql
-- Fallback if Cortex Code's version doesn't work.
SELECT 
    RELATIVE_PATH AS file_path,
    SPLIT_PART(RELATIVE_PATH, '/', -1) AS file_name
FROM DIRECTORY(@common_db.resources.course_files)
WHERE RELATIVE_PATH LIKE 'plant_images/%'
ORDER BY file_name;
```

---

### 2. Ask Cortex Code for something a little more elaborate.

Now let's push Cortex Code further. We will ask it to analyze a subset of the plant images and describe what's in them by interrogating each image.

:point_right: **In the Cortex Code panel**, type the following prompt:

```
Analyze the plant images and describe what's in them - limit to the first 5 records.
```

---

### Review results.

On the basis of the prompt Cortex Code should generate a table containing **Image** and **Description** for five records, directly in the chat panel.

### Run generated SQL.

:point_right: Now **copy** the SQL that Cortex Code generated to produce this output and **paste** it into the empty cell 
below. 

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_expand_sql2.png)

- :bulb: **Observe:** Cortex Code understands Snowflake's AI functions and can build complex queries combining directory tables, stage references, and multimodal AI. Look at how it structures the query - this is exactly the pattern we used in Lab 9!
- Now **run** this code.

> **Note:** If Cortex Code's output doesn't work perfectly, don't worry! A working version that Cortex Code generated earlier is provided in the cell after the empty one.

---

**Cell: `cortex_code_multimodal_run`**

```sql
-- PASTE Cortex Code's generated SQL here and run it
```

---

**Cell: `cortex_code_multimodal_reference_solution`**

```sql
-- Fallback if Cortex Code's version doesn't work.
-- NOTE: pixtral-large is the selected model here.

SELECT 
    RELATIVE_PATH AS file_path,
    SPLIT_PART(RELATIVE_PATH, '/', -1) AS file_name,
    AI_COMPLETE(
        'pixtral-large',
        'Describe what you see in this image in 1-2 sentences. Focus on the plant or vegetable shown.',
        TO_FILE('@common_db.resources.course_files', RELATIVE_PATH)
    ) AS image_description
FROM DIRECTORY(@common_db.resources.course_files)
WHERE RELATIVE_PATH LIKE 'plant_images/%'
ORDER BY file_name
LIMIT 5;
```

---

### What just happened?

Congratulations! You successfully engaged **Cortex Code as a coding partner** to:
1. Generate a directory listing query (simple SQL)
2. Build a multimodal AI query that analyzes images (complex AI + stage references)

Cortex Code understood the intent of your natural language prompt. Combining this with its knowledge of Snowflake's `AI_COMPLETE`, `TO_FILE`, and `BUILD_STAGE_FILE_URL` functions, it generated working SQL code in response to your request.

:bulb: **Behind the scenes:** 
Cortex Code has knowledge of Snowflake's entire SQL syntax, AI functions, and best practices. It can adapt to your specific account context (your tables, stages, and schemas).

--- 
### A note on model selection.

You may observe that across, and even within sessions, Cortex Code will select a different model if you leave the default **Auto** selection option enabled.

So how should we think about which choose a model? Here are some examples relevant to our working examples:

- pixtral-large: fast, good for simple image descriptions, lower cost
- claude-sonnet-4-6: slower , more detailed/accurate analysis, higher cost, supports 1M token context window


```
| Priority               | Choose                      |
|------------------------|-----------------------------|
| Speed & cost           | pixtral-large               |
| Accuracy & detail      | claude-sonnet-4-6           |
| Document understanding | gemini-3.1-pro (1M context) |
```

**Rule of thumb:** 
- Start with a faster/cheaper model. If the quality isn't sufficient for your use case, move up to a larger model. 
---

:robot_face: Now let's build something truly interactive.

---

## Part B: Build An Interactive Garden Expert Widget

In Lab 9, we saw how the `AI_COMPLETE` function could be used to answer questions from our knowledge base data. In the following exercise we will wrap that into an interactive experience using **Streamlit widgets**.

Don't worry! We will use Cortex Code to help us write the code.

---
### Notes on iterative development with Cortex Code.

Sometimes, depending on interpretation of your prompt and the model involved, code generated by Cortex Code may produce an error. If you get an error, simply copy the error message from the output and paste it back into the Cortex Code input panel. Within an iteration or two, it will typically resolve the issue for you.

- You do not need to be technical, know Python, or be strong in SQL — Cortex Code will guide you through this process in plain language.

In the interest of time, we have also supplied a collapsed cell following each prompt with working code that was previously produced for us by Cortex Code.

You can use it as a reference if you get stuck or want to compare results.

**Note:** The model you choose can also influence this behavior — different models may produce different code, take different approaches, or require different numbers of iterations to resolve issues. If one model isn't giving you the result you want, try another!

Tips for a smooth iterative experience:

- Copy the full error message (not just a summary) back into Cortex Code
- Be specific about what you want changed or fixed
- If results drift far from your goal, start a fresh prompt rather than piling on corrections
- Don't be afraid to experiment — that's how you learn what works best

---
### Step 1: Create a question dropdown.

We want a dropdown menu where users can select from pre-written gardening questions, or type their own.

:point_right: **In the Cortex Code panel**, type the following prompt, and note the level of detail we are including in our request to shape the output:

```
Generate Python code for a Streamlit selectbox in a Snowflake notebook cell with 
  these gardening questions as options:
- "Which plant would take the shortest amount of time to cook?"
- "What vegetable is good for making salsa?"
- "Which vegetables are best for beginner gardeners?"
- "What plants grow well in cold weather?"
- "Which vegetables have the most vitamins?"

Also add a "Type your own question..." option. If that option is selected, show 
  a text_input field.
Clean up the free text user input from injection attempts and escape single quotes.

Display the output of the option the user selects.
```

---

### Copy and run the generated Python code.

:point_right: Now **copy** the Python code Cortex Code has generated and **paste** it into the empty Python cell below. 

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_copy_code.png)

- **Run** this code.
- **Interact** with the widget to select different options, including typing your own question, and **observe** the output.

> **Note:** If Cortex Code's output doesn't work perfectly, don't worry! A working version that Cortex Code generated earlier is provided in the cell after the empty one.

---

**Cell: `selectbox_widget_cell`**

```python
# PASTE Cortex Code's generated Python code here and run it
```

---

**Cell: `selectbox_widget_reference_solution`**

```python
# Fallback if Cortex Code's version doesn't work.
# Interactive Question Selector
# This creates a dropdown with sample questions about our garden plants

import streamlit as st
import re

questions = [
    "Which plant would take the shortest amount of time to cook?",
    "What vegetable is good for making salsa?",
    "Which vegetables are best for beginner gardeners?",
    "What plants grow well in cold weather?",
    "Which vegetables have the most vitamins?",
    "Type your own question..."
]

selected = st.selectbox("Select a gardening question:", questions)

if selected == "Type your own question...":
    user_input = st.text_input("Enter your question:")
    if user_input:
        sanitized = re.sub(r"[;\-\-\/\*\'\"\\\(\){}]", "", user_input)
        sanitized = sanitized.replace(chr(39), chr(39) + chr(39))
        sanitized = sanitized.strip()
        st.write(f"Your question: {sanitized}")
else:
    st.write(f"Selected question: {selected}")
```

---

### Step 2: Connect to the Vegetable knowledge base.

Now we need to wire this dropdown to the `vegetable_knowledge_base` table we used in Lab 9, and have Cortex Code generate intelligent answers to our questions using this validated knowledge set.

In Lab 9 we implemented code that included references to the `LISTAGG` and `AI_COMPLETE` functions. But let's prompt Cortex Code with our requirements in natural language and let it determine the best way to code a solution for us.

:bulb: **Important:** Make sure you are continuing in the **same Cortex Code conversation** from Step 1. Cortex Code uses conversation history to understand what "previous code" means.

:point_right: **In the Cortex Code panel**, try this prompt:

```
Add to the previous code from cell selectbox_widget_reference_solution: 
- use my current context as reference
- set context in generated code with Snowflake context functions for db, schema, warehouse
- add an "Ask the Garden Expert" button
- when clicked it should attempt to answer the user's question with reference to my 
  vegetable_knowledge_base table
- display the answer in an easy to read format
- show some progress widget while you are figuring out the answer
- clean up the free text user input from injection attempts and escape single quotes
- Important: Inside SQL queries, only use plain text in quotes for separators and special 
  characters — do not use any helper functions
- Format your answer using markdown with bullet points and bold plant names
```

---

### Copy and run the generated Python code.

:point_right: Now **copy** the Python code Cortex Code has generated and **paste** it into the empty Python cell below. 

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_copy_code2.png)

Take a look at the generated code. You will likely see that Cortex Code has implemented both `LISTAGG` and `AI_COMPLETE` as we did in Lab 9. Based on its Snowflake knowledge these have been determined the best options to build a response to our request.

- Now **run** this code.
- **Interact** with the widget to select different options, including typing your own question, and **observe** the output.

> **Note:** If Cortex Code's output doesn't work perfectly, no problem. A working version that Cortex Code generated earlier is provided in the cell after the empty one. The cell below has the complete working version. **Run it** to see the interactive Q&A in action!

---
### Important note on model selection. 

The working code example in this notebook uses the **llama3.1-70b** model for AI-powered responses. When you use Cortex Code to generate your own version, it may select a **different model** unless you explicitly specify one in your prompt or form the Cortex Code panel.  Note that ours is set to `Auto`.

`Auto` in the Cortex Code panel refers to the automatic model selection setting. When set to `Auto`, Cortex Code automatically chooses the best-suited LLM for your task rather than using a fixed model. You can click on it to manually select a specific model (e.g., Claude, Llama, etc.) if you prefer consistent results from a particular model.

Because different models interpret and evaluate prompts in their own way, your results may vary from the reference output. This is expected behavior — each model brings its own strengths and response style to the same question.

---

**Cell: `connect_kb_cell`**

```python
# PASTE Cortex Code's generated SQL code here and run it
```

---

**Cell: `connect_kb_cell_reference_solution`**

```python
# Fallback if Cortex Code's version doesn't work.
# NOTE: claude-sonnet-4-6 is the selected model here.

import streamlit as st

db = session.sql("SELECT CURRENT_DATABASE()").collect()[0][0]
schema = session.sql("SELECT CURRENT_SCHEMA()").collect()[0][0]
wh = session.sql("SELECT CURRENT_WAREHOUSE()").collect()[0][0]

knowledge_table = f"{db}.{schema}.VEGETABLE_KNOWLEDGE_BASE"

questions = [
    "Which plant would take the shortest amount of time to cook?",
    "What vegetable is good for making salsa?",
    "Which vegetables are best for beginner gardeners?",
    "What plants grow well in cold weather?",
    "Which vegetables have the most vitamins?",
    "Type your own question..."
]

selected = st.selectbox("Select a gardening question:", questions)

question = selected
if selected == "Type your own question...":
    user_input = st.text_input("Enter your question:")
    if user_input:
        bad_chars = [";", "--", "/*", "*/", "(", ")", "{", "}"]
        sanitized = user_input
        for c in bad_chars:
            sanitized = sanitized.replace(c, "")
        sanitized = sanitized.replace("'", "''")
        sanitized = sanitized.strip()
        question = sanitized
    else:
        question = None

if question:
    st.markdown("**Your question:** " + question)

if st.button("Ask the Garden Expert"):
    if not question:
        st.warning("Please enter a question first.")
    else:
        with st.spinner("Consulting the garden knowledge base..."):
            context_query = "SELECT LISTAGG(INSIGHT, ' ') AS ALL_INSIGHTS FROM " + knowledge_table
            context_df = session.sql(context_query).collect()
            context_text = context_df[0]["ALL_INSIGHTS"] if context_df else ""

            safe_question = question.replace("'", "''")
            safe_context = context_text.replace("'", "''")

            prompt = "You are a gardening expert. Format your answer using markdown with bullet points and bold plant names. Use the following information to answer the question. <information>" + safe_context + "</information> <question>" + safe_question + "</question>"

            safe_prompt = prompt.replace("'", "''")
            sql = "SELECT AI_COMPLETE('claude-sonnet-4-6', '" + safe_prompt + "') AS RESPONSE"

            result = session.sql(sql).collect()
            answer = result[0]["RESPONSE"] if result else "No answer found."
            answer = answer.strip('"').replace('\\n', '\n')

        st.markdown("---")
        st.markdown("### Garden Expert Says:")
        st.markdown(answer)
```

---

## Part C: Add Plant Images - The Visual "Wow" Factor

You now have a working Q&A widget powered by `AI_COMPLETE`. Next, let's add the visual element — matching plant images — to create a complete application.

This is where it all comes together. 

In the previous exercises we utilized Streamlit components to build the foundation of an interactive visual application that could generate real answers to questions about plants. In this step we will extend the functionality to scan our plant images and find ones that match the plants mentioned in the AI's answer. The matching images will be displayed in a grid below the answer.

If we were to hand code a solution we would make use of all of the following features covered in the course:
- **Stages** (where images are stored)
- **`AI_COMPLETE`** (answering questions)
- **`AI_FILTER`** (finding relevant images)
- **Streamlit** (displaying results interactively)
- **Cortex Code** (helping us write it all)

:robot_face: **But**, instead of coding a solution ourselves, we will defer to Cortex Code to generate a programmatic path to solving for a set of requirements we will propose in natural language.

---

### Set **Claude Opus 4.7 (or later)** as the selected model.

- In the Cortex Code chat panel select **Claude Opus 4.7 (or later)** as the model to use for generation. 

### 🔴 ACTION REQUIRED: Change Your Model

Select **`Claude Opus 4.7 (or later)`** in the Cortex Code panel now.

Note that this is described in the selector as `Most capable for ambitious work` and that is exactly what we are undertaking in the next couple of examples.

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_select_claude_opus_4.7.png)

---

### The Cortex Code Prompt for the Complete App

:point_right: Here is the prompt to supply to Cortex Code in the chat panel in order to generate the full application:

:bulb: Don't be intimidated by the length of this prompt — it's simply a clear specification of each feature you want. The more detail you provide, the better Cortex Code's first attempt will be.

```
Generate Python code to create a complete Streamlit widget in a Snowflake notebook cell:

Give it a title
Shows a selectbox with gardening questions plus a "Type your own" option
The gardening questions as options are:
- "Which plant would take the shortest amount of time to cook?"
- "What vegetable is good for making salsa?"
- "Which vegetables are best for beginner gardeners?"
- "What plants grow well in cold weather?"
- "Which vegetables have the most vitamins?"
Display the output of the option the user selects.
Use my current context as reference
Add an "Ask the Garden Expert" button
- when clicked it should attempt to answer the user's question with reference 
  to my vegetable_knowledge_base table
- When using the AI_COMPLETE function select claude-sonnet-4-5 as the model
- display the answer in an easy to read format
- show some progress widget while you are figuring out the answer
- clean up the free text user input from injection attempts and escape single 
  quotes
After showing the answer, search through the plant images 
  (@COMMON_DB.RESOURCES.COURSE_FILES under the plant_images/ folder ) in my course 
  files and display any photos that match plants mentioned in the answer. Show the 
  images in a row with their names as captions.
Important: Check the documentation for any AI functions to ensure correct usage.
Important: Check the documentation for the most flexible/open way to generate image 
  URLs from internal stages that render correctly inside Snowflake notebooks and 
  Streamlit in Snowflake.
Important: Do not try to use Streamlit features newer than what is supported in this 
Streamlit in Snowflake environment.
```

---

### Copy and run the generated Python code.

:point_right: Now **copy** the Python code Cortex Code has generated and **paste** it into the empty Python cell below. 

- Then **run** the code to see the complete Garden Expert application in action!
- **Interact** with the widget to select different options, including typing your own question, and **observe** the output.

> **Note:** If Cortex Code's output doesn't work perfectly, a working version that Cortex Code generated earlier is provided in the cell after the empty one. 

:warning: **Note:** The AI_FILTER step may take 15-30 seconds as it analyzes each image. This is expected - be patient and watch the spinner!

---

**Cell: `full_app_cell`**

```python
# PASTE Cortex Code's generated SQL code here and run it
```

---

**Cell: `full_app_reference_solution`**

```python
# THE COMPLETE GARDEN EXPERT APPLICATION
# Combines: Selectbox + AI_COMPLETE + AI_FILTER + Image Display
# NOTE: claude-opus-4-7 was used to generate this code.

import streamlit as st

st.title("Garden Expert AI Assistant")

db = session.sql("SELECT CURRENT_DATABASE()").collect()[0][0]
schema = session.sql("SELECT CURRENT_SCHEMA()").collect()[0][0]
wh = session.sql("SELECT CURRENT_WAREHOUSE()").collect()[0][0]

knowledge_table = f"{db}.{schema}.VEGETABLE_KNOWLEDGE_BASE"
image_stage = "@COMMON_DB.RESOURCES.COURSE_FILES"

questions = [
    "Which plant would take the shortest amount of time to cook?",
    "What vegetable is good for making salsa?",
    "Which vegetables are best for beginner gardeners?",
    "What plants grow well in cold weather?",
    "Which vegetables have the most vitamins?",
    "Type your own question..."
]

selected = st.selectbox("Select a gardening question:", questions)

question = selected
if selected == "Type your own question...":
    user_input = st.text_input("Enter your question:")
    if user_input:
        bad_chars = [";", "--", "/*", "*/", "(", ")", "{", "}"]
        sanitized = user_input
        for c in bad_chars:
            sanitized = sanitized.replace(c, "")
        sanitized = sanitized.replace("'", "''")
        sanitized = sanitized.strip()
        question = sanitized
    else:
        question = None

if question:
    st.markdown("**Your question:** " + question)

if st.button("Ask the Garden Expert"):
    if not question:
        st.warning("Please enter a question first.")
    else:
        with st.spinner("Consulting the garden knowledge base..."):
            context_query = "SELECT LISTAGG(INSIGHT, ' ') AS ALL_INSIGHTS FROM " + knowledge_table
            context_df = session.sql(context_query).collect()
            context_text = context_df[0]["ALL_INSIGHTS"] if context_df else ""

            safe_question = question.replace("'", "''")
            safe_context = context_text.replace("'", "''")

            prompt = "You are a gardening expert. Format your answer using markdown with bullet points and bold plant names. Use the following information to answer the question. <information>" + safe_context + "</information> <question>" + safe_question + "</question>"

            safe_prompt = prompt.replace("'", "''")
            sql = "SELECT AI_COMPLETE('claude-sonnet-4-6', '" + safe_prompt + "') AS RESPONSE"

            result = session.sql(sql).collect()
            answer = result[0]["RESPONSE"] if result else "No answer found."
            answer = answer.strip('"').replace('\\n', '\n')

        st.markdown("---")
        st.markdown("### Garden Expert Says:")
        st.markdown(answer)

        with st.spinner("Searching for matching plant images..."):
            image_sql = "SELECT RELATIVE_PATH FROM DIRECTORY(" + image_stage + ") WHERE RELATIVE_PATH LIKE 'plant_images/%'"
            image_df = session.sql(image_sql).collect()

            available_images = {}
            for row in image_df:
                path = row["RELATIVE_PATH"]
                name = path.split("/")[-1].split(".")[0].lower().replace("_", " ")
                available_images[name] = path

            answer_lower = answer.lower()
            matched = {}
            for name, path in available_images.items():
                if name in answer_lower:
                    matched[name] = path

            if matched:
                num_cols = min(len(matched), 5)
                cols = st.columns(num_cols)
                for idx, (name, path) in enumerate(matched.items()):
                    url_sql = "SELECT GET_PRESIGNED_URL(" + image_stage + ", '" + path + "', 3600) AS URL"
                    url_result = session.sql(url_sql).collect()
                    url = url_result[0]["URL"]
                    with cols[idx % num_cols]:
                        st.image(url, caption=name.title(), use_column_width=True)
            else:
                st.info("No matching plant images found for this answer.")
```

---

### Why Do the Two Cells Show Different Numbers of Images?

Depending on the model you select for code generation, and the model then selected for use in the `AI_COMPLETE` function in the generated code, you may notice that `full_app_reference_solution` displays a different number of plant images than your `full_app_cell`. For example, one might show 9 images while the other shows 8. **This is expected behavior — nothing is broken.**

#### The root cause: Different AI models

Here is an example where the two cells may use different AI models to answer the same question:

| Cell | AI Model | Example Plants Mentioned |
|------|----------|--------------------------|
| `full_app_cell` | `llama3.1-70b` | Broccoli, Cauliflower, Kale, Brussels Sprouts, Cabbage, Lettuce, Spinach, Chard, Arugula |
| `full_app_reference_solution` | `claude-sonnet-4-6` | Spinach, Lettuce, Chard, Celery, Arugula, Brussels Sprouts, Kale, Potatoes |

Both answers are correct — they just emphasize different vegetables because each model was trained on different data with different architectures and parameter counts.

#### How this affects the images

The image-matching logic works the same way in both cells:

1. The AI generates an answer mentioning specific plant names
2. The code scans the answer text for matches against the 39 image filenames in `@common_db.resources.course_files/plant_images/`
3. Any matching plant name gets displayed as an image

Since each model mentions a **different set of plants**, the number of matching images will differ. For example:

- `llama3.1-70b` mentions **broccoli** and **cauliflower** (which have images) but not celery or potatoes
- `claude-sonnet-4-6` mentions **celery** and **potatoes** (which also have images) but not broccoli or cauliflower

#### Key takeaway

The code logic is identical — the difference is entirely in the AI-generated answer. Different models produce slightly different results, and that is a normal and expected characteristic of working with large language models.

---

## What You Just Built

:tada: **Congratulations!** You just built an AI-powered application that:

1. **Presents a user-friendly interface** - dropdown with curated questions + custom input
2. **Leverages `AI_COMPLETE`** - answers questions using your private knowledge base data
3. **Uses `AI_FILTER` on images** - scans 39 plant images to find visual matches
4. **Displays results beautifully** - images in a responsive grid with captions

And you did it with the help of **Cortex Code** as your AI coding partner!

:robot_face: Simply by specifying requirements in natural language (i.e. how you wanted the application to function) Cortex Code was able to translate this into SQL and Python code to **build the outcome you were designing for**.

---

### Key Takeaways

| Snowflake Features and Components Used | Why |
|---|---|
| **Cortex Code** | AI assistant that generates code from natural language |
| **AI_COMPLETE** | Answers questions using knowledge base context |
| **AI_FILTER** | Scans images to find matches based on text descriptions |
| **Streamlit widgets** | Creates interactive UI elements in notebook cells |
| **GET_PRESIGNED_URL** | Generates temporary URLs for displaying stage images |
| **TO_FILE / BUILD_STAGE_FILE_URL** | Creates file references for AI functions |

---

## (OPTIONAL): Create a Standalone Streamlit App 

:star: **For those with the time and inclination** :grinning:

Everything we built above runs inside a notebook cell. But what if you wanted to share this as a **standalone application** that anyone in your organization can access? Let's have a go at creating this very thing with Cortex Code.

### Reminder: Creating with Cortex Code is an **iterative conversation**.

Working with LLMs and Agents requires time and practice. It is a skill that can be developed, and this is helpful to remember because not every interaction turns out as planned. Sometimes the issue lies on our side and the vague specifications we define in prompts, and other times AI can make assumptions or take wrong turns.

:point_right: **Treat each error as a conversation turn, not a failure**. 
- The more you iterate, the sharper your prompts become - and the faster you get to working code.

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_iterative_process.png)

If you encounter **any** error from the generated code in the following exercise:

1. **Copy** the error message
2. **Paste** it back into the Cortex Code window
3. Cortex Code will **remember your conversation** and fix the issue in the deployment scripts
4. **Recreate** the Streamlit app using the supplied SQL script to see the updated version

---

### Set **Claude Opus 4.7 (or later)** as the selected model for generation.

- In the Cortex Code chat panel select **Claude Opus 4.7 (or later)** as the model to use. 

### 🔴 ACTION REQUIRED: Change Your Model

Select **`Claude Opus 4.7 (or later)`** in the Cortex Code panel now.

Note that this is described in the selector as `Most capable for ambitious work` and that is exactly what we are undertaking in the next example.

![Expand SQL (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_select_claude_opus_4.7.png)

---

### Create the Streamlit application. 

You can ask Cortex Code to create a full **Streamlit in Snowflake** app! This will be a separate application accessible from the Snowsight "Streamlit" menu item (Projects > Streamlit).

:point_right: **If you want to try this**, open the Cortex Code panel in the UI and paste the following prompt. Cortex Code will generate: 
1. The Python code and required stage
2. A SQL file that you can review and execute

```
Create a Streamlit in Snowflake app called {CURRENT_USER}_VEGGIE_AI_EXPLORER 
in my VEGGIES schema using my default virtual warehouse.

Detect my username, database, and warehouse from my current context. 
Handle the case where any of these values might be missing by using sensible 
  defaults like "Gardener" for the username.

FEATURES:
- This is a standalone Streamlit app, not a notebook cell
- Use wide layout
- Name the Streamlit app object as {CURRENT_USER}_VEGGIE_AI_EXPLORER 
  and set the TITLE to '{CURRENT_USER} Veggie AI Explorer' — detect CURRENT_USER() 
  and use the actual value, not a placeholder
- Add a seedling emoji to the title
- A selectbox with these gardening questions plus a "Type your own question..." option:
    - "Which plant would take the shortest amount of time to cook?"
    - "What vegetable is good for making salsa?"
    - "Which vegetables are best for beginner gardeners?"
    - "What plants grow well in cold weather?"
    - "Which vegetables have the most vitamins?"
- Display the selected question
- A text input field when "Type your own" is selected
    - Clean up the free text user input from injection attempts and escape single quotes
- An "Ask the Garden Expert" button that when clicked:
    - Gets context from my vegetable_knowledge_base table (LISTAGG the insight column)
    - Uses AI to answer the question based on that context
    - When using the AI_COMPLETE function select claude-sonnet-4-5 as the model
    - Displays the answer in an easy-to-read markdown format
    - Shows a progress spinner while working
- After showing the answer, search through the plant images
  (@COMMON_DB.RESOURCES.COURSE_FILES under the plant_images/ folder) in my course files 
  and display any photos that match plants mentioned in the answer
    - Show images in a row with their names as captions
    - Show a default message if no matching images found

IMPORTANT RULES:
- Do NOT use backslashes in the code — use chr() instead
- Inside SQL queries, only use plain text in quotes for separators and special characters 
    — do not use any helper functions
- Check the documentation for any AI functions to ensure correct usage and that arguments 
  satisfy constant-expression requirements
- Check the documentation for the most flexible way to generate image URLs from internal 
  stages that render correctly inside Snowflake notebooks and Streamlit in Snowflake
- Do not try to use Streamlit features newer than what is supported in this Streamlit in 
  Snowflake environment
- Create objects in my database to build this app (stage, python files, etc), just ask for 
  confirmation before doing so
- However, provide the final SQL script to create the Streamlit app so I can review and then 
  run myself
- When writing the Python file to a stage using COPY INTO:
- The file format MUST include COMPRESSION = NONE and ENCODING = 'UTF8'
- The first line of the Python file must be: # -*- coding: utf-8 -*-
- Verify that output_bytes equals input_bytes in the COPY result
  (if they differ, the file is compressed and will fail)
```

---

### Cortex Code Confirmation Prompts

When you paste the Streamlit app prompt into Cortex Code, the first thing it will do is **ask for your permission** before creating any objects in your account. This is because the prompt includes the instruction: *"Create objects in my database to build this app, just ask for confirmation before doing so."*

You will see a confirmation prompt similar to this:

> **May I create a stage (STREAMLIT_STAGE) in your database and upload the Streamlit app Python file to it?**
>
> - **Yes, proceed** — Create the stage and upload the streamlit_app.py file
> - **No, just give me the code** — Provide all the SQL and Python code for me to run manually
> - **Something else** — I need clarification

#### What should you choose?

Select **"Yes, proceed"** to allow Cortex Code to create the necessary objects on your behalf. This is the recommended path for this lab.

Cortex Code needs to create these objects to deploy your Streamlit app:

| Object | Purpose |
|--------|---------|
| **Stage** (`STREAMLIT_STAGE`) | Stores the Python source file for your app |
| **File Format** | Used to write the Python file content to the stage without corruption |
| **Python file** (`streamlit_app.py`) | The actual Streamlit application code, uploaded to the stage |

#### Why does Cortex Code ask first?

Cortex Code follows a **confirmation-before-action** pattern when creating, modifying, or dropping Snowflake objects. This gives you the opportunity to:

- Review what will be created and where
- Ensure the correct database and schema are being used
- Decline if you prefer to run the commands manually

This is a good practice in any environment, and is especially important in shared or production accounts.

#### After confirming

Once you select **"Yes, proceed"**, Cortex Code will execute several steps automatically. You will be prompted to **Allow** each action in the Cortex Code panel on the right-hand side. The typical sequence is:

1. Create the stage
2. Create a file format (used to upload the Python file)
3. Upload the `streamlit_app.py` file to the stage
4. Provide the final `CREATE STREAMLIT` SQL for you to review and run yourself

### Working with Cortex Code to build the Streamlit application. 

:warning: **Note:** While Cortex Code is capable of deploying the entire Streamlit application itself we have opted for doing the final step of this ourselves in this live environment. This provides the opportunity for us to review the generated SQL code prior to execution, which is a good practice, unless you are running in a sandbox environment in which the tolerance for mistakes is higher. 

--- 
You will be prompted to **ALLOW** Cortex Code to perform a number of actions in the panel on the right-hand side. This is because we have specified this in our prompt. 

Your flow may diverge slightly from what follows, and this is only meant as a general example. 


1. Cortex Code checks if creating objects is acceptable to you

![Cortex Code proceed confirm (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_proceed_confirm.png)

2. Create file format confirmation

![Cortex Code create file format (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_create_ff.png)

3. Create stage confirmation

![Cortex Code create stage (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_create_stage.png)


4. Upload Streamlit source (Python) file to new stage

![Cortex Code upload Streamlit (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_upload_streamlit.png)

5. And finally Cortex Code provides the SQL code for you to copy and run in your workspace to deploy the Streamlit application. **Copy this code, paste it in the SQL cell below, and run**.

![Cortex Code create streamlit (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_streamlit_create_code.png)

:warning: **Note:** Be sure to read the Cortex Code output closely. If it does not produce the `CREATE STREAMLIT` statement follow the instructions it provides.

---

**Cell: `streamlit_app_sql_cell`**

```sql
-- PASTE Cortex Code's generated SQL code here and run it
```

---

### Navigate to the main Streamlit application launch panel.

- Open the Streamlit selection in a **new tab** in your browser.

![CoCo create stage (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_sis_menu_option.png)

### Locate your Streamlit application and click the name to run it.

![CoCo create stage (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_run_streamlit_app.png)

### Explore your new Cortex-Code-generated Streamlit application.

![CoCo create stage (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_coco_explore_streamlit_app.png)

---

**Cell: `working_example_reference_code`**

```sql
-- Remove old file
REMOVE @{{user}}_GARDEN_PLANTS.VEGGIES.STREAMLIT_STAGE/streamlit_app.py;

-- Upload fixed streamlit_app.py 
COPY INTO @{{user}}_GARDEN_PLANTS.VEGGIES.STREAMLIT_STAGE/streamlit_app.py
FROM (
SELECT
'import streamlit as st' || chr(10) ||
'from snowflake.snowpark.context import get_active_session' || chr(10) ||
chr(10) ||
'session = get_active_session()' || chr(10) ||
chr(10) ||
'st.set_page_config(layout="wide")' || chr(10) ||
chr(10) ||
'ctx = session.sql("SELECT CURRENT_DATABASE() AS DB, CURRENT_SCHEMA() AS SC, CURRENT_WAREHOUSE() AS WH, CURRENT_USER() AS USR").collect()[0]' || chr(10) ||
'my_db = str(ctx["DB"] or "")' || chr(10) ||
'my_schema = str(ctx["SC"] or "")' || chr(10) ||
'my_wh = str(ctx["WH"] or "")' || chr(10) ||
'my_user = str(ctx["USR"] or "Gardener")' || chr(10) ||
'knowledge_table = my_db + "." + my_schema + ".VEGETABLE_KNOWLEDGE_BASE"' || chr(10) ||
'image_stage = "@common_db.resources.course_files"' || chr(10) ||
chr(10) ||
'st.markdown("# &#127793; " + my_user + "' || chr(39) || 's Veggie AI Explorer")' || chr(10) ||
chr(10) ||
'questions = [' || chr(10) ||
'    "Which plant would take the shortest amount of time to cook?",' || chr(10) ||
'    "What vegetable is good for making salsa?",' || chr(10) ||
'    "Which vegetables are best for beginner gardeners?",' || chr(10) ||
'    "What plants grow well in cold weather?",' || chr(10) ||
'    "Which vegetables have the most vitamins?",' || chr(10) ||
'    "Type your own question..."' || chr(10) ||
']' || chr(10) ||
chr(10) ||
'selected = st.selectbox("Select a gardening question:", questions)' || chr(10) ||
chr(10) ||
'question = selected' || chr(10) ||
'if selected == "Type your own question...":' || chr(10) ||
'    user_input = st.text_input("Enter your question:")' || chr(10) ||
'    if user_input:' || chr(10) ||
'        bad_chars = [";", "--", "/*", "*/", "(", ")", "{", "}"]' || chr(10) ||
'        sanitized = user_input' || chr(10) ||
'        for c in bad_chars:' || chr(10) ||
'            sanitized = sanitized.replace(c, "")' || chr(10) ||
'        sanitized = sanitized.replace(chr(39), chr(39) + chr(39))' || chr(10) ||
'        sanitized = sanitized.strip()' || chr(10) ||
'        question = sanitized' || chr(10) ||
'    else:' || chr(10) ||
'        question = None' || chr(10) ||
chr(10) ||
'if question:' || chr(10) ||
'    st.markdown("**Your question:** " + question)' || chr(10) ||
chr(10) ||
'if st.button("Ask the Garden Expert"):' || chr(10) ||
'    if not question:' || chr(10) ||
'        st.warning("Please enter a question first.")' || chr(10) ||
'    else:' || chr(10) ||
'        with st.spinner("Consulting the garden knowledge base..."):' || chr(10) ||
'            q = chr(39)' || chr(10) ||
'            context_query = "SELECT LISTAGG(INSIGHT, " + q + " " + q + ") AS ALL_INSIGHTS FROM " + knowledge_table' || chr(10) ||
'            context_df = session.sql(context_query).collect()' || chr(10) ||
'            context_text = context_df[0]["ALL_INSIGHTS"] if context_df else ""' || chr(10) ||
chr(10) ||
'            safe_question = question.replace(chr(39), chr(39) + chr(39))' || chr(10) ||
'            safe_context = context_text.replace(chr(39), chr(39) + chr(39))' || chr(10) ||
chr(10) ||
'            prompt = "You are a gardening expert. Use the following information to answer the question. <information>" + safe_context + "</information> <question>" + safe_question + "</question>"' || chr(10) ||
chr(10) ||
'            safe_prompt = prompt.replace(chr(39), chr(39) + chr(39))' || chr(10) ||
'            sql = "SELECT AI_COMPLETE(" + q + "llama3.1-70b" + q + ", " + q + safe_prompt + q + ") AS RESPONSE"' || chr(10) ||
chr(10) ||
'            result = session.sql(sql).collect()' || chr(10) ||
'            answer = result[0]["RESPONSE"] if result else "No answer found."' || chr(10) ||
chr(10) ||
'        st.markdown("---")' || chr(10) ||
'        st.markdown("### Garden Expert Says:")' || chr(10) ||
'        st.markdown(answer)' || chr(10) ||
chr(10) ||
'        with st.spinner("Searching for matching plant images..."):' || chr(10) ||
'            image_sql = "SELECT RELATIVE_PATH FROM DIRECTORY(" + image_stage + ") WHERE RELATIVE_PATH LIKE " + q + "plant_images/%" + q' || chr(10) ||
'            image_df = session.sql(image_sql).collect()' || chr(10) ||
chr(10) ||
'            available_images = {}' || chr(10) ||
'            for row in image_df:' || chr(10) ||
'                path = row["RELATIVE_PATH"]' || chr(10) ||
'                name = path.split("/")[-1].split(".")[0].lower().replace("_", " ")' || chr(10) ||
'                available_images[name] = path' || chr(10) ||
chr(10) ||
'            answer_lower = answer.lower()' || chr(10) ||
'            matched = {}' || chr(10) ||
'            for name, path in available_images.items():' || chr(10) ||
'                if name in answer_lower:' || chr(10) ||
'                    matched[name] = path' || chr(10) ||
chr(10) ||
'            if matched:' || chr(10) ||
'                num_cols = min(len(matched), 5)' || chr(10) ||
'                cols = st.columns(num_cols)' || chr(10) ||
'                for idx, (name, path) in enumerate(matched.items()):' || chr(10) ||
'                    url_sql = "SELECT GET_PRESIGNED_URL(" + image_stage + ", " + q + path + q + ", 3600) AS URL"' || chr(10) ||
'                    url_result = session.sql(url_sql).collect()' || chr(10) ||
'                    url = url_result[0]["URL"]' || chr(10) ||
'                    with cols[idx % num_cols]:' || chr(10) ||
'                        st.image(url, caption=name.title(), use_column_width=True)' || chr(10) ||
'            else:' || chr(10) ||
'                st.info("No matching plant images found for this answer.")'
)
FILE_FORMAT = (FORMAT_NAME = '{{user}}_GARDEN_PLANTS.VEGGIES.STREAMLIT_FF')
OVERWRITE = TRUE
SINGLE = TRUE;


-- Re-create the Streamlit app
CREATE OR REPLACE STREAMLIT {{user}}_GARDEN_PLANTS.VEGGIES.{{user}}_VEGGIE_AI_EXPLORER
  ROOT_LOCATION = '@{{user}}_GARDEN_PLANTS.VEGGIES.STREAMLIT_STAGE'
  MAIN_FILE = '/streamlit_app.py'
  QUERY_WAREHOUSE = {{user}}_WH
  TITLE = '{{user}} Veggie AI Explorer';
```

---

### Troubleshooting tips.

If you encounter errors in the build and run process with your new AI-generated Streamlit app please refer to the tips and tricks in the following **troubleshooting tips** cell.

- Click **Expanded** in the notebook **View display options** (top right of the cell) to review.
- Remember that AI coding is an interative process, and different models may generate different options and results.

---

### Troubleshooting tips for Cortex Code Streamlit app generation.

When you paste the prompt above into Cortex Code, the generated app should work on the first try. However, AI-generated code may occasionally produce minor issues. Here are the two most common ones and how to fix them:

---

### Error 1: Backslash characters in the deployed app

**Symptom:** The app fails with a syntax error mentioning an unexpected backslash, or the AI answer displays literal `\n` characters instead of line breaks.

**Cause:** When Cortex Code writes the Python file to a Snowflake stage, backslash characters (like `\n`) can get double-escaped during the CSV export process.

**Fix:** Copy the error message back into the Cortex Code window and ask it to fix it. It will replace the backslash with `chr(92) + 'n'` which avoids the issue entirely.

---

### Error 2: `set_page_config() can only be called once per app page`

**Symptom:** You see this error if you try to run the generated code inside a **notebook cell** rather than as a standalone Streamlit app.

**Cause:** `st.set_page_config()` is only valid in standalone Streamlit apps. Snowflake notebooks manage page configuration automatically, so calling it in a cell causes a conflict.

**Fix:** Copy the error message back into the Cortex Code window. It will remove the `st.set_page_config()` line and the code will run correctly.

---

## Test Your Knowledge :mag_right:

Check your understanding with interactive quiz questions below. Each `RUN_THIS_QUIZ_QUESTION_` cell has a Streamlit widget that presents a multiple-choice question about Snowflake functionality.

**Instructions:**
1. Hover your cursor over the notebook cell to reveal additional controls.
1. Click the Play button on the right side of each quiz cell to run it.
1. Select your answer from the options provided.
1. Review the feedback before moving on.

:bulb: **Note:** You can expand the cell to view the code if you are curious, but it is not required.

:point_right: These questions may be on any content you have covered in this lab.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_1`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_2`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_3`** — run in Snowflake notebook to answer the quiz question.

---

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_4`** — run in Snowflake notebook to answer the quiz question.

---

## Congratulations :tada: :confetti_ball:

You have completed this **BONUS Snowflake Platform Training lab**!

**Remember:** Your Snowflake training account and the **Snowflake Intelligence Assistant** remain available for **30 days** after class. Use them to continue exploring, practicing, and building!

---

Thank you for participating. We hope you enjoyed the course! :snowflake: