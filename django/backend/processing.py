import tensorflow as tf
import PIL
import base64
import matplotlib.pyplot as plt
import numpy as np
import difflib
from io import BytesIO

IMG_MAX_DIM = 512

def get_encoded_img(filepath):
    with open(filepath, mode='rb') as img_file:
        img = img_file.read()
        return base64.encodebytes(img).decode('utf-8')

def load_img(img_bytes):
  img = base64.decodebytes(img_bytes.encode('utf-8'))
  img = tf.image.decode_jpeg(img, channels=3)
  img = tf.image.convert_image_dtype(img, tf.float32)

  shape = tf.cast(tf.shape(img)[:-1], tf.float32)
  long_dim = max(shape)
  scale = IMG_MAX_DIM / long_dim

  new_shape = tf.cast(shape * scale, tf.int32)

  img = tf.image.resize(img, new_shape)

  # reshape to 1xWxHx3
  img = img[tf.newaxis, :]
  return img

def tensor_to_bytes(tensor):
  tensor = tensor*255
  tensor = np.array(tensor, dtype=np.uint8)
  if np.ndim(tensor)>3:
    assert tensor.shape[0] == 1
    tensor = tensor[0]
  pil_img = PIL.Image.fromarray(tensor)
  buffered = BytesIO()
  pil_img.save(buffered, format="JPEG")
  img_str = base64.b64encode(buffered.getvalue())
  return img_str.decode('utf-8')

def tensor_to_img(tensor):
  tensor = tensor*255
  tensor = np.array(tensor, dtype=np.uint8)
  if np.ndim(tensor)>3:
    assert tensor.shape[0] == 1
    tensor = tensor[0]
  return PIL.Image.fromarray(tensor)
  