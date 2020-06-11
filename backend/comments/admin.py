from django.contrib import admin
from . import models


@admin.register(models.Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ("user", "post", "comment_likes_count", "comment_dislikes_count")
