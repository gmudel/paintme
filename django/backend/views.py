from djangoproject import settings
from django.shortcuts import render
from django.http import HttpResponse
import json
import requests
import os
from random import choice
import base64

# Create your views here.
def random(request):
    static_root = settings.STATIC_ROOT
    path = os.path.join(static_root, "vincentvangogh")

    resp = {}
    filename = choice(os.listdir(path))
    filepath = os.path.join(path, filename)
    with open(filepath, mode='rb') as img_file:
        img = img_file.read()
        resp['img'] = base64.encodebytes(img).decode('utf-8')

    data = json.dumps(resp)
    return HttpResponse(data, content_type='application/json')

def artist(request, artist):
    return

def paintme(request, style_img, content_img):
    return
