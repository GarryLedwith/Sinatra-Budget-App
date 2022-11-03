require "sinatra"
require "sinatra/reloader" if development?
# require 'sinatra/base'
require "sinatra/contrib"
require "tilt/erubis"
require "redcarpet"
require "yaml"
require "bcrypt"
require "date"
require "chartkick"
require "financial_calculator"
require "pry"
require "tux"

configure do
  enable :sessions
  # set :session_secret, 'secret'
end

before do
  session[:expense_categories] ||= []
  session[:income_items] ||= []
  session[:expense_items] ||= []
  session[:debt_items] ||= []
  session[:emergency_items] ||= []
  session[:october_income] ||= []
  session[:october_expenses] ||= []
  session[:october_debt] ||= []
  session[:repayment_calculator] ||= []
end

# displays current month
def current_month
  time = Time.new
  time.strftime("%B")
end

# displays current year
def current_year
  time = Time.new
  time.strftime("%Y")
end

before do
  @current_month = current_month
  @current_year = current_year
end

# absolute path for data
def data_path
 if ENV["RACK-ENV"] == 'test'
   File.expand_path("../test/data", __FILE__)
 else
   File.expand_path("../data", __FILE__)
 end
end


#========= Income Methods ==============================

# load income data

# need to load a yaml file (either in test, or development)
def load_income_data
  income_path = if ENV["RACK-ENV"] == "test"
    File.expand_path("../test/data/income.yml", __FILE__)
  else
    File.expand_path("../data/income.yml", __FILE__)
  end

  YAML.load_file(income_path) # returns contents of yaml file
end

# Absolute path for income.yml (will refactor)
def income_data_path
  income_path = if ENV["RACK-ENV"] == "test"
    File.expand_path("../test/data/income.yml", __FILE__)
  else
    File.expand_path("../data/income.yml", __FILE__)
  end

  YAML.load(income_path) # returns the absolute path
end

# display income data
def show_income_data(year, month) # need to rename this method to show_monthly_data
  income_data = load_income_data

  # income_data[:month][:october][0]['amount'] # need to create a loop to iterate through yaml file here
  income_data
end

# add income to income yaml file
def add_income_to_database(name, amount)
  year = current_year.to_sym # converts current year to symbol
  month = current_month.downcase.to_sym # converts current month to a symbol

  path = income_data_path # loads path to income.yml

  income_data = load_income_data # loads the contents of the yml file
  income = { name: name, amount: amount } # hash will be stored in database

  income_data[year][month] << income # appends income to database

  update_database = YAML.dump(income_data) # converts data to YAML
  File.write(path, update_database) # update data in database (yml file)
  # binding.pry
end

# will need to add one argument to this method: a path to yml file
def create_empty_database_table
  path = income_data_path # loads path to income.yml
  income_data = load_income_data # loads the contents of the inclme yml file (tesing purposes only)
  income_table = annual_database_table

  File.open(path, 'w') { |file| file.write(income_table.to_yaml)}
end

#============ non specific database methods ==============

# yearly database table template for income
def annual_database_table
  year = current_year.to_sym

  { year => { januray: [], february: [], march: [], april: [],
              may: [], june: [], july: [], august: [], september: [],
              october: [], november: [], december: [] }}
end


#====================================================
# Expense database tables

# method will be used in the categories route
def annual_expense_category_database_table(category_name)
  year = current_year.to_sym
  category = category_name.to_sym

  { year => { category => { januray: [], february: [], march: [], april: [],
    may: [], june: [], july: [], august: [], september: [],
    october: [], november: [], december: [] }}}
end

def create_empty_expense_database_table(category_name)
  path = expense_data_path # loads path to income.yml
  expense_data = load_expense_data # loads the contents of the inclme yml file (tesing purposes only)
  expense_table = annual_expense_category_database_table(category_name)

  File.open(path, 'a+') { |file| file.write(expense_table.to_yaml)}
end

def create_new_expense_database
  path = expense_data_path # loads path to income.yml
  expense_data = load_expense_data # loads the contents of the inclme yml file (tesing purposes only)
  category_name = 'test'.to_sym
  expense_table = annual_expense_category_database_table(category_name)

  File.open(path, 'w') { |file| file.write(expense_table.to_yaml)}
end

#===============================================================

#========= Expense Methods ====================================

# Absolute path for expense.yml (will refactor)

