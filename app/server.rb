require 'sinatra'
require 'aws-record'

##################################
# For the index page
##################################
get '/' do
  erb :index
end

##################################
# Return a Hello world JSON
##################################
get '/hello-world' do
  content_type :json
  { :Output => 'Hello World!' }.to_json
end

post '/hello-world' do
    content_type :json
    { :Output => 'Hello World!' }.to_json
end

##################################
# Web App with a DynamodDB table
##################################

# Class for DynamoDB table
# This could also be another file you depend on locally.
class FeedbackServerlessSinatraTable
  include Aws::Record
  string_attr :id, hash_key: true
  string_attr :data
  epoch_time_attr :ts
end

get '/feedback' do
  erb :feedback
end

get '/api/feedback' do
  content_type :json
  ret = []
  items = FeedbackServerlessSinatraTable.scan()
  items.each do |r|
    item = { :ts => r.ts, :data => r.data }
    ret.push(item)
  end
  ret.sort { |a, b| a[:ts] <=> b[:ts] }.to_json
end

post '/api/feedback' do
  content_type :json
  body = env["rack.input"].gets
  item = FeedbackServerlessSinatraTable.new(id: SecureRandom.uuid, ts: Time.now, data: body)
  item.save! # raise an exception if save fails
  item.to_json
end