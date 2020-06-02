from django.shortcuts import render
from . import models
import json
from django.http import HttpResponse, JsonResponse
from posts import models as post_models
from users import models as user_models
from boards import models as board_models
from .models import Comment
from django.views.decorators.csrf import csrf_exempt
from commentLikes import models as commentLikes_models
from commentDislikes import models as commentDislikes_models

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
    text = request.GET.get("content")
    email = request.GET.get("user")
    user = user_models.User.objects.get(username=email)
    board = board_models.Board.objects.get(title="All")
    pk = request.GET.get("pk")
    post = post_models.Post.objects.get(pk=pk)
    comment = Comment.objects.create(text=text, user=user, post=post)
    comment.save()
    return HttpResponse("ok")

def already_comment_like(request):
    comment_pk = request.GET.get("pk")
    user_email = request.GET.get("user")
    comment = Comment.objects.get(pk=comment_pk)
    user = user_models.User.objects.get(username=user_email)
    try:
        like = commentLikes_models.CommentLike.objects.get(user=user, comment=comment)
        #like exists
        try:
            dislike = commentDislikes_models.CommentDislike.objects.get(user=user, comment=comment)
            #dislike exists
            response = {"like": True,
                        "dislike": True,
                        "likes_number": comment.comment_likes_count(),
                        "dislikes_number": comment.comment_dislikes_count(),
                        }
            return JsonResponse(response, status=201)
        except commentDislikes_models.CommentDislike.DoesNotExist:
            #dislike does not exist
            response = {"like": True,
                        "dislike": False,
                        "likes_number": comment.comment_likes_count(),
                        "dislikes_number": comment.comment_dislikes_count(),
                        }
            return JsonResponse(response, status=201)
    except commentLikes_models.CommentLike.DoesNotExist:
        #like does not exist
        try:
            dislike = commentDislikes_models.CommentDislike.objects.get(user=user, comment=comment)
            #dislike exists
            response = {"like": False,
                        "dislike": True,
                        "likes_number": comment.comment_likes_count(),
                        "dislikes_number": comment.comment_dislikes_count(),
                        }
            return JsonResponse(response, status=201)
        except commentDislikes_models.CommentDislike.DoesNotExist:
            #dislike does not exist
            response = {"like": False,
                        "dislike": False,
                        "likes_number": comment.comment_likes_count(),
                        "dislikes_number": comment.comment_dislikes_count(),
                        }
            return JsonResponse(response, status=201)