This Lambda function is used to notify the probation-migritaions-team Slack Channel when an ECS task is scheduled for retirement.

The lambda layer must be built in order to run local terragrunt plans. This can be done by running:
```shell
mkdir -p ./lambda_layer/python/lib/python3.9/site-packages

pip3 install -r ./python/requirements.txt -t ./lambda-layer/python/lib/python3.9/site-packages

cd ./lambda_layer

zip -r ../assets/slack_sdk_layer.zip ./python
```