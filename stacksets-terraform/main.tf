provider "aws" {
  region = var.aws_region
}

module "budget_stackset" {
source               = "./modules/budget-stackset" 
budget_name                =var.budget_name
budget_amount             = var.budget_amount  
threshold_percentage      = var.threshold_percentage 
notification_email        = var.notification_email
target_ou                 =var.target_ou
aws_region                =var.aws_region
stack_set_name            =var.stack_set_name
}