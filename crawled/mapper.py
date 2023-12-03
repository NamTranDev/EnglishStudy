import os
import shutil
import sqlite3
from sqlite3 import Error

import sys
sys.path.append('/Users/namtrandev/Project/MyGithub/EnglishStudy/crawled/db')
from db import path_db

def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file, isolation_level=None)
        c = conn.cursor()

        path_root = 'crawled/toeic'

        move_file_to_assets(c,path_root,'toeic')
        zip_topic(c,path_root,'toeic')
           
    except Error as e:
        print(e)
    finally:
        if conn:
            conn.close()

def zip_topic(c,path_root,category):
    topics = c.execute("SELECT * FROM topics where category = '" + category + "'").fetchall()
    for topic in topics:
        id_topic = topic[0]
        name = topic[1]
        path = path_root + '/' + name
        path_audio = path + '/' + 'audio'
        path_image = path + '/' + 'image'
        if not os.path.isdir(path):
            os.makedirs(path)
        if not os.path.isdir(path_audio):
            os.makedirs(path_audio)
        if not os.path.isdir(path_image):
            os.makedirs(path_image)

        sub_topics = c.execute('SELECT * FROM sub_topics where topic_id=' + str(id_topic)).fetchall()
        for sub_topic in sub_topics:
            sub_id = sub_topic[0]
            vocabularys = c.execute('SELECT * FROM vocabulary where sub_topic_id =' + str(sub_id)).fetchall()
            for vocabulary in vocabularys:
                    id = vocabulary[0]
                    image = vocabulary[3]
                    if image is not None and os.path.exists(path_root +'/image/' + image):
                        os.rename(path_root + '/image/' + image, path_image + '/' + image)
                    audios = c.execute('SELECT * FROM audio where vocabulary_id =' + str(id)).fetchall()
                    for audio in audios:
                        audio_file = audio[2]
                        if audio_file is not None and os.path.exists(path_root + '/audio/' + audio_file):
                            os.rename(path_root + '/audio/' + audio_file, path_audio + '/' + audio_file)
    

def move_file_to_assets(c,path, category):
        topics = c.execute("SELECT * FROM topics where category ='" + category+"'").fetchall()
        for topic in topics:
            id = topic[0]
            name = topic[1]
            image = topic[2]
            if image is not None and os.path.exists(path + "/" + name + '/image/' + image):
                os.rename(path + "/" + name + '/image/' + image, 'assets/image/' + image)

            sub_topics = c.execute('SELECT * FROM sub_topics where topic_id = ' + str(id)).fetchall()
            count = 0
            for sub_topic in sub_topics:
                count += 1
                sub_id = sub_topic[0]
                image = sub_topic[5]
                if image is not None and os.path.exists(path + "/" + name + '/image/' + image):
                    os.rename(path + "/" + name + '/image/' + image, 'assets/image/' + image)

                if count < 2:
                    vocabularys = c.execute('SELECT * FROM vocabulary where sub_topic_id =' + str(sub_id)).fetchall()
                    for vocabulary in vocabularys:
                        id = vocabulary[0]
                        image = vocabulary[3]
                        if image is not None and os.path.exists(path + "/" + name + '/image/' + image):
                            os.rename(path + "/" + name + '/image/' + image, 'assets/image/' + image)
                        audios = c.execute('SELECT * FROM audio where vocabulary_id =' + str(id)).fetchall()
                        for audio in audios:
                            audio_file = audio[2]
                            if audio_file is not None and os.path.exists(path + "/" + name + '/audio/' + audio_file):
                                os.rename(path + "/" + name + '/audio/' + audio_file, 'assets/audio/' + audio_file)
                else :
                    break
            

if __name__ == '__main__':
    create_connection(path_db)