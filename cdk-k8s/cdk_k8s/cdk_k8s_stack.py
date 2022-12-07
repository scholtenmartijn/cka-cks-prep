from aws_cdk import (
    # Duration,
    Stack,
    # aws_sqs as sqs,
)
from constructs import Construct
import aws_cdk.aws_ec2 as ec2
import aws_cdk.aws_autoscaling as autoscaling

class CdkK8SStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # The code that defines your stack goes here

        vpc = ec2.Vpc(self, "VPC",
            nat_gateways=1,
            max_azs=1
        )

        linux = ec2.GenericLinuxImage({
           "eu-west-1": "ami-096800910c1b781ba"
        })

        key_name = "cka-cks-prep"

        my_security_group = ec2.SecurityGroup(self, "SecurityGroup", vpc=vpc)
        autoscaling.AutoScalingGroup(self, "MasterASG",
            vpc=vpc,
            vpc_subnets=ec2.SubnetSelection(
                subnet_type=ec2.SubnetType.PUBLIC
            ),
            instance_type=ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE2, ec2.InstanceSize.LARGE),
            machine_image=linux,
            security_group=my_security_group,
            associate_public_ip_address=True
            key_name=key_name
        )

        autoscaling.AutoScalingGroup(self, "WorkerASG",
            vpc=vpc,
            vpc_subnets=ec2.SubnetSelection(
                subnet_type=ec2.SubnetType.PUBLIC
            ),
            instance_type=ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE2, ec2.InstanceSize.LARGE),
            machine_image=linux,
            security_group=my_security_group,
            associate_public_ip_address=True
            key_name=key_name
        )