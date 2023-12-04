import os

import requests


def download_file(url,dir,file_name):

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
    else:
        open(dir + '/' + file_name, 'wb').write(response.content)