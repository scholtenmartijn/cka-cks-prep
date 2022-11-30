import aws_cdk as core
import aws_cdk.assertions as assertions

from cdk_k8s.cdk_k8s_stack import CdkK8SStack

# example tests. To run these tests, uncomment this file along with the example
# resource in cdk_k8s/cdk_k8s_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = CdkK8SStack(app, "cdk-k8s")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
