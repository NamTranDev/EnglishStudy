import os
import shutil
import sqlite3
from sqlite3 import Error

def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file, isolation_level=None)
        c = conn.cursor()

        # move_file_to_assets(c)
        zip_topic(c)
           
    except Error as e:
        print(e)
    finally:
        if conn:
            conn.close()

def zip_topic(c):
    topics = c.execute('SELECT * FROM topics').fetchall()
    path_root = 'crawled/langeek_co/CEFR_Wordlist'
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
                    if image is not None and os.path.exists('crawled/langeek_co/CEFR_Wordlist/image/' + image):
                        os.rename('crawled/langeek_co/CEFR_Wordlist/image/' + image, path_image + '/' + image)
                    audios = c.execute('SELECT * FROM audio where vocabulary_id =' + str(id)).fetchall()
                    for audio in audios:
                        audio_file = audio[2]
                        if audio_file is not None and os.path.exists('crawled/langeek_co/CEFR_Wordlist/audio/' + audio_file):
                            os.rename('crawled/langeek_co/CEFR_Wordlist/audio/' + audio_file, path_audio + '/' + audio_file)
    

def move_file_to_assets(c):
        topics = c.execute('SELECT * FROM topics').fetchall()
        for topic in topics:
            image = topic[2]
            if image is not None and os.path.exists('crawled/langeek_co/CEFR_Wordlist/image/' + image):
                os.rename('crawled/langeek_co/CEFR_Wordlist/image/' + image, 'assets/image/' + image)

        sub_topics = c.execute('SELECT * FROM sub_topics').fetchall()
        count = 0
        for sub_topic in sub_topics:
            count += 1
            sub_id = sub_topic[0]
            image = sub_topic[5]
            if image is not None and os.path.exists('crawled/langeek_co/CEFR_Wordlist/image/' + image):
                os.rename('crawled/langeek_co/CEFR_Wordlist/image/' + image, 'assets/image/' + image)

            if count < 6:
                vocabularys = c.execute('SELECT * FROM vocabulary where sub_topic_id =' + str(sub_id)).fetchall()
                for vocabulary in vocabularys:
                    id = vocabulary[0]
                    image = vocabulary[3]
                    if image is not None and os.path.exists('crawled/langeek_co/CEFR_Wordlist/image/' + image):
                        os.rename('crawled/langeek_co/CEFR_Wordlist/image/' + image, 'assets/image/' + image)
                    audios = c.execute('SELECT * FROM audio where vocabulary_id =' + str(id)).fetchall()
                    for audio in audios:
                        audio_file = audio[2]
                        if audio_file is not None and os.path.exists('crawled/langeek_co/CEFR_Wordlist/audio/' + audio_file):
                            os.rename('crawled/langeek_co/CEFR_Wordlist/audio/' + audio_file, 'assets/audio/' + audio_file)

if __name__ == '__main__':
    create_connection('/Users/namtrandev/Project/MyGithub/EnglishStudy/assets/CEFR_Wordlist.db')