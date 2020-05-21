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
    is_deleted = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user} comments to {self.post}"

    def comment_likes_count(self):
        return self.commentLikes.count()
    comment_likes_count.short_description = "comment_likes"

    def comment_dislikes_count(self):
        return self.commentDislikes.count()
    comment_dislikes_count.short_description = "comment_dislikes"

    def serializeCustom(self):
        data = {
            "pk": self.pk,
            "text": self.text,
            "host": self.user.pk,
            "host_name": self.user.nickname,
            "likes_number": self.comment_likes_count(),
            "dislikes_number": self.comment_dislikes_count(),
            "created":str(self.created),
            "updated":str(self.updated),
            "is_deleted":self.is_deleted
        }
        return data