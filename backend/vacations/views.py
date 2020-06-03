from django.shortcuts import render
from . import models as vacation_models
from users import models as user_models
from django.http import HttpResponse, JsonResponse
import json

def vacation_create(request):
    user_email = request.GET.get("user")
    user = user_models.User.objects.get(username=user_email)
    date = request.GET.get("date")
    calendar_type = request.GET.get("type")
    if(calendar_type == "5"):
        cal = vacation_models.Vacation.objects.get(user=user, date=date)
        cal.delete()
        response = {"result" : "delete"}
        return JsonResponse(response, status=201)
    else:
        cal = vacation_models.Vacation.objects.create(user=user, date=date, calendar_type=calendar_type)
        cal.save()
        response = {"result" : "create"}
        return JsonResponse(response, status=201)

def get_vacation(request):
    user_email = request.GET.get("user")
    user = user_models.User.objects.get(username=user_email)
    vacations = vacation_models.Vacation.objects.all()
    vacations_full = []
    for vacation in vacations:
        vacations_full.append(vacation.serializeCustom())
    vacation_json = json.dumps(vacations_full)
    return HttpResponse(vacation_json, content_type="text/json-comment-filtered")