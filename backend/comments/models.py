from django.db import models
from core import models as core_models


class Comment(core_models.TimeStampedModel):
    text = models.TextField(max_length=100)
    user = models.ForeignKey("users.User",
                             on_delete=models.CASCADE,
                             related_name="comments")
    post = models.ForeignKey("posts.Post",
                             on_delete=models.CASCADE,
                             related_name="comments")

    def __str__(self):
        return f"{self.user} comments to {self.post}"