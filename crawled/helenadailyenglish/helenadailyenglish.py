import json
import os
import sqlite3
import sys
import time

from bs4 import BeautifulSoup
import requests

from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

sys.path.append('/Users/namtrandev/Project/MyGithub/EnglishStudy/crawled/db')
from db import create_database, database_exists,path_db

def write_json(datas):
    with open("crawled/helenadailyenglish/data.json", "w") as outfile:
        json.dump(datas, outfile)

def list_json():
    json_data = [] 
    try:
        with open('crawled/helenadailyenglish/data.json') as json_file:  
            json_data = json.load(json_file)
    except:
        pass
    return json_data

def main():
    url = 'https://helenadailyenglish.com/basic-english-conversation-100-daily-topics'
    helenadailyenglish_dir = 'crawled/helenadailyenglish/'
    name = 'helenadailyenglish'

    categorized_dir = helenadailyenglish_dir
    
    if not os.path.isdir(categorized_dir):
        os.mkdir(categorized_dir)

    path = path_db
    if database_exists(path):
        create_database(path)  
        print("Database created.")

    conn = sqlite3.connect(path)
    cursor = conn.cursor()

    chrome_options = Options()
    chrome_options.add_extension('/Users/namtrandev/Downloads/AdBlock-—-best-ad-blocker.crx')
    chrome_options.add_argument("--disable-notifications")
    driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()),options=chrome_options)
    
    driver.maximize_window()

    time.sleep(5)

    driver.switch_to.window(driver.window_handles[0])

    soup = BeautifulSoup(requests.get(url).content, 'lxml')
    div = soup.find("div", {"class": "td-page-content tagdiv-type"})
    lessions = div.find_all('a')
    for lession in lessions:
        title_root = lession.text
        colon_index = title_root.find(':')
        title_root = title_root[colon_index + 1:].strip()
        link = lession['href']

        isExist = False
        datas_json = list_json()
        for item in datas_json:
            if title_root.lower() in item['conversation_lession'].lower():
                item['conversation_lession'] = item['conversation_lession'].lower().capitalize()
                isExist = True
                break
        if isExist:
            print(title_root)
            continue
        
        driver.get(link)

        time.sleep(10)

        content = driver.page_source
        lession_soup = BeautifulSoup(content, 'lxml')
        div = lession_soup.find('div',{'id':'ftwp-postcontent'})
        titles = div.find_all('h3')
        audios = div.find_all('audio')
        scripts = div.find_all('ul')

        if(len(titles) > 0 and len(titles) == len(audios) == len(scripts)):
            for i in range(len(titles)):
                title = titles[i].find('strong').text
                colon_index = title.find(':')
                title = title[colon_index + 1:].strip()
                # print(title)
                audio = audios[i].find('source')['src']
                # print(audio)
                script = scripts[i].find_all('li')
                # print(script)
                isExist = False
                datas_json = list_json()
                for item in datas_json:
                    if title.lower() in item['conversation_lession'].lower():
                        isExist = True
                        break
                if isExist:
                    print(title)
                    continue
                else:
                    datas_json.append({"conversation_lession":title,"audio":audio,"transcript":[li.get_text(strip=True) for li in script]})
                    write_json(datas_json)
                
    write_json(datas_json)
                
main()