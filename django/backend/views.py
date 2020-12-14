from djangoproject import settings
from django.shortcuts import render
from django.http import HttpResponse, HttpResponseNotAllowed
import json
import requests
import os
from random import sample
import base64

def get_encoded_img(filename):
    filepath = os.path.join(path, filename)
    with open(filepath, mode='rb') as img_file:
        img = img_file.read()
        return base64.encodebytes(img).decode('utf-8')

# returns 10 random images from the pool of style images
def random(request):
    if request.method != "GET":
        return HttpResponseNotAllowed(("GET",))
    resp = {'imgs': []}
    static_root = settings.STATIC_ROOT
    path = os.path.join(static_root, "vincentvangogh")

    filenames = sample(os.listdir(path), 10)
    for filename in filenames:
        encoded_img = get_encoded_img(filename)
        resp['imgs'].append(encoded_img)

    data = json.dumps(resp)
    return HttpResponse(data, content_type='application/json')

def artist(request, artist, offset):
    if request.method != "GET":
        return HttpResponseNotAllowed(("GET",))
    resp = {'imgs': []}
    static_root = settings.STATIC_ROOT
    path = os.path.join(static_root, artist)

    all_filenames = os.listdir(path)
    startrange = offset * 10
    endrange = min(len(all_filenames), startrange + 10)
    selected_filenames = all_filenames[startrange:endrange]

    for filename in selected_filenames:
        encoded_img = get_encoded_img(filename)
        resp['imgs'].append(encoded_img)
    data = json.dumps(resp)
    return HttpResponse(data, content_type='application/json')

def paintme(request, style_img, content_img):
    return
