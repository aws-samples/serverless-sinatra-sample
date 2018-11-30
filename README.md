## Running Ruby Sinatra on AWS Lambda

This sample code helps get you started with a simple Sinatra web app deployed on AWS Lambda. It is tested with Ruby 2.5.x. 

What's Here
-----------

This sample includes:

* README.md - this file
* Gemfile - Gem requirements for the sample application
* app/config.ru - this file contains configuration for Rack middleware
* app/server.rb - this file contains the code for the sample service
* app/views - this directory has the template files
* spec/ - this directory contains the RSpec unit tests for the sample application
* template.yaml - this file contains the description of AWS resources used by AWS
  CloudFormation to deploy your serverless application
* pipeline-cfn.yaml - this is the CloudFormation template to create the CodePipeline and the other needed resources. You need to fork the repo if you use a personal GitHub token
* buildspec.yml - this file contains build commands used by AWS CodeBuild

Getting Started
---------------

These directions assume you already have Ruby 2.5.x and [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed and configured. Please fork the repo and create an [access token](https://github.com/settings/tokens/new) if you want to create a [CodePipeline](https://aws.amazon.com/codepipeline/) to deploy the app. The pipeline-cfn.yaml template can be used to automate the process.

To work on the sample code, you'll need to clone your project's repository to your local computer. If you haven't, do that first. You can find a guide [here](https://help.github.com/articles/cloning-a-repository/).

1. Install bundle

        $ gem install bundler

2. Install Ruby dependencies for this service

        $ bundle install

3. Download the Gems to the local vendor directory

        $ bundle install --deployment

4. Create the deployment package (note: if you don't have a S3 bucket, you need to create one):

        $ aws cloudformation package \
            --template-file template.yaml \
            --output-template-file serverless-output.yaml \
            --s3-bucket { your-bucket-name }
            
    Alternatively, if you have [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) installed, you can run the following command 
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

To add AWS resources to your project, you'll need to edit the `template.yaml`
file in your project's repository. You may also need to modify permissions for
your project's IAM roles. After you push the template change, AWS CloudFormation provisions the resources for you.

## License

This library is licensed under the Apache 2.0 License.
