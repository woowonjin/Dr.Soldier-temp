from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from users import models as user_models
from posts import models as post_models
from . import models as like_models
import json


def likes(request):
    post_pk = request.GET.get("pk")
    uid = request.GET.get("user")
    user = user_models.User.objects.get(uid=uid)
    post = post_models.Post.objects.get(pk=post_pk)
    try:
        check_like = like_models.Like.objects.get(user=user, post=post)
        check_like.delete()
        response = {"result": "delete"}
        return JsonResponse(response, status=201)
    except like_models.Like.DoesNotExist:
        like = like_models.Like.objects.create(user=user, post=post)
        like.save()
        response = {"result": "create"}
        return JsonResponse(response, status=201)
