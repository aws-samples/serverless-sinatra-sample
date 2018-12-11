require 'spec_helper'

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
    expect(json_result["Output"]).to eq("Hello World!")
  end

  it "should POST params to API feedback endpoint with success" do
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

    api_gateway_post('/api/feedback', { name: "Tomas", feedback: "AWS Lambda + Ruby == <3" })

    expect(last_response).to be_ok
  end

  it "should successfuly GET items from API feedback endpoint in right order" do
    stub_client.stub_responses(:scan, :items => [
      {'name' => 'Zdenka', "ts" => 2345678, "feedback" => "Halestorm"},
      {'name' => 'Tomas',  "ts" => 1234567, "feedback" => "Trivium"},
      {'name' => 'xiangshen', "ts" => 5678901, "feedback" => "Awesome !"},
    ])

    get '/api/feedback'
    expect(last_response).to be_ok
    expect(json_result).to match_array([
      { "name" => "Tomas",    "feedback"=>"Trivium",   "ts"=> be_kind_of(String)},
      { "name" => "Zdenka",   "feedback"=>"Halestorm", "ts"=> be_kind_of(String)},
      { "name" => "xiangshen","feedback"=>"Awesome !", "ts"=> be_kind_of(String)}
    ])
  end
end
