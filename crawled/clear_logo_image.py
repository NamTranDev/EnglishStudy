import cv2
import numpy as np


def main():
    input_image_path = '/Users/namtrandev/Project/MyGithub/EnglishStudy/assets/image/vocabulary_bye.jpeg'
    output_logo_path = '/Users/namtrandev/Downloads/test_remove_logo.png'
    # remove_logo(input_image_path,output_logo_path)

    img = cv2.imread(input_image_path)
    get_watermark(img)
    cv2.imshow("Watermark", img)
    cv2.waitKey(0)


def remove_logo(input_image_path, output_image_path):
    # Read the image
    image = cv2.imread(input_image_path)

    # Define logo dimensions and margins
    logo_width = 120
    logo_height = 160
    margin_bottom = 70
    margin_right = 100

    # Calculate logo position
    x_logo = image.shape[1] - logo_width - margin_right
    y_logo = image.shape[0] - logo_height - margin_bottom

    # Create a binary mask representing the region of the logo
    mask = np.zeros(image.shape[:2], dtype=np.uint8)
    mask[y_logo:y_logo + logo_height, x_logo:x_logo + logo_width] = 255

    # Inpaint the region covered by the logo
    inpainted_region = cv2.inpaint(image, mask, inpaintRadius=3, flags=cv2.INPAINT_NS)

    # Blend the inpainted region with the original image
    alpha = 0.5  # Adjust this value for blending strength
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