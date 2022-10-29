# A place to write project notes
****
## MVC model
- Controller
- Views
- Models

Separate responsibilities into classes

****
## Classes
### Income
- Income name
- Income amount

### Requirements to add income to database (yml file)
- Create a `yaml` file to store income data
- Allow user to add income name and amount to database
- Display the updated amount from the data base


### Implementation steps
1. Create a `yaml` file called `income.yml`
2. Create a hash with current year as the key and a hash as a value and each
   month as keys and an array as the value for each month
3.  Create a method called `load_income_data` that will return the contents of
    `income.yml`
4. Create a method called `add_income_to_database` that will take 2 arguments:
   name and amount of income. This method will apend a hash like this: `{name:
   "Web Dev", amount: "400" }` to the array in #2
5.

### Expense categories
- Category name
- Number of expenses per category

### Expenses
- Expense name
- Expense amount
- Due date

### Debt
- Debt name
- Debt amount
- Balance owed
- Interest rate
- Monthly payment

### Insights
- Display charts
- group charts by specified time frame
- Date


### User
- signup
- signin
- signout
