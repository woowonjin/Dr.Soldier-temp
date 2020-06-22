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
    try:
        cal = vacation_models.Vacation.objects.get(user=user, date=date)
        if(calendar_type == "5"):
            cal.delete()
            response = {"result" : "delete"}
            return JsonResponse(response, status=201)
        else:
            if(calendar_type == "1"):
                cal_type = vacation_models.Vacation.VACATION
                cal.calendar_type = cal_type
                cal.save()
            elif(calendar_type == "2"):
                cal_type = vacation_models.Vacation.TRAINING
                cal.calendar_type = cal_type
                cal.save()
            elif(calendar_type == "3"):
                cal_type = vacation_models.Vacation.OUTING
                cal.calendar_type = cal_type
                cal.save()
            elif(calendar_type == "4"):
                cal_type = vacation_models.Vacation.DISPATCH
                cal.calendar_type = cal_type
                cal.save()
            response = {"result" : "revise"}
            return JsonResponse(response, status=201)
    
    except vacation_models.Vacation.DoesNotExist:
        if(calendar_type == "5"):
            response = {"result" : "Nothing"}
            return JsonResponse(response, status=201)
        else:
            if(calendar_type == "1"):
                cal_type = vacation_models.Vacation.VACATION
                cal_new = vacation_models.Vacation.objects.create(user=user, date=date, calendar_type=cal_type)
                cal_new.save()
            elif(calendar_type == "2"):
                cal_type = vacation_models.Vacation.TRAINING
                cal_new = vacation_models.Vacation.objects.create(user=user, date=date, calendar_type=cal_type)
                cal_new.save()
            elif(calendar_type == "3"):
                cal_type = vacation_models.Vacation.OUTING
                cal_new = vacation_models.Vacation.objects.create(user=user, date=date, calendar_type=cal_type)
                cal_new.save()
            elif(calendar_type == "4"):
                cal_type = vacation_models.Vacation.DISPATCH
                cal_new = vacation_models.Vacation.objects.create(user=user, date=date, calendar_type=cal_type)
                cal_new.save()
            response = {"result" : "create"}
            return JsonResponse(response, status=201)

def get_vacation(request):
    user_email = request.GET.get("user")
    try:
        user = user_models.User.objects.get(username=user_email)
        vacations = vacation_models.Vacation.objects.all().filter(user=user)
        vacations_full = []
        for vacation in vacations:
            vacations_full.append(vacation.serializeCustom())
        vacation_json = json.dumps(vacations_full)
        return HttpResponse(vacation_json, content_type="text/json-comment-filtered")
    except user_models.User.DoesNotExist:
        response = {"result" : "fail"}
        return JsonResponse(response, status=201)