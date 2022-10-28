ENV["RACK-ENV"] = "test" # This is setting the RACK_ENV variable to 'test'

require "minitest/autorun"
require "rack/test" # gives us access to Rack::Test helper methods 

require "minitest/reporters"
Minitest::Reporters.use!

require_relative "../budget"

class BudgeTest < Minitest::Test 
  include Rack::Test::Methods # mixing in Rack::Test::Methods into our class (rely on a method called app)

  def app # returns an instance of a Rack application  
    Sinatra::Application 
  end

  def test_home_page 
    get "/" 
    assert_equal 200, last_response.status 
  end
end