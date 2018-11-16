require 'json'
require 'rack'

$app ||= Rack::Builder.parse_file("#{File.dirname(__FILE__)}/app/config.ru").first

def handler(event:, context:)

  p "Request received ..."
  # enironment required by Rack (http://www.rubydoc.info/github/rack/rack/file/SPEC)
  env = {
    "REQUEST_METHOD" => event['httpMethod'],
    "SCRIPT_NAME" => "",
    "PATH_INFO" => event['path'] || "",
    "QUERY_STRING" => event['queryStringParameters'] || "",
    "SERVER_NAME" => "localhost",
    "SERVER_PORT" => 443,
    
    "rack.version" => Rack::VERSION,
    "rack.url_scheme" => "https",
    "rack.input" => StringIO.new(event['body'] || ""),
    "rack.errors" => $stderr,
  }
  
  unless event['header'].nil?
    event['headers'].each{ |key, value| env[key] = "HTTP_#{value}" }
  end
  
  begin
    status, headers, body = $app.call(env)

    body_content = ""
    body.each do |item|
      body_content += item.to_s
    end
  
    response = {
      "statusCode" => status,
      "headers" => headers,
      "body" => body_content
    }
  rescue Exception => msg
    response = {
      "statusCode" => 500,
      "body" => msg
    }
  end
  
  response
end
