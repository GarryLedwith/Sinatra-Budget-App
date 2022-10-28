# Add income routes 

class IncomeController < ApplicationController 
  
  
  def initialize(name, amount)
    @income_name = name 
    @income_amount = amount  
  end
end