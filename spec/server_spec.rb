require 'spec_helper'

set :environment, :test

# Tests for server.rb
describe 'HelloWorld Service' do
  include Rack::Test::Methods

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

  it "should POST params to feedback endpoint with success" do
    expect(stub_client)
      .to receive(:put_item)
      .with({
        :condition_expression=>be_kind_of(String),
        :expression_attribute_names=>be_kind_of(Hash),
        :item=>
         {"feedback"=>"AWS Lambda + Ruby == <3",
          "id"=>be_kind_of(String),
          "name"=>"Tomas",
          "ts"=>be_within(3).of(Time.now.to_i)},
        :table_name=>"FeedbackServerlessSinatraTable"})
      .and_call_original

    post '/api/feedback', name: "Tomas", feedback: "AWS Lambda + Ruby == <3"

    expect(last_response).to be_ok
  end
end
