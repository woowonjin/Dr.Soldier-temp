from django.shortcuts import render
from django.core import serializers
from django.http import HttpResponse, JsonResponse
import json
from django.db import models
from django.db.models import Count
from .models import Post

def documents(request):
    print("/documents")
    if request.method == "GET":
        posts = Post.objects.filter(is_deleted=False)
        posts_full = []
        for post in posts:
            posts_full.append(post.serializeCustom())
        # post_list = serializers.serialize('json', posts_full)
        posts_json = json.dumps(posts_full)
        return HttpResponse(posts_json, content_type="text/json-comment-filtered")
        
    elif request.method == "POST":
        print("POST")
        print(request.POST["title"])
        print(request.body)
'''
    return JsonResponse({
        'message' : '안녕 파이썬 장고',
        'items' : ['파이썬', '장고', 'AWS', 'Azure'],
    }, json_dumps_params = {'ensure_ascii': True})
'''
    