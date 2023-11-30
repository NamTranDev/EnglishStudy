import json
import os
import shutil
import sqlite3

from crawled.db.db import create_database, database_exists,path_db


def main():
    toeic_dir = 'crawled/toeic'
    toeic_name = 'toeic'

    categorized_dir = toeic_dir

    category_name = toeic_name

    dir_folder_image = categorized_dir+'/image'
    dir_folder_audio = categorized_dir+'/audio'

    if not os.path.isdir(dir_folder_image):
        os.mkdir(dir_folder_image)

    if not os.path.isdir(dir_folder_audio):
        os.mkdir(dir_folder_audio)
        
    path = path_db

    if not database_exists(path):
        create_database(path)
        print("Database created.")

    conn = sqlite3.connect(path)
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM topics')
    list_topic = cursor.fetchall()

    first_or_default_topic = next((topic for topic in list_topic 
                                           if topic[1] == 'Toeic' 
                                           if topic[2] == 'topic_toeic.webp' 
                                           and topic[3] == '50 lessons' 
                                           and topic[4] == '600 words' 
                                           and topic[5] == 'The 600 Essential Words for the TOEIC is a study guide that enhances English vocabulary for workplace communication, essential for the TOEIC test, featuring definitions, example sentences' 
                                           ), None)
    
    if first_or_default_topic is None:
        first_or_default_topic = {
                    'topic_name':'Toeic',
                    'topic_image':'topic_toeic.webp',
                    'number_lessons':'50 lessons',
                    'total_words':'600 words',
                    'description_topic':'The 600 Essential Words for the TOEIC is a study guide that enhances English vocabulary for workplace communication, essential for the TOEIC test, featuring definitions, example sentences',
                    'link_topic':'',
                    }
        cursor.execute('''
                INSERT INTO topics (
                    topic_name, topic_image, number_lessons, total_words, description_topic, link_topic, category
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                'Toeic', 'topic_toeic.webp', '50 lessons', '600 words', 'The 600 Essential Words for the TOEIC is a study guide that enhances English vocabulary for workplace communication, essential for the TOEIC test, featuring definitions, example sentences', '', category_name
            ))
        id_topic = cursor.lastrowid
    else:
        id_topic = first_or_default_topic[0]

    cursor.execute('SELECT * FROM sub_topics WHERE topic_id = ?', (id_topic,))
    sub_topics_db = cursor.fetchall()

    file_json_topic_path = '/Users/namtrandev/Project/MyGithub/LearnPython/practice4/600WordToiec/Topic.json'
    with open(file_json_topic_path, 'r') as file:
        sub_topics = json.load(file)
    file_json_word_path = '/Users/namtrandev/Project/MyGithub/LearnPython/practice4/600WordToiec/Word.json'
    with open(file_json_word_path, 'r') as file:
        words = json.load(file)
    for sub_topic in sub_topics:
        sub_topic_name = sub_topic['topic_en']
        sub_topic_image = sub_topic['image']
        sub_topic_id = sub_topic['id']
        sub_topic_name_vi = sub_topic['topic_vi']

        dir_sourc_img = '/Users/namtrandev/Project/MyGithub/LearnPython/practice4/topic_image'
        if os.path.exists(dir_folder_image + '/' + sub_topic_image) is False:
            if os.path.exists(dir_sourc_img + '/' + image_vocabulary_name):
                shutil.copy2(dir_folder_image + '/' + sub_topic_image, dir_sourc_img + '/' + image_vocabulary_name)

        filter_condition = lambda word: word['id_topic'] == sub_topic_id
        filtered_word = list(filter(filter_condition, words))
        filtered_word_size = len(filtered_word)
        first_or_default_sub_topic = next((sub_topic for sub_topic in sub_topics_db 
                                           if sub_topic[2] == sub_topic_name 
                                           and sub_topic[3] == filtered_word_size + ' Words' 
                                           and sub_topic[5] == sub_topic_image 
                                           ), None)
        if first_or_default_sub_topic is None:
            cursor.execute('''
                        INSERT INTO sub_topics (
                            topic_id, sub_topic_name, number_sub_topic_words, link_sub_topic,sub_topic_image
                        ) VALUES (?, ?, ?, ?)
                    ''', (
                        id_topic, sub_topic_name, filtered_word_size + ' Words','',sub_topic_image
                    ))
            id_sub_topic = cursor.lastrowid
        else:
            id_sub_topic = first_or_default_sub_topic[0]

        cursor.execute('SELECT * FROM vocabulary WHERE sub_topic_id = ?', (id_sub_topic,))
        words_db = cursor.fetchall()

        for word in filtered_word:
            vocabulary = word['vocabulary']
            image_vocabulary_name = word['image']
            word_type = word['from_type']
            description = word['explain_en']
            description_vi = word['explain_vi']
            example = word['example_en']
            example_vi = word['example_vi']
            spelling = word['spelling']
            audio = word['audio']
            
            dir_sourc_img = '/Users/namtrandev/Project/MyGithub/LearnPython/practice4/topic_image'
            if os.path.exists(dir_folder_image + '/' + image_vocabulary_name) is False:
                if os.path.exists(dir_sourc_img + '/' + image_vocabulary_name):
                    shutil.copy2(dir_folder_image + '/' + image_vocabulary_name, dir_sourc_img + '/' + image_vocabulary_name)

            first_or_default_word = next((word for word in words_db  
                                            if word[2] == vocabulary 
                                            and word[3] == image_vocabulary_name 
                                            and word[4] == word_type 
                                            and word[5] == description
                                            ), None)
            
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

            cursor.execute('SELECT * FROM examples WHERE vocabulary_id = ?', (id_vocabulary,))
            examples_db = cursor.fetchall()
            first_or_default_example = next((example_db for example_db in examples_db  
                                            if example_db[2] == example), None)
            
            if first_or_default_example is None:
                cursor.execute('''
                                        INSERT INTO examples (
                                            vocabulary_id, example
                                        ) VALUES (?, ?)
                                    ''', (
                                        id_vocabulary, example
                                    ))
                

            cursor.execute('SELECT * FROM spelling WHERE vocabulary_id = ?', (id_vocabulary,))
            spellings_db = cursor.fetchall()
            first_or_default_spelling = next((spelling_db for spelling_db in spellings_db  
                                            if spelling_db[2] == spelling), None)
            
            if first_or_default_spelling is None:
                cursor.execute('''
                                        INSERT INTO spelling (
                                            vocabulary_id, spelling_text
                                        ) VALUES (?, ?)
                                    ''', (
                                        id_vocabulary, spelling
                                    ))
                
            cursor.execute('SELECT * FROM audio WHERE vocabulary_id = ?', (id_vocabulary,))
            audios_db = cursor.fetchall()
            first_or_default_audio = next((audio_db for audio_db in audios_db  
                                            if audio_db[2] == audio), None)
            
            dir_sourc_audio = '/Users/namtrandev/Project/MyGithub/LearnPython/practice4/audio'
            if os.path.exists(dir_folder_audio + '/' + audio) is False:
                if os.path.exists(dir_sourc_audio + '/' + audio):
                    shutil.copy2(dir_folder_audio + '/' + audio, dir_sourc_audio + '/' + audio)    
            
            if first_or_default_audio is None:
                cursor.execute('''
                                        INSERT INTO spelling (
                                            vocabulary_id, audio_file
                                        ) VALUES (?, ?)
                                    ''', (
                                        id_vocabulary, audio
                                    ))

main()