## Running Ruby Sinatra on AWS Lambda

This sample code helps get you started with a simple Sinatra web app deployed on AWS Lambda 

What's Here
-----------

This sample includes:

* README.md - this file
* Gemfile - Gem requirements for the sample application
* app/config.ru - this file contains configuration for Rack middleware
* app/server.rb - this file contains the code for the sample service
* app/views - this directory has the template files
* spec/ - this directory contains the RSpec unit tests for the sample application
* template.yml - this file contains the description of AWS resources used by AWS
  CloudFormation to deploy your infrastructure

Getting Started
---------------

These directions assume you want to develop on your local computer, and not
from the Amazon EC2 instance itself. If you're on the Amazon EC2 instance, the
virtual environment is already set up for you, and you can start working on the
code.

To work on the sample code, you'll need to clone your project's repository to your
local computer. If you haven't, do that first. You can find instructions in the
AWS CodeStar user guide.

1. Install bundle

        $ gem install bundle

2. Install Ruby dependencies for this service

        $ bundle install

3. Download the Gems to the local vendor directory

        $ bundle install --deployment
        
4. Create the deployment package (note: if you don't have a S3 bucket, you need to create one):

        $ aws cloudformation package \
            --template-file template.yaml \
            --output-template-file serverless-output.yaml \
            --s3-bucket { your-bucket-name }
            
    Alternatively, if you have SAM CLI installed, you can run the following command 
    which will do the same

        $ sam package \
            --template-file template.yaml \
            --output-template-file serverless-output.yaml \
            --s3-bucket { your-bucket-name }
            
5. Deploying your application

        $ aws cloudformation deploy --template-file serverless-output.yaml \
            --stack-name { your-stack-name } \
            --capabilities CAPABILITY_IAM
    
    Or use SAM CLI

        $ sam deploy \
            --template-file serverless-output.yaml \
            --stack-name { your-stack-name } \
            --capabilities CAPABILITY_IAM


What Do I Do Next?
------------------

If you have checked out a local copy of your repository you can start making changes to the sample code. 

Learn more about Serverless Application Model (SAM) and how it works here: https://github.com/awslabs/serverless-application-model/blob/master/HOWTO.md

AWS Lambda Developer Guide: http://docs.aws.amazon.com/lambda/latest/dg/deploying-lambda-apps.html

How Do I Add Template Resources to My Project?
------------------

To add AWS resources to your project, you'll need to edit the `template.yml`
file in your project's repository. You may also need to modify permissions for
your project's worker roles. After you push the template change, AWS CloudFormation provisions the resources for you.

## License

This library is licensed under the Apache 2.0 License.
