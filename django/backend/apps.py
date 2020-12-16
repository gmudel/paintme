from django.apps import AppConfig
from django.conf import settings
import tensorflow as tf
import tensorflow_hub
import numpy as np


class BackendConfig(AppConfig):
    name = 'backend'
    model = tensorflow_hub.load('https://tfhub.dev/google/magenta/arbitrary-image-stylization-v1-256/2')
