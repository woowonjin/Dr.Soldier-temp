from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from . import models as user_models
from django.contrib.auth import authenticate, login, logout
from django.http import HttpResponse, JsonResponse


@csrf_exempt
def login(request):
    uid = request.GET.get("uid")
    email = request.GET.get("email")
    nickname = request.GET.get("nickname")
    method = request.GET.get("method")
    try:
        user = user_models.User.objects.get(uid=uid)
        response = {"result": "no"}
        return JsonResponse(response, status=201)
    except user_models.User.DoesNotExist:
        if(method == "kakao"):
            user = user_models.User.objects.create(
                uid=uid,
                username=uid,
                nickname=nickname,
                login_method=user_models.User.LOGIN_KAKAO,
            )
            user.set_unusable_password()
            user.save()
            response = {"result": "create"}
            return JsonResponse(response, status=201)
        elif(method == "apple"):
            user = user_models.User.objects.create(
                uid=uid,
                username=uid,
                nickname=nickname,
                login_method=user_models.User.LOGIN_APPLE,
            )
            user.set_unusable_password()
            user.save()
            response = {"result": "create"}
            return JsonResponse(response, status=201)
