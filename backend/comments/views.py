from django.shortcuts import render
from . import models
import json
from django.http import HttpResponse, JsonResponse
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
