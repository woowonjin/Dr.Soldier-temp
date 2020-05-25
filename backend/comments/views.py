from django.shortcuts import render
from . import models
import json
from django.http import HttpResponse, JsonResponse
from posts import models as post_models
from users import models as user_models
from boards import models as board_models
from .models import Comment
from django.views.decorators.csrf import csrf_exempt

def comments(request):
    print("comments")
    pk = request.GET.get("pk")
    comments = models.Comment.objects.filter(post=pk).filter(is_deleted=False)
    comments_full = []
    for comment in comments:
        comments_full.append(comment.serializeCustom())
    # post_list = serializers.serialize('json', posts_full)
    comments_json = json.dumps(comments_full)
    return HttpResponse(comments_json, content_type="text/json-comment-filtered")

@csrf_exempt
def comment_create(request):
    print("START")
    text = request.GET.get("content")
    user = user_models.User.objects.get(pk=1)
    board = board_models.Board.objects.get(title="All")
    pk = request.GET.get("pk")
    print(pk)
    post = post_models.Post.objects.get(pk=pk)
    comment = Comment.objects.create(text=text, user=user, post=post)
    comment.save()
    print("END")
    return HttpResponse("ok")