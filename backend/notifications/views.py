from django.shortcuts import render
from posts import models as post_models
from users import models as user_models
from . import models as noti_models
from django.http import HttpResponse, JsonResponse
import json


def notification(request):
    post_pk = request.GET.get("post_pk")
    user_email = request.GET.get("user")
    post = post_models.Post.objects.get(pk = post_pk)
    user = user_models.User.objects.get(username = user_email)
    noti_type_temp = request.GET.get("type")
    if noti_type_temp == "like":
        noti_type = noti_models.Notification.LIKE
        noti = noti_models.Notification.objects.create(user=user, post=post, noti_type=noti_type)
    elif noti_type_temp == "like_cancel":
        noti_type = noti_models.Notification.LIKE_CANCEL
        noti = noti_models.Notification.objects.create(user=user, post=post, noti_type=noti_type)
    elif noti_type_temp == "dislike":
        noti_type = noti_models.Notification.DISLIKE
        noti = noti_models.Notification.objects.create(user=user, post=post, noti_type=noti_type)
    elif noti_type_temp == "dislike_cancel":
        noti_type = noti_models.Notification.DISLIKE_CANCEL
        noti = noti_models.Notification.objects.create(user=user, post=post, noti_type=noti_type)
    elif noti_type_temp == "comment":
        noti_type = noti_models.Notification.COMMENT
        noti = noti_models.Notification.objects.create(user=user, post=post, noti_type=noti_type)

def get_notifications(request):
    user_email = request.GET.get("user")
    user = user_models.User.objects.get(username=user_email)
    notifications = noti_models.Notification.objects.filter(user=user).order_by("-created")
    noti_full = []
    for noti in notifications:
        noti_full.append(noti.serializeCustom())
    noti_json = json.dumps(noti_full)
    return HttpResponse(noti_json, content_type="text/json-comment-filtered")
