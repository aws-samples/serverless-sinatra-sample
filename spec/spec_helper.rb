require_relative '../app/server.rb'
require 'rack/test'

RSpec.configure do |config|
  config.before(:each) do
    FeedbackServerlessSinatraTable.configure_client(client: stub_client)
  end
end

def app
  Sinatra::Application
end

def stub_client
  @stub_client ||= begin
    Aws::DynamoDB::Client.new(stub_responses: true) # don't send real calls to DynamoDB in test env
  end
end
