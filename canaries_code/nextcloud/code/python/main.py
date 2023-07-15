from aws_synthetics.selenium import synthetics_webdriver as syn_webdriver
from aws_synthetics.common import synthetics_logger as logger
import boto3

def main():

    url = "https://cloud.gustavo-td.com"
    sns_client = boto3.client('sns')
    sns_topic_arn = 'arn:aws:sns:us-east-1:111355452311:slack-topic'
    subject = "Failed to access Nextcloud"

    # Set screenshot option
    takeScreenshot = True

    browser = syn_webdriver.Chrome()

    try:
        logger.info("Connecting to URL ...")
        browser.get(url)

        if takeScreenshot:
            browser.save_screenshot("loaded.png")

        response_code = syn_webdriver.get_http_response(url)

        logger.info("Canary successfully executed.")

        if not response_code or response_code < 200 or response_code > 299:
            raise Exception("Failed to load page!")

    except Exception as e:

        print(f"ERROR MESSAGE: {str(e)}")
        sns_message = f"Failed to access Nextcloud, Error: {str(e)}"
        sns_client.publish(TopicArn=sns_topic_arn, Message=sns_message, Subject=subject)

        print(f"sns message sent: {sns_message}")

        if takeScreenshot:
            browser.save_screenshot("loaded.png")


        raise Exception("Failed to load page!")

def handler(event, context):
    logger.info("Selenium Python heartbeat canary.")
    return main()

