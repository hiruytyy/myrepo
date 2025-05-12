provider "aws" {
  region = var.aws_region
}

resource "aws_cloudformation_stack_set" "example" {
  name                      = var.stack_set_name
  capabilities              = ["CAPABILITY_NAMED_IAM"]
  permission_model          = "SERVICE_MANAGED"
  description               = "This code creates an AWS IAM Role with administrative access"

  template_body = <<-YAML
    AWSTemplateFormatVersion: '2010-09-09'

    Description: "Basic Budget test"

    Parameters:

      budgetname:
        Description: "Name of  budget"
        Type: Number

      budgetamount:
        Description: "The monthly budget limit in USD."
        Type: Number

      thresholdpercentage:
        Description: "The percentage of the budget that triggers the alert."
        Type: Number

      notificationemail:
        Description: "The email address to receive budget alerts."
        Type: String

    Resources:
      BudgetExample:
        Type: "AWS::Budgets::Budget"
        Properties:
          Budget:
            BudgetName: !Ref budgetname
            BudgetLimit:
              Amount: !Ref budgetamount
              Unit: USD
            TimeUnit: MONTHLY
            BudgetType: COST
          NotificationsWithSubscribers:
            - Notification:
                NotificationType: ACTUAL
                ComparisonOperator: GREATER_THAN
                Threshold: !Ref thresholdpercentage
              Subscribers:
                - SubscriptionType: EMAIL
                  Address: !Ref notificationemail
  YAML

  parameters = {
 
    budgetname          = var.budget_name
    budgetamount        = var.budget_amount 
    thresholdpercentage = var.threshold_percentage 
    notificationemail   = var.notification_email
  }

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  operation_preferences {
    failure_tolerance_count  = 1
    max_concurrent_count     = 1
  }
}

resource "aws_cloudformation_stack_set_instance" "example_instance" {
  stack_set_name = aws_cloudformation_stack_set.example.name

  deployment_targets {
    organizational_unit_ids = var.target_ou
  }

  depends_on = [aws_cloudformation_stack_set.example]
}
