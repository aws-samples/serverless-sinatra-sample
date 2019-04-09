require 'sinatra'
require 'aws-record'

before do
  if (! request.body.read.empty? and request.body.size > 0)
    request.body.rewind
    @params = Sinatra::IndifferentHash.new
    @params.merge!(JSON.parse(request.body.read))
  end
end

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
  string_attr :name
  string_attr :feedback
  epoch_time_attr :ts
end

get '/feedback' do
  erb :feedback
end

get '/api/feedback' do
  content_type :json
  items = FeedbackServerlessSinatraTable.scan()
  items
    .map { |r| { :ts => r.ts, :name => r.name, :feedback => r.feedback } }
    .sort { |a, b| a[:ts] <=> b[:ts] }
    .to_json
end

post '/api/feedback' do
  content_type :json
  item = FeedbackServerlessSinatraTable.new(id: SecureRandom.uuid, ts: Time.now)
  item.name = params[:name]
  item.feedback = params[:feedback]
  item.save! # raise an exception if save fails

  item.to_h.to_json
end
