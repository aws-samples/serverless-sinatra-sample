# MIT No Attribution

# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'json'
require 'rack'
require 'base64'

# Global object that responds to the call method. Stay outside of the handler
# to take advantage of container reuse
$app ||= Rack::Builder.parse_file("#{File.dirname(__FILE__)}/app/config.ru").first

def handler(event:, context:)
  # Check if the body is base64 encoded. If it is, try to decode it
  if event["isBase64Encoded"]
    body = Base64.decode64(event['body'])
  else
    body = event['body']
  end
  # Rack expects the querystring in plain text, not a hash
  querystring = Rack::Utils.build_query(event['queryStringParameters']) if event['queryStringParameters']
  # Environment required by Rack (http://www.rubydoc.info/github/rack/rack/file/SPEC)
  env = {
    "REQUEST_METHOD" => event['httpMethod'],
    "SCRIPT_NAME" => "",
    "PATH_INFO" => event['path'] || "",
    "QUERY_STRING" => querystring || "",
    "SERVER_NAME" => "localhost",
    "SERVER_PORT" => 443,
    "CONTENT_TYPE" => event['headers']['content-type'],

    "rack.version" => Rack::VERSION,
    "rack.url_scheme" => "https",
    "rack.input" => StringIO.new(body || ""),
    "rack.errors" => $stderr,
  }
  # Pass request headers to Rack if they are available
  unless event['headers'].nil?
    event['headers'].each{ |key, value| env["HTTP_#{key}"] = value }
  end

  begin
    # Response from Rack must have status, headers and body
    status, headers, body = $app.call(env)

    # body is an array. We simply combine all the items to a single string
    body_content = ""
    body.each do |item|
      body_content += item.to_s
    end

    # We return the structure required by AWS API Gateway since we integrate with it
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    response = {
      "statusCode" => status,
      "headers" => headers,
      "body" => body_content
    }
    if event["requestContext"].has_key?("elb")
      # Required if we use application load balancer instead of API GW
      response["isBase64Encoded"] = false
    end
  rescue Exception => msg
    # If there is any exception, we return a 500 error with an error message
    response = {
      "statusCode" => 500,
      "body" => msg
    }
  end
  # By default, the response serializer will call #to_json for us
  response
end
