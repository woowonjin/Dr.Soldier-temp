from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse, JsonResponse
import json
from django.core.paginator import Paginator
from django.db import models
from .models import Post
from boards import models as board_models
from users import models as user_models
from datetime import datetime
from likes import models as like_models
from dislikes import models as dislikes_models
from posts import models as post_models

def documents(request):
    posts = Post.objects.filter(is_deleted=False).order_by("-created")
    paginator = Paginator(posts, 20)
    page = request.GET.get("page")

    page_posts = paginator.page(int(page))
    posts_full = []
    for post in page_posts:
        posts_full.append(post.serializeCustom())
    posts_json = json.dumps(posts_full)
    return HttpResponse(posts_json, content_type="text/json-comment-filtered")
        
        
@csrf_exempt
def post_create(request):
    title = request.GET.get("title")
    text = request.GET.get("content")
    user_name = request.GET.get("user")
    user = user_models.User.objects.get(username=user_name)
    board = board_models.Board.objects.get(title="All")
    post = Post.objects.create(title=title, text=text, host=user, board=board)
    post.save()
    return HttpResponse("ok")

def already_likes(request):
    post_pk = request.GET.get("pk")
    email = request.GET.get("user")
    user = user_models.User.objects.get(username=email)
    post = post_models.Post.objects.get(pk=post_pk)
    try:
        like = like_models.Like.objects.get(user=user, post=post)
        try:
            dislike = dislikes_models.Dislike.objects.get(user=user, post=post)
            response = {"like": True,
                        "dislike": True,
                        "likes_number": post.count_likes(),
                        "dislikes_number": post.count_dislikes(),
                        "comments_number": post.count_comments(),
                        }
            return JsonResponse(response, status=201)
        except dislikes_models.Dislike.DoesNotExist:
            response = {"like": True,
                        "dislike": False,
                        "likes_number": post.count_likes(),
                        "dislikes_number": post.count_dislikes(),
                        "comments_number": post.count_comments(),}
            return JsonResponse(response, status=201)
    except like_models.Like.DoesNotExist:
        try:
            dislike = dislikes_models.Dislike.objects.get(user=user, post=post)
            response = {"like": False,
                        "dislike": True,
                        "likes_number": post.count_likes(),
                        "dislikes_number": post.count_dislikes(),
                        "comments_number": post.count_comments(),}
            return JsonResponse(response, status=201)
        except dislikes_models.Dislike.DoesNotExist:
            response = {"like": False,
                        "dislike": False,
                        "likes_number": post.count_likes(),
                        "dislikes_number": post.count_dislikes(),
                        "comments_number": post.count_comments(),}
            return JsonResponse(response, status=201)
    # try:
    #     check_like = like_models.Like.objects.get(user=user, post=post)
    #     response = {"like": True}
    #     return JsonResponse(response, status=201)
    # except like_models.Like.DoesNotExist:
    #     response = {"like": False}
    #     return JsonResponse(response, status=201)

