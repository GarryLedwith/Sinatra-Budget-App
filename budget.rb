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

# view helpers 
helpers do 
  def count_expenses 
    # will count the number of expenses per expense category 
  end

  def group_income_by_date_range
    # groups income into a specified date range and displays the data 
  end

  def group_expenses_by_date_range 
    # groups expenses into a specified date range and displays the data 
  end

  def group_networth_by_date_range 
    # groups networth into a specified date range and displays the data 
  end
end 

# absolute path for data 
def data_path 
 if ENV["RACK-ENV"] == 'test'
   File.expand_path("../test/data", __FILE__)
 else 
   File.expand_path("../data", __FILE__)
 end 
end


#========= Accessing income and expense data in yaml files ==============================

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

# display income data 
def show_income_data(year, month) # need to rename this method to show_monthly_data 
  income_data = load_income_data
  
  # income_data[:month][:october][0]['amount'] # need to create a loop to iterate through yaml file here 
  income_data
end

# add income to income yaml file 
def add_income_to_database(name, amount)
  income_data = load_income_data 

  # create a method to write to yaml file 

  #Testing purposes: 
  # k => year 
  # v => hash containing 12 months in given year 
  # income_data.each do |k, v| 
  #   income_data[k][:month][:october][0][:income] = name # hardcoded for testing 
  #   income_data[k][:month][:october][0][:amount] = amount 
  #   binding.pry 
  # end

  # if income_data[:year].nil? 
  #   # create a key value pair 
  #   income_data[:year] = "2022"
  #   income_data[:months] 
  #   :month:
  #   :january: []
  #   :february: []
  #   :march: []
  #   :april: []
  #   :may: []
  #   :june: []
  #   :july: []
  #   :august: []
  #   :september: []
  #   :october: []
  #   :november: []
  #   :december: []

  # end 
  
  # income_data[:year][:month][:october] = name # hardcoded for testing 
  # income_data[:year][:month][:october][0][:amount] = amount 
  
  # income_data[:test] = "new test"
  # income_data[:month] = "May"

  path = "/home/parallels/Launch_School/Projects/RB175/budget_planner/data/income.yml"
  
  # File.open(path, 'w') { |f| YAML.dump(income_data[:test], f)} # write to yaml file 
  # binding.pry 

  income = {name: name, amount: amount}


File.open(path, "w") { |file| file.write(income.to_yaml) } # this will write to the associated yml file each time it is ran 
# and will override any existing data in the file 


  # data = YAML.load_file "path/to/yml_file.yml"
  # data["Name"] = ABC
  # File.open("path/to/yml_file.yml", 'w') { |f| YAML.dump(data, f) }



  # creates a new yaml file if none exists 
  def create_new_annual_database 



  end

end 

#===============================================================

# load expense data 

# Redundent code (will refactor)
def load_expense_data 
  expense_path = if ENV["RACK-ENV"] == "test"
    File.expand_path("../test/data/expense.yml", __FILE__)
  else 
    File.expand_path("../data/expense.yml", __FILE__)
  end

  YAML.load_file(expense_path) 
end

# display expense data
def show_expense_data(year, month)
  expense_data = load_expense_data
  
  expense_data[year]
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

  # add_income_to_database(@current_year, @current_month)

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

  # hard code: 
  expense_name = "Rent"
  expense_amount = "$500"

  if category_name.size >= 1 && category_name.size <= 100 
    session[:expense_categories] << { name: category_name, expenses: [] } # need to be added to yaml file 
    session[:success] = "The expense category has been created."
    redirect "/expenses"
  else 
    session[:error] = "Category name must be between 1 and 100 characters"

    erb :new_category, layout: :layout 
  end 
end

# View all expenses within an expense category for a given month 
get "/expenses/:id" do 
  @total = []
  
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
  expense = { name: expense_name, amount: expense_amount, due_date: params[:expense_due_date] } # needs to be added to yaml file 

  id = session[:id]

  if expense_name.size >= 1 && expense_name.size <= 100 
    session[:expense_categories][id][:expenses] << expense
    session[:october_expenses] << { expense_name => expense_amount } # info for display chart 
    session[:success] = "The expense and amount has been created."
    redirect "/expenses/#{id}"
  else 
    session[:error] = "Expense name must be between 1 and 100 characters"

    erb :new_expense_item, layout: :layout 
  end 
end



#============= Debt ====================

# Render a debt category 
get "/debt" do 
  time = Time.new 
    @current_month = time.strftime("%B")

    @monthly_debt = Hash.new # displays chart data 
  
    session[:october_debt].each do |hash|
      hash.each do |key, value|
        @monthly_debt[key] = value 
      end
    end
    
    @total = []
  erb :debt, layout: :layout 
end

# Render a new debt form 
get "/debt/new" do 
  erb :new_debt_item, layout: :layout 
end

# create a debt item 
post "/debt" do 
  debt_name = params[:debt_item].strip 
  debt_amount = params[:debt_amount].strip 

  if debt_name.size >= 1 && debt_name.size <= 100 
    session[:debt_items] << { name: debt_name, amount: debt_amount } # needs to be added to yaml file 
    session[:october_debt] << { debt_name => debt_amount } # info for display chart 
    session[:success] = "The debt and amount has been created."
    redirect "/debt"
  else 
    session[:error] = "Debt name must be between 1 and 100 characters"

    erb :new_debt_item, layout: :layout 
  end 
end 

#=================== Debt Free ========================

get "/debt/free" do 
  erb :debt_calculator, layout: :layout 

end

#============= Emergency Fund ====================

# Render emergency fund page 
get "/emergency" do 
  time = Time.new 
  @current_month = time.strftime("%B")

  @emergency = {'Emergency Fund' => "500"}
  
  @total = []
  erb :emergency, layout: :layout 
end

# Render a new emergengy fund form 
get "/emergency/new" do 

  erb :new_emergency_item, layout: :layout
end

# Render a new emergency goal form 
get "/emergency/goal" do 

  erb :new_emergency_goal, layout: :layout 
end


# Create an emergency item 
post "/emergency" do 
  emergency_name = params[:emergency_item].strip 
  emergency_amount = params[:emergency_amount].strip 

  if emergency_name.size >= 1 && emergency_name.size <= 100 
    session[:emergency_items] << { name: emergency_name, amount: emergency_amount } # need to add to yaml file 
    session[:success] = "The debt and amount has been created."
    redirect "/emergency"
  else 
    session[:error] = "Debt name must be between 1 and 100 characters"

    erb :new_emergency_item, layout: :layout 
  end 

end

#============= My budget ====================


get "/mybudget" do 
  erb :new_budget, layout: :layout 
end



#============= Goals ====================


get "/goals" do 
  erb :goals, layout: :layout 
end


#============= Net Worth ====================


# get "/networth" do 

#   @networth = { "January" => "800000", "February" => "760000", "March" => "810000", 
#     "April" => "660000", "May" => "850000","June" => "850000",
#     "July" => "850000", "August" => "850000", "September" => "975000"}
#   erb :net_worth, layout: :layout 
# end

#============= Insights ====================


get "/insights" do 

  @networth = { "January" => "800000", "February" => "760000", "March" => "810000", 
    "April" => "660000", "May" => "850000","June" => "850000",
    "July" => "850000", "August" => "850000", "September" => "5000"}
  erb :net_worth, layout: :layout 
  erb :insights, layout: :layout 
end





