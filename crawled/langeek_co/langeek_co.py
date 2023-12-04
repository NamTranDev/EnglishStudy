import json
import shutil
import sqlite3
from sqlite3 import Error
import time
from bs4 import BeautifulSoup
import requests
import re
import os


from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import sys
sys.path.append('/Users/namtrandev/Project/MyGithub/EnglishStudy/crawled/db')
from db import create_database, database_exists,path_db

index = 2
log_link = None
log_word = None
log_sub_topic = None

def clean_database(db_file):
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    # Find vocabulary IDs with isError = True
    cursor.execute('SELECT id FROM vocabulary WHERE isError = ?', (1,))
    error_vocabulary_ids = [row[0] for row in cursor.fetchall()]

    print(error_vocabulary_ids)

    # Delete records from spelling table
    for vocabulary_id in error_vocabulary_ids:
        cursor.execute('DELETE FROM spelling WHERE vocabulary_id = ?', (vocabulary_id,))

    # Delete records from audio table
    for vocabulary_id in error_vocabulary_ids:
        cursor.execute('DELETE FROM audio WHERE vocabulary_id = ?', (vocabulary_id,))

    # Delete records from examples table
    for vocabulary_id in error_vocabulary_ids:
        cursor.execute('DELETE FROM examples WHERE vocabulary_id = ?', (vocabulary_id,))

    # Delete records from vocabulary table
    cursor.execute('DELETE FROM vocabulary WHERE isError = ?', (1,))

    # Commit changes and close the connection
    conn.commit()
    conn.close()

    print("Clean Success")

