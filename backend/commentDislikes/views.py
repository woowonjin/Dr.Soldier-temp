from django.shortcuts import render
from . import models
from comments import models as comment_models
from users import models as user_models
from django.http import HttpResponse

def dislike(request):
    comment_pk = request.GET.get("pk")
    email = request.GET.get("user")
    user = user_models.User.objects.get(username=email)
    comment = comment_models.Comment.objects.get(pk=comment_pk)
    print("dislike")
    try:
        check_dislike = models.CommentDislike.objects.get(user=user, comment=comment)
        check_dislike.delete()
        return HttpResponse("ok")
    except models.CommentDislike.DoesNotExist:
        dislike = models.CommentDislike.objects.create(user=user, comment=comment)
        dislike.save()
        return HttpResponse("ok")