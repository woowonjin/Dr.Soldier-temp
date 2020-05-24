from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from . import models as user_models
from django.contrib.auth import authenticate, login, logout

@csrf_exempt
def kakao_login(request):
    email = request.GET.get("email")
    nickname = request.GET.get("nickname")
    try:
        user = user_models.User.objects.get(username=email)
        return HttpResponse(f"pk: {user.pk}")
    except user_models.User.DoesNotExist:
        user = user_models.User.objects.create(
            username = email,
            nickname = nickname,
            login_method=user_models.User.LOGIN_KAKAO,
        )
        user.set_unusable_password()
        user.save()
        return HttpResponse(f"pk: {user.pk}")