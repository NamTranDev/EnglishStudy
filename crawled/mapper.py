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

        # convert_file_path(c)
        # conn.commit()

        create_resource_default(c)

        # move_file_to_assets(c,path_root,'toeic')
        # zip_topic(c,path_root,'toeic')
           
    except Error as e:
        print(e)
    finally:
        if conn:
            conn.close()

def create_resource_default(c):
    path_assets_image = 'assets/image'
    path_assets_audio = 'assets/audio'
    root_folder = 'crawled/resource_default'
    check_file_exist_or_makedir(root_folder)
    categories = c.execute("SELECT * FROM category").fetchall()
    for category in categories:
        count = 0
        key = category[0]
        query = "SELECT * FROM topics where category='" + str(key) + "'"
        print(query)
        topics = c.execute(query).fetchall()
        for topic in topics:
            id_topic = topic[0]
            topic_name = topic[1]
            topic_image = topic[2]
            category_name = topic[9]
            print(id_topic)
            print(topic_name)
            print(category_name)
            folder_category = root_folder + '/' + category_name
            check_file_exist_or_makedir(folder_category)
            folder_topic = folder_category + '/resource_default_' + topic_name
            check_file_exist_or_makedir(folder_topic)
            if topic_image is not None:
                copy_file(path_assets_image,folder_topic,topic_image)
            

            sub_topics = c.execute('SELECT * FROM sub_topics where topic_id=' + str(id_topic)).fetchall()
            for sub_topic in sub_topics:
                sub_id = sub_topic[0]
                sub_image = sub_topic[5]
                if sub_image is not None:
                    copy_file(path_assets_image,folder_topic,sub_image)
                if(count > 0):
                    continue
                vocabularys = c.execute('SELECT * FROM vocabulary where sub_topic_id =' + str(sub_id)).fetchall()
                for vocabulary in vocabularys:
                    id = vocabulary[0]
                    image = vocabulary[3]
#                     update_query = """
#     UPDATE vocabulary
#     SET image_file_path = ?
#     WHERE id = ?
# """
#                     c.execute(update_query, (category_name + '/' + 'resource_default_' + topic_name + '/' + image, id))
                    if image is not None:
                        copy_file(path_assets_image,folder_topic,image)
                    audios = c.execute('SELECT * FROM audio where vocabulary_id =' + str(id)).fetchall()
                    for audio in audios:
                        audio_file = audio[2]
#                         update_query = """
#     UPDATE audio
#     SET audio_file_path = ?
#     WHERE audio_file_name = ? and vocabulary_id = ?
# """
#                         c.execute(update_query, (category_name + '/' + 'resource_default_' + topic_name + '/' + audio_file,audio_file, id))
                        if audio_file is not None:
                            copy_file(path_assets_audio,folder_topic,audio_file)
                count += 1
            conversations = c.execute('SELECT * FROM conversation where topic_id=' + str(id_topic)).fetchall()
            for conversation in conversations:
                if count > 4:
                    break
                id = conversation[0]
                audios = c.execute('SELECT * FROM audio_conversation where conversation_id =' + str(id)).fetchall()
                for audio in audios:
                    audio_file = audio[2]
#                     update_query = """
#     UPDATE audio_conversation
#     SET audio_file_path = ?
#     WHERE audio_file_name = ? and conversation_id = ?
# """
#                     c.execute(update_query, (category_name + '/' + 'resource_default_' + topic_name + '/' + audio_file,audio_file, id))
                    if audio_file is not None:
                        copy_file(path_assets_audio,folder_topic,audio_file)
                count += 1

def check_file_exist_or_makedir(path):
    if not os.path.exists(path): 
            os.makedirs(path)

def copy_file(source_folder, destination_folder,file_name):
    path = source_folder+'/'+file_name
    if not os.path.exists(path):
        return
    if(os.path.exists(destination_folder + '/'+file_name)):
        return
    try:
        shutil.move(path, destination_folder)
        print(f"Đã sao chép tệp '{path}' thành công vào '{destination_folder}'.")
    except FileNotFoundError:
        print("Không tìm thấy tệp nguồn.")
    except PermissionError:
        print("Không có quyền truy cập để sao chép tệp.")
    except Exception as e:
        print(f"Lỗi không xác định: {e}")

def convert_file_path(c):
    topics = c.execute("SELECT * FROM topics").fetchall()
    for topic in topics:
        id_topic = topic[0]
        topic_name = topic[1]
        category = topic[7]
        sub_topics = c.execute('SELECT * FROM sub_topics where topic_id=' + str(id_topic)).fetchall()
        for sub_topic in sub_topics:
            sub_id = sub_topic[0]
            vocabularys = c.execute('SELECT * FROM vocabulary where sub_topic_id =' + str(sub_id)).fetchall()
            for vocabulary in vocabularys:
                id = vocabulary[0]
                image = vocabulary[3]
                if image is not None:
                    update_query = """
    UPDATE vocabulary
    SET image_file_path = ?
    WHERE id = ?
"""
                    c.execute(update_query, (category + '/' + topic_name + '/image/' + image, id))
                audios = c.execute('SELECT * FROM audio where vocabulary_id =' + str(id)).fetchall()
                for audio in audios:
                    audio_file = audio[2]
                    if audio_file is not None:
                        update_query = """
    UPDATE audio
    SET audio_file_path = ?
    WHERE audio_file_name = ? and vocabulary_id = ?
"""
                        c.execute(update_query, (category + '/' + topic_name + '/audio/' + audio_file, audio_file,id))
                
                

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