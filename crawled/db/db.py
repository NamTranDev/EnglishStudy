import os
import sqlite3

path_db = 'assets/english.db'

def database_exists(db_file):
    return os.path.exists(db_file)

def create_database(db_file):
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_name TEXT,
        topic_image TEXT,
        number_lessons TEXT,
        total_words TEXT,
        description_topic TEXT,
        link_topic TEXT,
        category Text
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS sub_topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER,
        sub_topic_name TEXT,
        number_sub_topic_words TEXT,
        link_sub_topic TEXT,
        FOREIGN KEY (topic_id) REFERENCES topics (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS vocabulary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sub_topic_id BIGINT,
        vocabulary TEXT,
        image TEXT,
        word_type TEXT,
        description TEXT,
        isError BOOLEAN,
        FOREIGN KEY (sub_topic_id) REFERENCES sub_topics (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS spelling (
        id BIGINT PRIMARY KEY,
        vocabulary_id BIGINT,
        spelling_text TEXT,
        FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS audio (
        id BIGINT PRIMARY KEY,
        vocabulary_id BIGINT,
        audio_file TEXT,
        FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS examples (
        id BIGINT PRIMARY KEY,
        vocabulary_id BIGINT,
        example TEXT,
        FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS conversation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER,
        conversation_lession TEXT,
        FOREIGN KEY (topic_id) REFERENCES topics (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS audio_conversation (
        id BIGINT PRIMARY KEY,
        conversation_id BIGINT,
        audio_file_name TEXT,
        audio_file_path TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversation (id)
    )
''')
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS transcript (
        id BIGINT PRIMARY KEY,
        conversation_id BIGINT,
        script TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversation (id)
    )
''')
    conn.commit()
    conn.close()