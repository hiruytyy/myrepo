variable "budget_name" {
  description = "The name of the AWS budget."
  type        = string
   
}

variable "budget_amount" {
  description = "The monthly budget limit in USD."
  type        = number
 
}

variable "threshold_percentage" {
  description = "The percentage of the budget that triggers the alert."
  type        = number
 
}

variable "notification_email" {
  description = "The email address to receive budget alerts."
}


variable "stack_set_name" {
  description = " Name for the CFT stack set"
  type        = string
   
}


variable "target_ou" {
  description = "The AWS Organizations Organizational Unit (OU) where the budget is targeted or tagged."
  type        = list(string)
   
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
   
}
