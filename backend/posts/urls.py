from django.urls import path
from . import views

app_name = "posts"

urlpatterns = [
    path("info/", views.post_info, name="create"),
    path("create/", views.post_create, name="create"),
]