import os
import shutil
import cv2
import numpy as np


def main():
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_bye.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_good afternoon.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_good evening.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_good morning.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_good night.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_goodbye.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_hello.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_hi.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_no.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_OK.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_sorry.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_thank you.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_thanks.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_welcome.jpeg'
    # input_image_path = 'crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist/vocabulary_yes.jpeg'
    # remove_logo(input_image_path,get_file_name(input_image_path))

    clone_folders('/Users/namtrandev/Project/MyGithub/EnglishStudy/crawled/resource_default/CEFR_Wordlist/resource_default_A1 Level Wordlist','remove_logo/image')

def get_file_name(image_path):
    return os.path.basename(image_path)

def clone_folders(source_dir, destination_dir):
    if not os.path.exists(destination_dir):
        os.makedirs(destination_dir)
        
    for root, dirs, files in os.walk(source_dir):
        for directory in dirs:
            # Tạo thư mục đích tương ứng với thư mục nguồn
            new_directory = os.path.join(destination_dir, directory)
            os.makedirs(new_directory, exist_ok=True)
        
        for file in files:
            if file.lower().endswith('.jpeg') or file.lower().endswith('.jpg'):
                source_file = os.path.join(root, file)
                destination_file = os.path.join(destination_dir, os.path.relpath(root, source_dir), file)
                remove_logo(source_file,destination_file)
            else:
                source_file = os.path.join(root, file)
                destination_file = os.path.join(destination_dir, os.path.relpath(root, source_dir), file)
                shutil.copyfile(source_file, destination_file)

def remove_logo(input_image_path, output_image_path):
    # Read the image
    image = cv2.imread(input_image_path)

    height, width, channels = image.shape

    print("Chiều rộng của hình ảnh:", width)
    print("Chiều cao của hình ảnh:", height)

    # Define logo dimensions and margins
    logo_width = 120
    logo_height = 160

    # Tính toán margin dựa trên kích thước của hình ảnh và kích thước của logo
    margin_bottom = int(0.115 * height)  # Đổi 0.1 thành tỉ lệ mong muốn
    margin_right = int(0.13 * width)    # Đổi 0.1 thành tỉ lệ mong muốn
    # margin_bottom = 70
    # margin_right = 90

    # Calculate logo position
    x_logo = image.shape[1] - logo_width - margin_right
    y_logo = image.shape[0] - logo_height - margin_bottom

    # Create a binary mask representing the region of the logo
    mask = np.zeros(image.shape[:2], dtype=np.uint8)
    mask[y_logo:y_logo + logo_height, x_logo:x_logo + logo_width] = 255

    # Inpaint the region covered by the logo
    inpainted_region = cv2.inpaint(image, mask, inpaintRadius=3, flags=cv2.INPAINT_NS)

    # Blend the inpainted region with the original image
    alpha = 0.005  # Adjust this value for blending strength
    result = image.copy()
    result[y_logo:y_logo + logo_height, x_logo:x_logo + logo_width] = cv2.addWeighted(image[y_logo:y_logo + logo_height, x_logo:x_logo + logo_width], alpha, inpainted_region[y_logo:y_logo + logo_height, x_logo:x_logo + logo_width], 1 - alpha, 0)

    # Save the image with the logo removed
    cv2.imwrite(output_image_path, result)

def process(img):
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_blur = cv2.GaussianBlur(img_gray, (3, 3), 0)
    img_canny = cv2.Canny(img_blur, 161, 54)
    img_dilate = cv2.dilate(img_canny, None, iterations=1)
    return cv2.erode(img_dilate, None, iterations=1)

def get_watermark(img):
    contours, _ = cv2.findContours(process(img), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    img.fill(255)
    for cnt in contours:
        if cv2.contourArea(cnt) > 100:
            cv2.drawContours(img, [cnt], -1, 0, -1)

main()