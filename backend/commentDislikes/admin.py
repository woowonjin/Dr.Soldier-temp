from django.contrib import admin
from . import models

@admin.register(models.CommentDislike)
class CommentLikeAdmin(admin.ModelAdmin):
    list_display = ("user", "comment")
