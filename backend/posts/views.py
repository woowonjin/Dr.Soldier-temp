from django.shortcuts import render
from django.core import serializers
from django.http import HttpResponse, JsonResponse
import json
from django.db import models
from django.db.models import Count
from .models import Post

def documents(request):
    print("/documents")

    posts = Post.objects.filter(is_deleted=False).annotate(number_likes = Count("likes"))
    print(type(posts))
    post_list = serializers.serialize('json', posts)
    print(type(post_list))
    
    return HttpResponse(post_list, content_type="text/json-comment-filtered")
'''
    return JsonResponse({
        'message' : '안녕 파이썬 장고',
        'items' : ['파이썬', '장고', 'AWS', 'Azure'],
    }, json_dumps_params = {'ensure_ascii': True})
'''
    