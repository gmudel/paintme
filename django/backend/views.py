from djangoproject import settings
from django.shortcuts import render
from django.http import HttpResponse, HttpResponseNotAllowed
import json
import requests
import os
from random import sample
import base64

# returns 10 random images from the pool of style images
def random(request):
    if request != "GET":
        return HttpResponseNotAllowed(("GET",))
    static_root = settings.STATIC_ROOT
    path = os.path.join(static_root, "vincentvangogh")

    resp = {'imgs': []}
    filenames = sample(os.listdir(path), 10)
    for filename in filenames:
        filepath = os.path.join(path, filename)
        with open(filepath, mode='rb') as img_file:
            img = img_file.read()
            encoded_img = base64.encodebytes(img).decode('utf-8')
            resp['imgs'].append(encoded_img)

    data = json.dumps(resp)
    return HttpResponse(data, content_type='application/json')

def artist(request, artist, offset):

    return

def paintme(request, style_img, content_img):
    return
