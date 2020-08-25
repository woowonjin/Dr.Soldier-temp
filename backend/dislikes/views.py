from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from users import models as user_models
from posts import models as post_models
from . import models as dislike_models


def dislikes(request):
    post_pk = request.GET.get("pk")
    uid = request.GET.get("user")
    user = user_models.User.objects.get(uid=uid)
    post = post_models.Post.objects.get(pk=post_pk)
    try:
        dislike_check = dislike_models.Dislike.objects.get(
            user=user, post=post)
        dislike_check.delete()
        response = {"result": "delete"}
        return JsonResponse(response, status=201)
    except dislike_models.Dislike.DoesNotExist:
        dislike = dislike_models.Dislike.objects.create(user=user, post=post)
        dislike.save()
        response = {"result": "create"}
        return JsonResponse(response, status=201)
