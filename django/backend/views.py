from djangoproject import settings
from django.shortcuts import render
from django.http import HttpResponse, HttpResponseNotAllowed
from django.views.decorators.csrf import csrf_exempt
import json
import requests
import os
from random import sample
import base64

from .apps import BackendConfig
from .processing import *

# returns 10 random images from the pool of style images
def random(request):
    if request.method != "GET":
        return HttpResponseNotAllowed(("GET",))
    resp = {'imgs': []}
    static_root = settings.STATIC_ROOT
    path = os.path.join(static_root, "vincentvangogh")

    filenames = sample(os.listdir(path), 10)
    for filename in filenames:
        filepath = os.path.join(path, filename)
        encoded_img = get_encoded_img(filepath)
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
        filepath = os.path.join(path, filename)
        encoded_img = get_encoded_img(filepath)
        resp['imgs'].append(encoded_img)
    data = json.dumps(resp)
    return HttpResponse(data, content_type='application/json')

@csrf_exempt
def paintme(request):
    #if request.method != "GET":
    #    return HttpResponseNotAllowed(("GET",))
    
    #d = base64.decodebytes(recvd)

    body = json.loads(request.body.decode('utf-8'))
    content_img_bytes = body['content_img']
    style_img_bytes = body['style_img']

    resp = {'img' : None}

    content_img = load_img(content_img_bytes)
    style_img = load_img(style_img_bytes)

    painted_img = BackendConfig.model(content_img, style_img)[0]
    resp['img'] = tensor_to_bytes(painted_img)

    data = json.dumps(resp)
    return HttpResponse(data, content_type='application/json')

