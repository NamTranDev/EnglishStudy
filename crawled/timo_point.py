import time
from selenium import webdriver

index = 0
def main():
    link = """https://www.linkedin.com/posts/tr%E1%BA%A7n-nam-abb185119_lifeattimo-activity-7137250792226357248-c0lI?utm_source=share&utm_medium=member_desktop"""
    driver = webdriver.Chrome()
    driver.get(link)
    driver.maximize_window()
    while True:
        global index 
        index += 1
        time.sleep(5)
        driver.get(link)
        time.sleep(5)
    driver.quit()
main()
