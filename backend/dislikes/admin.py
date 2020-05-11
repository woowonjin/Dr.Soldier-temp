from django.contrib import admin
from . import models


@admin.register(models.Dislike)
class DislikeAdmin(admin.ModelAdmin):
    list_display = ("user", "post")
