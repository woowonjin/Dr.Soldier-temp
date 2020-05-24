from django.contrib import admin
from . import models


@admin.register(models.Like)
class LikeAdmin(admin.ModelAdmin):
    class Meta:
        order_by = ("-created")
    list_display = ("user", "post")
