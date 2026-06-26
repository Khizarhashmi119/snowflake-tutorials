# LAB 5: WAREHOUSES AND CONTEXT

👉 - In this lab, we will discuss virtual warehouses in more detail and explore options for adjusting their size (compute capacity), as well as examining Snowsight's options for viewing cost information.

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

## What is a Warehouse in Snowflake 📓 

### Defining "warehouse" in Snowflake.

- People who have been working with data for a while might think of the term "Data Warehouse" as referring to a special collection of data structures, but in Snowflake, warehouses don't store data.

- In Snowflake, warehouses are "compute resources" - they are used to perform the processing of data. 

- When you create a warehouse in Snowflake, you are defining these "resources".

### Scaling up and down. 

- Changing the size of warehouse changes the number of servers in the cluster. 

- Changing the size of an existing warehouse is called scaling up or scaling down.

### Scaling in and out. 

- If multi-cluster/elastic warehousing is available (Enterprise edition or above), a warehouse is capable of scaling out in times of increased demand.

- If multi-cluster scaling out takes place, clusters are added for the period of demand, and then clusters are removed (snap back) when demand decreases.

- The number of servers in the original cluster dictates the number of servers in each cluster during periods where the warehouse scales out by adding clusters.

---

## Just Because You Can... 📓 

### ...doesn't mean you SHOULD!!! 📓 

In Snowflake, you can bring ENORMOUS compute power into play in just a few seconds! We want you to know this is possible, especially if you have a large job that needs **LARGE** computing power. 

But, we also want you to know that most queries **DO NOT** require massive computing power. 

In fact, Snowflake recommends always starting with extra-small (XS) warehouses and only scaling up if you find a compelling reason to do that. XS warehouses use one credit per hour. Our largest warehouse is the Snowpark-optimized 6XL, which uses a whopping 768 credits per hour! More than 12 credits per minute! 

For this workshop, keep your warehouse set to XS except in cases where we ask you to use size S instead. 

For on-the-job Snowflake usage, you will likely have people who oversee the configuration of your warehouses. Warehouse oversizing is the simplest way to make mistakes that cause big surprises on the monthly invoice, so it's best to get accustomed to using XS and S warehouses most of the time and scale up only after careful consideration.

Snowflake recommends that each account have people who oversee costs and will have advanced knowledge of how to choose warehouse sizes best and configure the elasticity settings. These cost administrators will also be able to calculate whether the change in warehouse-size will result in enough time savings to justify the costs incurred or even balance them out.

---

## Resizing Virtual Warehouses 🥋

Snowflake Virtual Warehouse size can be adjusted via Snowsight or programmatically. Let's explore these options with your assigned virtual warehouse.

### Scale your virtual warehouse "up" using Snowsight.

Open the Snowsight Warehouses page in a new browser tab or window.

1. Hover over the **Compute** icon to the left of your Notebook in the main menu.

1. Right-click on the **Warehouses** link that appears in the dialog that appears and select your preferred target - a new tab or a new window.

1. Taking this action means we leave this Snowflake Notebook page uninterrupted and can switch back to its instructions easily.

