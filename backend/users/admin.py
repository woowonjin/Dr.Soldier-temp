from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from . import models


@admin.register(models.User)
class UserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (("CustomProfile", {
        "fields": (
            "nickname",
            "login_method",
        )
    }), )

    list_display = (
        "username",
        "nickname",
        "login_method",
    )
