from django.contrib import admin
from . import models


@admin.register(models.Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ("title", "host", "board", "is_deleted", "count_comments",
                    "count_likes", "count_dislikes", "created", "updated")
