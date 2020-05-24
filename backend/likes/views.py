from django.shortcuts import render
from users import models as user_models
from posts import models as post_models
from . import models as like_models

def likes(request):
    post_pk = request.GET.get("pk")
    email = request.GET.get("user")
    user = user_models.User.objects.get(username=email)
    post = post_models.Post.objects.get(pk=post_pk)

    like = like_models.Like.objects.create(user=user, post=post)
    like.save()
    return
