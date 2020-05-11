from django.urls import path
from . import views

app_name = "users"

urlpatterns = [
    path("kakaologin/", views.kakao_login, name="kakao-login"),
]