from django.db import models
from core import models as core_models

class Notification(core_models.TimeStampedModel):
    user = models.ForeignKey("users.User", 
                            on_delete = models.CASCADE ,
                            related_name="notifications")
    
    post = models.ForeignKey("posts.Post", on_delete=models.CASCADE, related_name="notifications")

    COMMENT = "댓글"
    LIKE = "좋아요"
    DISLIKE = "싫어요"
    LIKE_CANCEL = "좋아요취소"
    DISLIKE_CANCEL = "싫어요취소"
    noti_type_choice = ((COMMENT, "댓글"), (LIKE, "좋아요"), (DISLIKE, "싫어요")
                        , (LIKE_CANCEL, "좋아요취소"), (DISLIKE_CANCEL, "싫어요취소"))
    is_read = models.BooleanField(default=False)
    noti_type = models.CharField(choices=noti_type_choice, max_length=20, default=LIKE)

    def __str__(self):
        return f"{self.user.nickname} 님이 회원님의 게시물 {self.post.title}에 {self.noti_type}"
    
    def serializeCustom(self):
        data = {
            "pk": self.pk,
            "type": self.noti_type,
            "post_title": self.post.title,
            "user_name": self.user.nickname,
            "is_read": self.is_read,
            "created":str(self.created),
        }
        return data