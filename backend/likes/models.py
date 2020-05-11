from django.db import models
from core import models as core_models


class Like(core_models.TimeStampedModel):
    user = models.ForeignKey("users.User",
                             on_delete=models.CASCADE,
                             related_name="likes")
    post = models.ForeignKey("posts.Post",
                             on_delete=models.CASCADE,
                             related_name="likes")

    def __str__(self):
        return f"{self.user} likes {self.post}"