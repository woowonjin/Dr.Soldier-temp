from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    """Custom User Models"""

    LOGIN_KAKAO = "KaKao"
    LOGIN_EMAIL = "Email"
    LOGIN_CHOICES = ((LOGIN_KAKAO, "KaKao"), (LOGIN_EMAIL, "Email"))
    nickname = models.CharField(max_length=15)
    birthdate = models.DateField(blank=True, null=True)
    login_method = models.CharField(choices=LOGIN_CHOICES,
                                    max_length=15,
                                    default=LOGIN_KAKAO)
