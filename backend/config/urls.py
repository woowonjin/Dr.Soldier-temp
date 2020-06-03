"""config URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
import posts.views
import users.views
import likes.views
import dislikes.views
from comments import views as comments_views
from commentLikes import views as commentLikes_views
from commentDislikes import views as commentDislikes_views
from comments import views as comments_views
from notifications import views as noti_views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('alreadylikes/', posts.views.already_likes),
    path('alreadyCommentLikes/', comments_views.already_comment_like),
    path('likes/', likes.views.likes),
    path('notification/', noti_views.notification),
    path('read_notification/', noti_views.noti_read),
    path('get-notifications/', noti_views.get_notifications),
    path('get-notifications-num/', noti_views.get_notifications_num),
    path('dislikes/', dislikes.views.dislikes),
    path('documents/', posts.views.documents, name="documents"),
    path('commentLikes/', commentLikes_views.like, name="commentLikes"),
    path('commentDislikes/', commentDislikes_views.dislike, name="commentDislikes"),
    path('posts/', include("posts.urls", namespace="posts")),
    path('comments/', include("comments.urls", namespace="comments")),
    path('users/', include("users.urls", namespace="users")),
]
