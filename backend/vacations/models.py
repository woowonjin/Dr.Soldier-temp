from django.db import models
from core import models as core_models


class vacation(core_models.TimeStampedModel):
    user = name = models.ForeignKey("users.User",
                                    related_name="vacations",
                                    on_delete=models.CASCADE)
    date = models.DateField()

    def __str__(self):
        return f"{self.user} at {self.date}"
