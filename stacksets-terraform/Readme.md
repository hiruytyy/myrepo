

## Overview

This Terraform configuration automates the deployment of an **AWS Budget Alarm** using a CloudFormation StackSet. It provisions an AWS Budget resource that allows you to track your AWS usage and costs, helping to ensure that your spending stays within defined limits. The budget is configured to trigger an alarm when usage exceeds a certain percentage of the set threshold, which helps to prevent unexpected high costs. By using CloudFormation StackSets, this configuration can be deployed across multiple AWS accounts and regions, providing a centralized way to manage budget alarms in a large organization. The deployment includes parameters such as the budget amount, threshold percentage, and an email address for receiving notifications, ensuring that alerts are sent to the appropriate stakeholders when the budget limit is reached.

In this example, the **AWS::Budgets::Budget** resource is used to create a budget that monitors AWS costs and usage. The configuration includes parameters such as `budget_amount`, `threshold_percentage`, and `notification_email`. The budget is set with a monthly time unit and a cost-based budget type. When the actual usage exceeds the defined threshold percentage, the alarm triggers a notification, and the specified email address is alerted. The budget alarm resource helps organizations maintain cost control by setting predefined limits and alerting key stakeholders when the budget is nearing its limit. By utilizing Terraform and CloudFormation StackSets, this configuration enables efficient, repeatable infrastructure deployments across multiple accounts and regions, ensuring that cost management is consistent and scalable.

 ## input

 
| Variable Name        | Description                                                                 | Type              | Example Value            |
|----------------------|-----------------------------------------------------------------------------|-------------------|--------------------------|
| `budget_name`        | The name of the AWS budget.                                                  | String            | "MonthlyBudget"          |
| `budget_amount`      | The monthly budget limit in USD.                                             | Number            | 500                      |
| `threshold_percentage` | The percentage of the budget that triggers the alert.                        | Number            | 80                       |
| `notification_email` | The email address to receive budget alerts.                                  | String            | "example@example.com"    |
| `stack_set_name`     | Name for the CloudFormation StackSet.                                        | String            | "BudgetStackSet"         |
| `target_ou`          | The AWS Organizations Organizational Unit (OU) where the budget is targeted. | List of Strings    | ["Marketing", "Finance"] |
| `aws_region`         | AWS Region to deploy resources.                                              | String            | "us-east-1"              |
