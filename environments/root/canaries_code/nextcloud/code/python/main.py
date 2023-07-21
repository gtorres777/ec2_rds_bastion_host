from aws_synthetics.selenium import synthetics_webdriver as syn_webdriver
from aws_synthetics.common import synthetics_logger as logger
import json
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait

def extract_json_from_page_source(page_source):
    start_index = page_source.find("{")
    end_index = page_source.rfind("}") + 1
    json_data = page_source[start_index:end_index]
    return json_data

def nextcloud_health_check(url):
    browser = syn_webdriver.Chrome()

    try:
        logger.info("Connecting to URL ...")
        browser.get(url)

        # Wait for the page to load completely before extracting the page source
        WebDriverWait(browser, 10)

        logger.info("RECIEN PAGE")

        # Get the page source JSON response
        page_source = browser.page_source

        # Extract JSON content from the page source
        json_data = extract_json_from_page_source(page_source)
        logger.info("JSON DATA")
        logger.info(json_data)

        # Parse the JSON response
        parsed_json = json.loads(json_data)
        logger.info("PARSED JSON")
        logger.info(parsed_json)


        # Extract and validate the HTTP status code
        status_code = browser.execute_script("return window.performance.getEntries()[0]?.responseStatus")
        logger.info("RESPONSE STATUS")
        logger.info(status_code)
        if status_code == 200:
            logger.info("HTTP status code is 200 OK.")
        else:
            raise Exception(f"HTTP status code is not 200 OK. Status: {status_code}")

        # Extract and validate the installed and maintenance fields in the JSON response
        installed = parsed_json.get("installed", False)
        maintenance = parsed_json.get("maintenance", False)
        if installed:
            logger.info("Nextcloud is installed and healthy.")
        else:
            raise Exception("Nextcloud is not installed or not healthy.")

        if maintenance:
            logger.info("Nextcloud is in maintenance mode.")
        else:
            raise Exception("Nextcloud is not in maintenance mode.")

        logger.info("Canary successfully executed.")

    except Exception as e:
        logger.error(f"Failed to load page! ERROR: {str(e)}")

        # Save a screenshot on failure
        browser.save_screenshot("loaded.png")

        raise

    finally:
        # Close the WebDriver
        browser.quit()

def handler(event, context):
    logger.info("Selenium Python heartbeat canary.")
    url = "https://cloud.gustavo-td.com/status.php"
    nextcloud_health_check(url)
