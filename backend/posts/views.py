from django.shortcuts import render
from django.core import serializers
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse, JsonResponse
import json
from django.db import models
from .models import Post
from boards import models as board_models
from users import models as user_models
from datetime import datetime

def documents(request):
    print("/documents")
    if request.method == "GET":
        posts = Post.objects.filter(is_deleted=False).order_by("-created")
        posts_full = []
        for post in posts:
            posts_full.append(post.serializeCustom())
        # post_list = serializers.serialize('json', posts_full)
        posts_json = json.dumps(posts_full)
        return HttpResponse(posts_json, content_type="text/json-comment-filtered")
        
        
@csrf_exempt
def post_create(request):
    title = request.GET.get("title")
    text = request.GET.get("content")
    user = user_models.User.objects.get(username="dndnjswls918@naver.com")
    board = board_models.Board.objects.get(title="All")
    post = Post.objects.create(title=title, text=text, host=user, board=board)
    post.save()
    return HttpResponse("ok")