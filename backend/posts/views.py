from django.shortcuts import render
from django.core import serializers
from django.http import HttpResponse, JsonResponse
import json
# Create your views here.

from .models import Post

def documents(request):
    print("/documents")
    posts = Post.objects.filter(is_deleted__isnull=False)
    post_list = serializers.serialize('json', posts)
    print(post_list)
    print(type(post_list))
    # print(json.loads(post_list))
    # print(type(json.loads(json.loads(post_list))))
    return HttpResponse(post_list, content_type="text/json-comment-filtered")
'''
    return JsonResponse({
        'message' : '안녕 파이썬 장고',
        'items' : ['파이썬', '장고', 'AWS', 'Azure'],
    }, json_dumps_params = {'ensure_ascii': True})
'''
    