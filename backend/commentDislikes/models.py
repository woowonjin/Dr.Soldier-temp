from django.db import models
from core import models as core_models


class CommentDislike(core_models.TimeStampedModel):
    user = models.ForeignKey("users.User",
                             on_delete=models.CASCADE,
                             related_name="commentDislikes")
    comment = models.ForeignKey("comments.Comment",
                             on_delete=models.CASCADE,
                             related_name="commentDislikes")

    def __str__(self):
        return f"{self.user} dislikes {self.comment}"