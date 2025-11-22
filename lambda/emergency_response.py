import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("🚨 DDoS Alarm Triggered!")
    client = boto3.client('wafv2', region_name='us-east-1')
    
    acl_name = os.environ['WEB_ACL_NAME']
    acl_id = os.environ['WEB_ACL_ID']
    
    try:
        response = client.get_web_acl(Name=acl_name, Scope='CLOUDFRONT', Id=acl_id)
        current_acl = response['WebACL']
        token = response['LockToken']
        
        rules = current_acl['Rules']
        for rule in rules:
            if rule['Name'] == 'RateLimit':
                rule['Statement']['RateBasedStatement']['Limit'] = 100
                break
        
        client.update_web_acl(
            Name=acl_name, Scope='CLOUDFRONT', Id=acl_id,
            DefaultAction=current_acl['DefaultAction'],
            Rules=rules,
            VisibilityConfig=current_acl['VisibilityConfig'],
            LockToken=token
        )
        logger.info("✅ Rate limit lowered to 100")
    except Exception as e:
        logger.error(str(e))
        raise e
