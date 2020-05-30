from django.shortcuts import render
from . import models
from comments import models as comment_models
from users import models as user_models
from django.http import HttpResponse

def like(request):
    comment_pk = request.GET.get("pk")
    email = request.GET.get("user")
    user = user_models.User.objects.get(username=email)
    comment = comment_models.Comment.objects.get(pk=comment_pk)
    print("like")
    try:
        check_like = models.CommentLike.objects.get(user=user, comment=comment)
        check_like.delete()
        return HttpResponse("ok")
    except models.CommentLike.DoesNotExist:
        like = models.CommentLike.objects.create(user=user, comment=comment)
        like.save()
        return HttpResponse("ok")
