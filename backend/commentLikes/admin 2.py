from django.contrib import admin
from . import models

@admin.register(models.CommentLike)
class CommentLikeAdmin(admin.ModelAdmin):
    list_display = ("user", "comment")
