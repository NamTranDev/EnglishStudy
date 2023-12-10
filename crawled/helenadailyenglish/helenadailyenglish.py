import json
import os
import sqlite3
import sys
import time

from bs4 import BeautifulSoup
import requests

from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
# from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

import sys
sys.path.append('/Users/namtrandev/Project/MyGithub/EnglishStudy/crawled/download')
from download import download_file

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

    chrome_options = Options()
    chrome_options.add_extension('/Users/namtrandev/Downloads/AdBlock-—-best-ad-blocker.crx')
    chrome_options.add_argument("--disable-notifications")
    driver = webdriver.Chrome(options=chrome_options)
    
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

def main2():

    helenadailyenglish_dir = 'crawled/'
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

    datas_json = list_json()

    cursor.execute('SELECT * FROM topic_conversation')
    list_topic = cursor.fetchall()

    topic_name = 'Basic English Conversation: 100 Daily Topics'
    description_topic = 'The topics level for English beginners. If you are a newbie in learning English, they are suitable for you.'

    number_lessons = '100 lessions'

    first_or_default_topic = next((topic for topic in list_topic 
                                           if topic[1] == topic_name 
                                           and topic[2] == description_topic
                                           and topic[3] == number_lessons
                                           and topic[5] == name
                                           ), None)
    
    if first_or_default_topic is None:
        cursor.execute('''
                INSERT INTO topic_conversation (
                    topic_name, description_topic, number_lessons, link_topic, category
                ) VALUES (?, ?, ?, ?, ?)
            ''', (
                topic_name, description_topic, number_lessons, '', name
            ))
        id_topic = cursor.lastrowid
    else:
        id_topic = first_or_default_topic[0]

    for index, item in enumerate(datas_json):
        title = item['conversation_lession']
        title = title.lower().capitalize()
        audio = item['audio']
        transcripts = item['transcript']

        dir_folder = helenadailyenglish_dir + name + '/' + topic_name
        audio_file_name = name + '_' + str(index + 1) + '.mp3'

        full_audio_path = name + '_audio/' + audio_file_name
        download_file(audio,dir_folder,audio_file_name)

        cursor.execute('SELECT * FROM conversation')
        conversations = cursor.fetchall()

        first_or_default_conversation = next((conversation for conversation in conversations  
                                           if conversation[1] == title 
                                           ), None)
        
        if first_or_default_conversation is None:
            cursor.execute('''INSERT INTO conversation (
                                    topic_id,conversation_lession
                                ) VALUES (?, ?)
                            ''', (
                                id_topic, title
                            ))
            
            id_conversation = cursor.lastrowid
        else:
            id_conversation = first_or_default_conversation[0]

        cursor.execute('SELECT * FROM audio_conversation WHERE conversation_id = ?', (id_conversation,))
        audio_conversations = cursor.fetchall()
        first_or_default_conversation_audio = next((audio_conversation for audio_conversation in audio_conversations  
                                           if audio_conversation[2] == full_audio_path 
                                           ), None)
        
        if first_or_default_conversation_audio is None:
            cursor.execute('''INSERT INTO audio_conversation (
                                    conversation_id,audio_file_name,audio_file_path
                                ) VALUES (?, ?, ?)
                            ''', (
                                id_conversation, audio_file_name, full_audio_path
                            ))
            
        for transcript in transcripts:
            cursor.execute('SELECT * FROM transcript WHERE conversation_id = ?', (id_conversation,))
            transcript_conversations = cursor.fetchall()
            first_or_default_conversation_audio = next((transcript_conversation for transcript_conversation in transcript_conversations  
                                           if transcript_conversation[2] == transcript 
                                           ), None)
            
            if first_or_default_conversation_audio is None:
                cursor.execute('''INSERT INTO transcript (
                                        conversation_id,script
                                    ) VALUES (?, ?)
                                ''', (
                                    id_conversation, transcript
                                ))
        conn.commit()
    conn.close()

def main3():

    helenadailyenglish_dir = 'crawled/'
    name = 'helenadailyenglish'

    path = path_db
    conn = sqlite3.connect(path)
    cursor = conn.cursor()

    dir_folder = helenadailyenglish_dir + name + '/' + name + '_audio'

    move_file_to_assets(cursor,dir_folder,name)

def move_file_to_assets(c,path, category):
        topic_conversation = c.execute("SELECT * FROM topic_conversation where category ='" + category+"'").fetchall()
        for topic in topic_conversation:
            id = topic[0]
            name = topic[1]

            conversations = c.execute('SELECT * FROM conversation where topic_id = ' + str(id)).fetchall()
            count = 0
            for conversation in conversations:
                count += 1
                conversation_id = conversation[0]

                if count < 6:
                    audios = c.execute('SELECT * FROM audio_conversation where conversation_id =' + str(conversation_id)).fetchall()
                    for audio in audios:
                        audio_file = audio[2]
                        if audio_file is not None and os.path.exists(path + "/" + audio_file):
                            os.rename(path + "/" + audio_file, 'assets/audio/' + audio_file)
                else :
                    break

main3()