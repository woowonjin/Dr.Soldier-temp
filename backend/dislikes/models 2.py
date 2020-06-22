from django.db import models
from core import models as core_models


class Dislike(core_models.TimeStampedModel):
    user = models.ForeignKey("users.User",
                             on_delete=models.CASCADE,
                             related_name="dislikes")
    post = models.ForeignKey("posts.Post",
                             on_delete=models.CASCADE,
                             related_name="dislikes")

    def __str__(self):
        return f"{self.user} dislikes {self.post}"