from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    """Custom User Models"""
    uid = models.CharField(max_length=50, unique=True, default="")
    LOGIN_KAKAO = "KaKao"
    LOGIN_APPLE = "Apple"
    LOGIN_CHOICES = ((LOGIN_KAKAO, "KaKao"), (LOGIN_APPLE, "Apple"))
    nickname = models.CharField(max_length=15)
    login_method = models.CharField(choices=LOGIN_CHOICES,
                                    max_length=15,
                                    default=LOGIN_KAKAO)

    def serializeCustom(self):
        data = {
            "pk": self.pk,
        }
        return data