# This file path in this method must be dynamic
def expense_data_path
  expense_path = if ENV["RACK-ENV"] == "test"
    File.expand_path("../test/data/expenses.yml", __FILE__)
  else
    File.expand_path("../data/expenses.yml", __FILE__)
  end

  YAML.load(expense_path) # returns the absolute path
end

# reads and parses file
# Redundent code (will refactor)
def load_expense_data
  expense_path = if ENV["RACK-ENV"] == "test"
    File.expand_path("../test/data/expenses.yml", __FILE__)
  else
    File.expand_path("../data/expenses.yml", __FILE__)
  end

  YAML.load_file(expense_path)
end

# display income data
def show_income_data(year, month) # need to rename this method to show_monthly_data
  income_data = load_income_data

  # income_data[:month][:october][0]['amount'] # need to create a loop to iterate through yaml file here
  income_data
end

# add income to income yaml file
def add_expense_to_database(name, amount, date)

  #   =========NOTE=======
  # When I delete database these two local variables are returning nil:

  year = current_year.to_sym # converts current year to symbol
  month = current_month.downcase.to_sym # converts current month to a symbol
  category = "Fixed Expenses" # hardcoded for testing

  path = expense_data_path # loads path to income.yml

  expense_data = load_expense_data # loads the contents of the yml file
  expenses = { name: name, amount: amount, date: date} # hash will be stored in database


  #========NOTE===============
  # This hash data is hardcoded to debug a problem with nil:
  # binding.pry
  expense_data[:"2022"][:test][:november] << expenses # appends income to database
  # binding.pry

  update_database = YAML.dump(expense_data) # converts data to YAML
  File.write(path, update_database) # update data in database (yml file)
end

def delete_income_data_form_database(name, amount)
  # this method will delete data from database
end

# will need to add one argument to this method: a path to yml file
def create_empty_database_table
  path = income_data_path # loads path to income.yml
  income_data = load_income_data # loads the contents of the inclme yml file (tesing purposes only)
  income_table = annual_database_table

  File.open(path, 'w') { |file| file.write(income_table.to_yaml)}
end



# Routes
# ======= Home ===============================

# Displays a list of files in the data directory
get "/" do
  @files = Dir.glob(data_path + "/*").map do |path|
    File.basename(path)
  end

  erb :home, layout: :layout
end

#========== Income item and amount ===================

# Render income category
get "/income" do
  # time = Time.new
  # @current_month = time.strftime("%B")

  @current_month
  @current_year

  #session[:pie_chart] = { work: 5000, singing: 600, dancing: 900 } # need to build this

  @files = Dir.glob(data_path + "/income.yml").map do |path| # this can be changed to dynamic
    File.basename(path)
  end # returns income.yml file (for visual purpose only)



  #@income_data = show_income_data(@current_year, @current_month)

  @income_data = load_income_data # for testing purposes (returns the absolute path)

  @monthly_data = Hash.new # displays chart data

  # @new_database_table = create_empty_database_table # creates a new empty database table

  session[:october_income].each do |hash|
    hash.each do |key, value|
      @monthly_data[key] = value
    end
  end

  @total = []
  erb :income, layout: :layout
end

# Render a new income item form
get "/income/new" do
  erb :new_income_item, layout: :layout
end

# Create an income item
post '/income' do
income_name = params[:income_item].strip
income_amount = params[:income_amount].strip


if income_name.size >= 1 && income_name.size <= 100
  session[:income_items] << { name: income_name, amount: income_amount } # needs to be added to yaml file
  add_income_to_database(income_name, income_amount) # add income to yml file

  session[:october_income] << { income_name => income_amount } # info for display chart
  session[:success] = "The income and amount has been created."
  redirect "/income"
else
  session[:error] = "Category name must be between 1 and 100 characters"

  erb :new_income_category, layout: :layout
end
end

#========== Expense categories ===================

# View all expense categories
get "/expenses" do

  @current_month
  @current_year

  @category = session[:expense_category_name] # use this name for my database hash


  @expense_categories = session[:expense_categories]
  session[:pie_chart] = { "Fixed Expenses" => 5, "Long Term Expenses" => 6, "Just for Fun" =>  9 } # need to build this
  erb :expense_categories, layout: :layout
end

# Render a new expense category form
get "/expenses/new" do
  erb :new_category, layout: :layout
end