def main():
    CEFR_Wordlist_url = 'https://langeek.co/en/vocab/level-based';
    CEFR_Wordlist_dir = 'crawled/langeek_co/CEFR_Wordlist'
    CEFR_Wordlist_name = 'CEFR_Wordlist'
    

    categorized_dir = CEFR_Wordlist_dir

    category_name = CEFR_Wordlist_name

    dir_folder_image = categorized_dir+'/image'
    dir_folder_audio = categorized_dir+'/audio'

    if not os.path.isdir(categorized_dir):
        os.mkdir(categorized_dir)
        
    path = path_db
    if not database_exists(path):
        create_database(path)
        print("Database created.")
    else:
        clean_database(path)
        print("Database already exists.")

    conn = sqlite3.connect(path)
    cursor = conn.cursor()

    soup_parent = BeautifulSoup(requests.get(CEFR_Wordlist_url).content, 'lxml')
    images = soup_parent.find_all('img')
    
    for image in images:
        if '0_.125rem_.25rem_rgba(0,0,0,.075' in image.prettify():
            
            parent = image.parent.parent

            topic_name = parent.find('h3').text
            number_lessons_words = parent.find_all('p')[0].text.split(' - ')
            number_lessons = number_lessons_words[0]
            total_words = number_lessons_words[1]
            description_topic = parent.find_all('p')[1].text
            link_topic = parent.find('a')['href']
            link_image_topic = image['src']

            cursor.execute('SELECT * FROM topics')
            list_topic = cursor.fetchall()

            if '/assets/img/no-pic.png' == link_image_topic:
                image_topic_name = None
            else:
                image_topic_name = 'topic_' + topic_name.lower() + '.jpeg'
                download(link_image_topic,dir_folder_image,image_topic_name)

            # print(link_topic)

            first_or_default_topic = next((topic for topic in list_topic 
                                           if topic[1] == topic_name 
                                           and topic[2] == image_topic_name 
                                           and topic[3] == number_lessons 
                                           and topic[4] == total_words 
                                           and topic[5] == description_topic 
                                           and topic[6] == link_topic
                                           ), None)
            if first_or_default_topic is None:
                first_or_default_topic = {
                    'topic_name':topic_name,
                    'topic_image':image_topic_name,
                    'number_lessons':number_lessons,
                    'total_words':total_words,
                    'description_topic':description_topic,
                    'link_topic':link_topic,
                    }
                cursor.execute('''
                INSERT INTO topics (
                    topic_name, topic_image, number_lessons, total_words, description_topic, link_topic, category
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                topic_name, image_topic_name, number_lessons, total_words, description_topic, link_topic, category_name
            ))
                id_topic = cursor.lastrowid
            else:
                id_topic = first_or_default_topic[0]
                
            soup_children = BeautifulSoup(requests.get('https://langeek.co' + link_topic).content, 'lxml')
            titles = soup_children.find_all('h3')
            cursor.execute('SELECT * FROM sub_topics WHERE topic_id = ?', (id_topic,))
            sub_topics = cursor.fetchall()

            for title in titles:
                parent_child = title.parent.parent.parent.parent.parent
                sub_topic_name = parent_child.find('h3').text
                number_sub_topic_words = parent_child.find('h6').text.split(' - ')[0]
                link_sub_topic = parent_child.find_all('a')[1]['href']

                first_or_default_sub_topic = next((sub_topic for sub_topic in sub_topics 
                                           if sub_topic[2] == sub_topic_name 
                                           and sub_topic[3] == number_sub_topic_words 
                                           and sub_topic[4] == link_sub_topic 
                                           ), None)
                if first_or_default_sub_topic is None:
                    cursor.execute('''
                        INSERT INTO sub_topics (
                            topic_id, sub_topic_name, number_sub_topic_words, link_sub_topic
                        ) VALUES (?, ?, ?, ?)
                    ''', (
                        id_topic, sub_topic_name, number_sub_topic_words,link_sub_topic
                    ))
                    id_sub_topic = cursor.lastrowid
                else:
                    id_sub_topic = first_or_default_sub_topic[0]
                    

                cursor.execute('SELECT * FROM vocabulary WHERE sub_topic_id = ?', (id_sub_topic,))
                words = cursor.fetchall()

                if len(words) == int(number_sub_topic_words.split(' ')[0]):
                    print('From topic : ' + topic_name + '\nDone sub topic : ' + sub_topic_name)
                    continue
                
                time_load = 6
                time_wait = 1

                # link_child = '/en/vocab/subcategory/3999/learn'
                link_sub_topic_path = 'https://langeek.co' + link_sub_topic
                # link_sub_topic_path = 'https://langeek.co/en/vocab/subcategory/17/learn'
                soup_words = BeautifulSoup(requests.get(link_sub_topic_path).content, 'lxml')
                words_soup = soup_words.find_all("h6")
                driver = webdriver.Chrome()
                driver.get(link_sub_topic_path)
                time.sleep(time_load)

                try:
                    driver.find_element(by=By.XPATH,value="""//*[@id="__next"]/div/main/div[2]/div/div[2]/button[2]""").click()
                except:
                    pass

                time.sleep(time_wait)

                driver.find_element(by=By.TAG_NAME,value='html').send_keys(Keys.END)

                # time.sleep(time_wait)
                # driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                global index 
                index = 2
                for word in words_soup:
                    if 'class="text-muted"' in word.prettify():
                        
                        parent_word = word.parent.parent.parent.parent.parent.parent
                        # /assets/img/no-pic.png => No Image
                        image_vocabulary = parent_word.find('img')['src']
                        vocabulary = parent_word.find("div", {"class": "tw-text-[1.75rem] sm:tw-text-[2rem] font-quicksand-bold"}).text
                        vocabulary = re.sub(r"[^\x00-\x7F]+", '', vocabulary)     
                        if'/' in vocabulary:
                            click_next(driver,time_wait,False)
                            continue
                        if 'to be' != vocabulary and 'to ' == vocabulary[0:3]:
                            vocabulary = vocabulary[3:]
                        spelling = parent_word.find('h6').text
                        word_type = parent_word.find('small').text
                        description = parent_word.find("div", {"class": "ReviewCardFron_wordTranslation__qn3g5"}).text

                        if '/assets/img/no-pic.png' == image_vocabulary:
                            image_vocabulary_name = None
                        else:
                            image_vocabulary_name = 'vocabulary_' + vocabulary + '.jpeg'
                            download(image_vocabulary,dir_folder_image,image_vocabulary_name)

                        first_or_default_word = next((word for word in words  
                                           if word[2] == vocabulary 
                                           and word[3] == image_vocabulary_name 
                                           and word[4] == word_type 
                                           and word[5] == description
                                           ), None)
                        
                        global log_link
                        global log_word
                        global log_sub_topic
                        log_link = None
                        log_word = None
                        log_sub_topic = None
                        
                        if first_or_default_word is None:
                            first_or_default_word = {
                                'vocabulary' : vocabulary,
                                'image' : image_vocabulary_name,
                                'word_type' : word_type,
                                'description' : description,
                            }
                            cursor.execute('''
                                INSERT INTO vocabulary (
                                    sub_topic_id, vocabulary, image, word_type, description, isError
                                ) VALUES (?, ?, ?, ?, ?, ?)
                            ''', (
                                id_sub_topic, vocabulary, image_vocabulary_name, word_type, description, False
                            ))
            
                            id_vocabulary = cursor.lastrowid
                        else:
                            id_vocabulary = first_or_default_word[0]
                            #  isError
                            if first_or_default_word[6] == 0:
                                click_next(driver,time_wait,False)
                                continue

                        log_link = link_sub_topic_path
                        log_word = vocabulary
                        log_sub_topic = sub_topic_name

                        word_search = vocabulary.replace(' ','-')
                        word_query = vocabulary.replace(' ','+')
                        # 
                        url = 'https://www.oxfordlearnersdictionaries.com/definition/english/'+word_search + "?" + word_query
                        oxford = BeautifulSoup(requests.get(url,allow_redirects=True,headers={
                    "User-Agent" : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
                    }).content, 'lxml')
                        try:
                            frame = oxford.find("div", {"class": "webtop"})
                            word_compair = frame.find('h1').text
                            if vocabulary.strip().lower() == word_compair.strip().lower():
                                
                                audio_uk = frame.find('div',{'class':'sound audio_play_button pron-uk icon-audio'})
                                link_audio_uk = audio_uk['data-src-mp3']
                                audio_uk_vocabulary_name = 'vocabulary_' + vocabulary + '_uk.mp3'
                                download(link_audio_uk,dir_folder_audio,audio_uk_vocabulary_name)


                                audio_us = frame.find('div',{'class':'sound audio_play_button pron-us icon-audio'})
                                link_audio_us = audio_us['data-src-mp3']
                                audio_us_vocabulary_name = 'vocabulary_' + vocabulary + '_us.mp3'
                                download(link_audio_us,dir_folder_audio,audio_us_vocabulary_name)
                                
                                cursor.execute('''
                                    INSERT INTO audio (
                                        vocabulary_id, audio_file
                                    ) VALUES (?, ?)
                                ''', (
                                    id_vocabulary, audio_uk_vocabulary_name
                                ))
                                cursor.execute('''
                                    INSERT INTO audio (
                                        vocabulary_id, audio_file
                                    ) VALUES (?, ?)
                                ''', (
                                    id_vocabulary, audio_us_vocabulary_name
                                ))

                                spelling_frame = frame.find_all('span',{'class':'phon'})
                                
                                cursor.execute('''
                                INSERT INTO spelling (
                                    vocabulary_id, spelling_text
                                ) VALUES (?, ?)
                            ''', (
                                id_vocabulary, spelling_frame[0].text
                            ))
                                cursor.execute('''
                                INSERT INTO spelling (
                                    vocabulary_id, spelling_text
                                ) VALUES (?, ?)
                            ''', (
                                id_vocabulary, spelling_frame[1].text
                            ))

                        except Exception as error:
                            print(error)
                            count = 0
                            while count < 2:
                                count = 2
                                url = 'https://www.howtopronounce.com/' + word_search

                                response = requests.get(url,allow_redirects=True,headers={
                    "User-Agent" : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
                    })
                                if response.status_code == 404:
                                    # count += 1
                                    # if count == 2:
                                    print('Not Found Audio' + "\nLink : " + log_link + "\Sub Topic : " + log_sub_topic+ "\nWord : " + log_word)
                                    # if 'to' == vocabulary[0:2]:
                                    #     word_search = vocabulary[3:-1].strip()
                                    # else:
                                    #     break
                                elif response.status_code == 200:
                                    pronounce = BeautifulSoup(response.content, 'lxml')
                                    audio_pronounce_link = pronounce.find('audio')['src']
                                    audio_vocabulary_name = 'vocabulary_' + vocabulary.replace(' ','_') + '.mp3'
                                    download(audio_pronounce_link,dir_folder_audio,audio_vocabulary_name)

                                    cursor.execute('''
                                        INSERT INTO audio (
                                            vocabulary_id, audio_file
                                        ) VALUES (?, ?)
                                    ''', (
                                        id_vocabulary, audio_vocabulary_name
                                    ))

                                    cursor.execute('''
                                        INSERT INTO spelling (
                                            vocabulary_id, spelling_text
                                        ) VALUES (?, ?)
                                    ''', (
                                        id_vocabulary, spelling
                                    ))
                                    break

                        try:
                            if parent_word.find('h6',{'class','mb-0'}):
                                open_example(driver,time_wait)
                                examples = driver.find_elements(by=By.CLASS_NAME,value="""ExamplesListItem_wrapper__jjv8l""")
                                for example in examples:
                                    cursor.execute('''
                                        INSERT INTO examples (
                                            vocabulary_id, example
                                        ) VALUES (?, ?)
                                    ''', (
                                        id_vocabulary, example.text
                                    ))
                        except Exception as error:
                            print(error)
                            cursor.execute('''
                                UPDATE vocabulary
                                SET isError = ?
                                WHERE id = ?
                            ''', (True, id_vocabulary))
                        
                        # https://www.oxfordlearnersdictionaries.com/definition/english/back-catalogue?q=back+catalogue
                        # div class webtop 
                        conn.commit()
                        click_next(driver,time_wait,parent_word.find('h6',{'class','mb-0'}) is not None)

                driver.quit
                    

def scroll_to_bottom(driver):
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

def download(url,dir,file_name):

    if not os.path.isdir(dir):
        os.mkdir(dir)

    if os.path.exists(dir + '/' + file_name):
        return

    response = requests.get(url, allow_redirects=True,headers={
"User-Agent" : "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
})
    if response.status_code == 404:
        print('Error Not Found')
        print(url)
    open(dir + '/' + file_name, 'wb').write(response.content)
            
def open_example(driver,time_wait):
    example_views = [
        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.swiper-slide-active > div > div > div.ReviewCardFron_side__fjWgA.ReviewCardFron_hasPhoto__alvci.ReviewCardFron_wordReviewCard__J7Mof.undefined.pt-3.position-relative.shadow-sm.card > div.ReviewCardFron_examplesButton__hjqNl.d-flex.justify-content-center.align-items-center.text-white""",

        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.WordsBox_swiperSlideActive__O3wLX.swiper-slide-active > div > div > div.ReviewCardFron_side__fjWgA.null.ReviewCardFron_wordReviewCard__J7Mof.undefined.position-relative.shadow-sm.card > div.ReviewCardFron_examplesButton__hjqNl.d-flex.justify-content-center.align-items-center.text-white""",

        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.swiper-slide-active > div > div > div.ReviewCardFron_side__fjWgA.null.ReviewCardFron_wordReviewCard__J7Mof.undefined.position-relative.shadow-sm.card > div.ReviewCardFron_examplesButton__hjqNl.d-flex.justify-content-center.align-items-center.text-white""",

        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.WordsBox_swiperSlideActive__O3wLX.swiper-slide-active > div > div > div.ReviewCardFron_side__fjWgA.ReviewCardFron_hasPhoto__alvci.ReviewCardFron_wordReviewCard__J7Mof.undefined.pt-3.position-relative.shadow-sm.card > div.ReviewCardFron_examplesButton__hjqNl.d-flex.justify-content-center.align-items-center.text-white""",
        
    ]

    time.sleep(time_wait)

    for _ in range(10):  # Adjust the number of times you want to scroll
        driver.find_element(by = By.TAG_NAME,value = 'body').send_keys(Keys.END)

    click('Click to see examples',driver,time_wait,example_views)
    
    click('See more',driver,time_wait,[
        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.swiper-slide-active > div > div > div.ReviewCardBack_side__8hPGG.ReviewCardBack_hasPhoto__EM1OZ.ReviewCardBack_backSide__ydgZR.card > div.d-flex.justify-content-center.position-relative.py-45 > button""",

        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.WordsBox_swiperSlideActive__O3wLX.swiper-slide-active > div > div > div.ReviewCardBack_side__8hPGG.null.ReviewCardBack_backSide__ydgZR.card > div.d-flex.justify-content-center.position-relative.py-45 > button""",

        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.swiper-slide-active > div > div > div.ReviewCardBack_side__8hPGG.null.ReviewCardBack_backSide__ydgZR.card > div.d-flex.justify-content-center.position-relative.py-45 > button""",

        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.WordsBox_swiperSlideActive__O3wLX.swiper-slide-active > div > div > div.ReviewCardBack_side__8hPGG.ReviewCardBack_hasPhoto__EM1OZ.ReviewCardBack_backSide__ydgZR.card > div.d-flex.justify-content-center.position-relative.py-45 > button"""
        
        """#tabcontainer-tabpane-review > div > div > div.swiper-wrapper.WordsBox_swiperWrapper__LOvCf > div.swiper-slide.WordsBox_cardContainer__YBpRw.WordsBox_swiperSlideActive__O3wLX.swiper-slide-active > div > div > div.ReviewCardFron_side__fjWgA.ReviewCardFron_hasPhoto__alvci.ReviewCardFron_wordReviewCard__J7Mof.undefined.pt-3.position-relative.shadow-sm.card > div.ReviewCardFron_examplesButton__hjqNl.d-flex.justify-content-center.align-items-center.text-white"""
    ])
    
    time.sleep(time_wait)   

def close_popup(driver,time_wait):
    click('Close PopUp',driver,time_wait,[
            """#popup-""" + str(index) + """ > div > div.ExamplesList_xmarkWrapper__cV4sS""",
        ])
    time.sleep(time_wait)

def click(tag_click,driver,time_wait,selectors):
    success = False
    time.sleep(time_wait)
    for selector in selectors:
        try:
            driver.find_element(by=By.CSS_SELECTOR,value=selector).click()
            success = True
            break
        except:
            continue
    global log_link
    global log_word
    global log_sub_topic
    if success is True:
        return
    if(log_link is None and log_sub_topic is None and log_word is None):
        raise Exception("Error click from " + tag_click)
    else:
        raise Exception("Error click from " + tag_click + "\nLink : " + log_link + "\nSub Topic : " + log_sub_topic + "\nWord : " + log_word)

def click_next(driver,time_wait,continue_next = True):
    try:
        if continue_next is True:
            close_popup(driver,time_wait)
    except Exception as error:
        print(error)
    global index
    index += 1
    time.sleep(time_wait)
    driver.find_element(by=By.CSS_SELECTOR,value="""#tabcontainer-tabpane-review > div > div > div.swiper-button-next""").click()

main()