from django.db import models
from core import models as core_models


class CommentLike(core_models.TimeStampedModel):
    user = models.ForeignKey("users.User",
                             on_delete=models.CASCADE,
                             related_name="commentLikes")
    comment = models.ForeignKey("comments.Comment",
                             on_delete=models.CASCADE,
                             related_name="commentLikes")

    def __str__(self):
        return f"{self.user} likes {self.comment}"

