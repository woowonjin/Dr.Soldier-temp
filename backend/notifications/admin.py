from django.contrib import admin
from . import models

@admin.register(models.Notification)
class NotiAdmin(admin.ModelAdmin):
    list_display = ("user",
                    "post",
                    "noti_type")