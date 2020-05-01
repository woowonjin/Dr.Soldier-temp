from django.contrib import admin
from . import models


@admin.register(models.vacation)
class VacationAdmin(admin.ModelAdmin):
    list_display = ("user", "date")