![Open Warehouses page (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_admin_menu_1_v2.png)

1. Locate your animal named warehouse line.

1. Click on the ellipsis to the right of this line and select the **Edit** option.

![Open warehouses edit dialog (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_warehouse_edit_1.png)

1. Click into the **Size** dropdown.

1. Select the **Small 2 credits/hour** option.

1. Click the blue **Save Warehouse** option.

![Adjust warehouse size (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_warehouse_edit_2.png)

---

### Check your virtual warehouse size using code. 🥋

We can use the `SHOW` command to present many details of our virtual warehouse, including its current size.

Execute the following and note the value in the "size" column for your warehouse:

---

**Cell: `cell8`**

```sql
SHOW warehouses like '{{user}}_wh';
```

---

### Adjust your virtual warehouse size using code. 🥋

Provided you have the permission to perform these types of actions on a virtual warehouse, the `ALTER` statement can be used to change many of its properties, cancel running queries, and suspend (stop) or resume (start) it.

Execute the `ALTER` statement to return your virtual warehouse to the size it was before scaling it up using Snowsight in the above exercise.

---

**Cell: `cell10`**

```sql
ALTER warehouse {{user}}_wh SET warehouse_size=XSMALL;
```

---

### Use the `SHOW` command to confirm the successful warehouse size change. 🎯 

- **WRITE** a `SHOW` command to display information (including its current size) in the SQL cell below and run.

💡 **Hint**: no code is supplied in the following cell, but you should be able to take "inspiration" from commands run earlier in this notebook.

---

**Cell: `cell12`**

```sql
-- write your SHOW command here and run it to confirm the current virtual warehouse size
```

---

### Protecting yourself from surprises. 📓 

Snowflake has many ways to monitor and control costs so that if someone makes a mistake, you'll know about it as quickly as possible. A platform administrator will typically configure and manage these in your Snowflake account. Some of the options include:

- [Budgets](https://docs.snowflake.com/en/user-guide/budgets)
- [Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors)
- [Alerts and Notifications](https://docs.snowflake.com/en/guides-overview-alerts)

---

### Viewing cost information. 📓

Snowflake provides multiple features and capabilities to help you keep track of spending on the platform. You can write queries against views in the **ACCOUNT_USAGE** and **ORGANIZATION_USAGE** schemas of the **SNOWFLAKE** database to obtain this information. Even more simply, you can explore historical costs using Snowsight. Snowsight lets you quickly and easily obtain cost information from a visual dashboard. 

By default, only account administrators (that is, users with the `ACCOUNTADMIN` role) have access to cost and usage data, but these privileges have been granted to your `(animal)_LEARNER_RL` in this account. 

To explore account-level costs:
- Select **Admin** » **Cost Management** from the main left-side menu in Snowsight, and open this in a new browser tab or window

![Access cost management (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_cost_management_link_1_v2.png)

### Account overview.

- If prompted, select a warehouse to use to view the usage data.
- The **Account Overview** page provides high-level insights into the cost of using Snowflake and can be a starting point for optimizing your spend.

![Account Overview (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_account_overview_ui_v2.png)

### Consumption.

- You can use the **Consumption** page to drill down into the overall cost of using Snowflake for any given day, week, or month.

![Account Overview (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_consumption_ui_v2.png)


**Note**: these pages contain many selectable submenus and clickable components that allow you to drill down, filter, and sort costs in different ways, according to your requirements.

---

## Lesson 5 Challenge Exercise 🎯 

### Explore account-level costs.

#### Cost Management > Account Overview page. 🎯 

![Account Overview (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_account_overview_ui_small_v2.png)

Explore this page for yourself in Snowsight, and answer the following:

- what is the **average daily credits** for the last 28 days in this account?
- what is the largest database?
- which user(s) is responsible for the most expensive query during this period?

---

#### Cost Management > Consumption page. 🎯 

![Account Overview (image)](https://edu-cdev-images.s3.us-west-2.amazonaws.com/ob/ob_consumption_ui_small_v2.png)

Explore this page for yourself in Snowsight, and answer the following:

- on which day were the most credits consumed during the past 28 days?
- has AI Services consumed any credits during this period?

---

## Context Settings 📓 

**Does not exist** errors appear often, and they aren't always because you're using the wrong ROLE.

Sometimes you see a does not exist error for other reasons, like:

- you **created** something **in the wrong place** - like putting the ROOT_DEPTH table in the FRUITS schema.

- you are **looking in the wrong place** -- like `SELECT * FROM ROOT_DEPTH;` but your database context is set to `SNOWFLAKE_SAMPLE_DATA.PUBLIC`.

- you have a **typo** -- like `SELECT * FROM GARENPLNT.VEGGIES.ROOT_DEPTH;`

Of course, it's also possible **you DID NOT CREATE** the item!! So check for that possibility as well!

Also, by now, you should know...

- the difference between a USER and a ROLE. 

- the difference between a USER and an ACCOUNT.

- the difference between DEFAULT ROLE, your CURRENT ROLE on the Snowsight home page, and the ROLE in which your notebook context is set.

- how to programmatically change your role in a Snowflake notebook.

If you do not know these things, you may struggle with the questions below. If you do struggle, please go back and review the lesson.

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

> **Quiz cell `RUN_THIS_QUIZ_QUESTION_5`** — run in Snowflake notebook to answer the quiz question.

---

## Next Steps

If you have completed the lab steps and answered the **Knowledge Test** questions correctly, please proceed to the next Notebook when advised by your Snowflake instructor.