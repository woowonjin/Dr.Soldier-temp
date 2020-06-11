from django.urls import path
from . import views

app_name = "comments"

urlpatterns = [
    path("create/", views.comment_create, name="create"),
    path("", views.comments, name="comment")
]