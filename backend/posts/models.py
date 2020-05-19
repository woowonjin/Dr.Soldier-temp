from django.db import models
from core import models as core_models


class Post(core_models.TimeStampedModel):
    """Custom Post Model"""
    title = models.CharField(max_length=50)
    text = models.TextField(max_length=500)
    host = models.ForeignKey("users.User",
                             on_delete=models.CASCADE,
                             related_name="posts")
    board = models.ForeignKey("boards.Board",
                              on_delete=models.CASCADE,
                              related_name="posts")
    is_deleted = models.BooleanField(default=False)
    def __str__(self):
        return f"title:{self.title}"

    def count_likes(self):
        return self.likes.count()

    count_likes.short_description = "Likes"

    def count_comments(self):
        return self.comments.count()

    count_comments.short_description = "Comments"

    def count_dislikes(self):
        return self.dislikes.count()

    count_dislikes.short_description = "Dislikes"

    def serializeCustom(self):
        data = {
            "pk": self.pk,
            "title": self.title,
            "text": self.text,
            "host": self.host.pk,
            "host_name": self.host.nickname,
            "board": self.board.pk,
            "is_deleted": self.is_deleted,
            "likes_number": self.count_likes(),
            "dislikes_number": self.count_dislikes(),
            "created":str(self.created),
            "updated":str(self.updated),
        }
        return data
