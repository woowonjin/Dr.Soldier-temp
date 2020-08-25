from django.shortcuts import render
from . import models
from comments import models as comment_models
from users import models as user_models
from django.http import HttpResponse, JsonResponse


def dislike(request):
    comment_pk = request.GET.get("pk")
    uid = request.GET.get("user")
    user = user_models.User.objects.get(uid=uid)
    comment = comment_models.Comment.objects.get(pk=comment_pk)
    try:
        check_dislike = models.CommentDislike.objects.get(
            user=user, comment=comment)
        check_dislike.delete()
        response = {"result": "delete"}
        return JsonResponse(response, status=201)
    except models.CommentDislike.DoesNotExist:
        dislike = models.CommentDislike.objects.create(
            user=user, comment=comment)
        dislike.save()
        response = {"result": "create"}
        return JsonResponse(response, status=201)