# Create a new expense category
post '/expenses' do
  category_name = params[:expense_category_name].strip # returning nil when trying to create a new expense

  # databae in yml:


  if category_name.size >= 1 && category_name.size <= 100
    session[:expense_categories] << { name: category_name, expenses: [] } # need to be added to yaml file

    session[:expense_category_name] = category_name

    # I need to add a method here to build a database yaml file

  # add new hash to expense yaml file from here

  create_empty_expense_database_table(category_name)

    session[:success] = "The expense category has been created."
    redirect "/expenses"
  else
    session[:error] = "Category name must be between 1 and 100 characters"

    erb :new_category, layout: :layout
  end
end

# View all expenses within an expense category for a given month
get "/expenses/:id" do
  @total = [100] # I need to fix this assignement issue

  @expense_data = load_expense_data # for testing purposes (returns the absolute path)

  session[:id] = params[:id].to_i # setting the session id to params id
  session[:id]
  @expense_category = session[:expense_categories][session[:id]]

  @monthly_expenses = Hash.new # displays chart data

  session[:october_expenses].each do |hash|
      hash.each do |key, value|
        @monthly_expenses[key] = value
      end
    end
  erb :expense, layout: :layout
end



#========== Expense item and amount ===================

# This method is not working
get '/expense' do
  # @expense = session[:expense_items] # what is this line for?

  erb :expense, layout: :layout
end


# Render a new expense item form
get "/expense/new" do
  erb :new_expense_item, layout: :layout
end

# Create a new expense item
post "/expense" do
  expense_name = params[:expense_item].strip
  expense_amount = params[:expense_amount].strip
  due_date = params[:expense_due_date].strip
  expense = { name: expense_name, amount: expense_amount, due_date: params[:expense_due_date] } # needs to be added to yaml file

  id = session[:id]

  if expense_name.size >= 1 && expense_name.size <= 100
    session[:expense_categories][id][:expenses] << expense
    add_expense_to_database(expense_name, expense_amount, due_date)

    session[:october_expenses] << { expense_name => expense_amount } # info for display chart
    session[:success] = "The expense and amount has been created."
    redirect "/expenses/#{id}"
  else
    session[:error] = "Expense name must be between 1 and 100 characters"

    erb :new_expense_item, layout: :layout
  end
end

#============= New budget ====================


get "/mybudget" do
  erb :new_budget, layout: :layout
end


# Create an income item
post '/mybudget' do
  name = params[:budget_name].strip
  # currency = params[:income_amount].strip
  # date_format = params[:date_format].strip
  # currenct_placement = params[:currenct_placement].strip

  # how do I store this info form the form?



  if name.size >= 1 && name.size <= 100
    # session[:income_items] << { name: income_name, amount: income_amount } # needs to be added to yaml file
    # add_income_to_database(income_name, income_amount) # add income to yml file

   create_empty_database_table # creates a new empty database table
  #  create_empty_expense_database_table # creates a new empty expense database
  #  table
  create_new_expense_database

    # session[:october_income] << { income_name => income_amount } # info for display chart
    session[:success] = "Your new budget has been created."
    redirect "/income"
  else
    session[:error] = "Budget name must be between 1 and 100 characters"

    erb :new_budget, layout: :layout
  end
end

#============= Net Worth ====================


get "/networth" do

  @networth = { "January" => "800000", "February" => "760000", "March" => "810000",
    "April" => "660000", "May" => "850000","June" => "850000",
    "July" => "850000", "August" => "850000", "September" => "975000"}
  erb :networth_report, layout: :layout
end

#============= Insights ====================


get "/insights" do

  @networth = { "January" => "800000", "February" => "760000", "March" => "810000",
    "April" => "660000", "May" => "850000","June" => "850000",
    "July" => "850000", "August" => "850000", "September" => "5000"}
  erb :net_worth, layout: :layout
  erb :insights, layout: :layout
end


#display debt calculator tool
get "/tools" do

erb :debt_calculator, layout: :layout
end


#======= Reports ========================


# Render income report
get "/income-report" do

  erb :income_report, layout: :layout
end

# Create income report
post "/income-report" do

redirect "/income-report"
end


# Render spending report
get "/spending-report" do

  erb :income_report, layout: :layout
end

# Render income vs spending report
get "/income_vs_spending" do

  erb :income_vs_expending, layout: :layout
end

# Render networth report
get "/networth-report" do

  @networth = { "January" => "800000", "February" => "760000", "March" => "810000",
    "April" => "660000", "May" => "850000","June" => "850000",
    "July" => "850000", "August" => "850000", "September" => "5000"}

  erb :networth_report, layout: :layout
end

post "/networth-report" do
  redirect "/networth-report"
end



