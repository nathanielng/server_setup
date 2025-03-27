import boto3, os, json

sts_client = boto3.client('sts')
response = sts_client.get_caller_identity()
AWS_ACCOUNT_ID=response['Account']
BUDGET_NAME=os.getenv('BUDGET_NAME', None)
BUDGET_AMOUNT=os.getenv('BUDGET_AMOUNT', None)
EMAIL=os.getenv('EMAIL', None)
if BUDGET_NAME is None or BUDGET_AMOUNT is None or EMAIL is None:
    print('Please specify BUDGET_NAME, BUDGET_AMOUNT, and EMAIL as environment variables')
    exit()

client = boto3.client('budgets')

response = client.create_budget(
    AccountId=AWS_ACCOUNT_ID,
    Budget={
        'BudgetName': BUDGET_NAME,
        'BudgetLimit': {
            'Amount': BUDGET_AMOUNT,
            'Unit': 'USD'
        },
        'TimeUnit': 'MONTHLY',
        'BudgetType': 'COST',
        'CostTypes': {
            'IncludeRefund': False,
            'IncludeCredit': False,
            'IncludeUpfront': True,
            'IncludeRecurring': True,
            'IncludeOtherSubscription': True,
            'IncludeTax': True,
            'IncludeSupport': True,
            'IncludeDiscount': True,
            'IncludeSubscription': True,
            'UseAmortized': False,
            'UseBlended': False
        }
    },
    NotificationsWithSubscribers=[
        {
            'Notification': {
                'NotificationType': 'ACTUAL',
                'ComparisonOperator': 'GREATER_THAN',
                'Threshold': 20.0,
                'ThresholdType': 'PERCENTAGE'
            },
            'Subscribers': [
                {
                    'SubscriptionType': 'EMAIL',
                    'Address': EMAIL
                }
            ]
        },
        {
            'Notification': {
                'NotificationType': 'ACTUAL',
                'ComparisonOperator': 'GREATER_THAN',
                'Threshold': 40.0,
                'ThresholdType': 'PERCENTAGE'
            },
            'Subscribers': [
                {
                    'SubscriptionType': 'EMAIL',
                    'Address': EMAIL
                }
            ]
        },
        {
            'Notification': {
                'NotificationType': 'ACTUAL',
                'ComparisonOperator': 'GREATER_THAN',
                'Threshold': 60.0,
                'ThresholdType': 'PERCENTAGE'
            },
            'Subscribers': [
                {
                    'SubscriptionType': 'EMAIL',
                    'Address': EMAIL
                }
            ]
        },
        {
            'Notification': {
                'NotificationType': 'ACTUAL',
                'ComparisonOperator': 'GREATER_THAN',
                'Threshold': 80.0,
                'ThresholdType': 'PERCENTAGE'
            },
            'Subscribers': [
                {
                    'SubscriptionType': 'EMAIL',
                    'Address': EMAIL
                }
            ]
        },
        {
            'Notification': {
                'NotificationType': 'ACTUAL',
                'ComparisonOperator': 'GREATER_THAN',
                'Threshold': 100.0,
                'ThresholdType': 'PERCENTAGE'
            },
            'Subscribers': [
                {
                    'SubscriptionType': 'EMAIL',
                    'Address': EMAIL
                }
            ]
        }
    ]
)
print(json.dumps(response, indent=2, default=str))
