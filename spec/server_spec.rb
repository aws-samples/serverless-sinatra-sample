require_relative '../app/server.rb'
require 'rack/test'

set :environment, :test

# Tests for server.rb
describe 'HelloWorld Service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Test for HTTP GET for URL-matching pattern '/'
  it "should return successfully on GET" do
    get '/hello-world'
    expect(last_response).to be_ok
    json_result = JSON.parse(last_response.body)
    expect(json_result["Output"]).to eq("Hello World!")
  end

  # Test for HTTP POST for URL-matching pattern '/'
  it "should return successfully on POST" do
    post '/hello-world'
    expect(last_response).to be_ok
    json_result = JSON.parse(last_response.body)
    expect(json_result["Output"]).to eq("Hello World!")
  end
end
