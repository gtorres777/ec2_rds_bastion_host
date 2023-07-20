from aws_synthetics.selenium import synthetics_webdriver as syn_webdriver
from aws_synthetics.common import synthetics_logger as logger
import boto3

def main():

    url = "http://11.0.3.151"

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

        if takeScreenshot:
            browser.save_screenshot("loaded.png")

        raise Exception(f"Failed to load page! with ERROR {str(e)}")

def handler(event, context):
    logger.info("Selenium Python heartbeat canary.")
    return main()

