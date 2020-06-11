from django.db import models
from core import models as core_models


class Vacation(core_models.TimeStampedModel):
    user = models.ForeignKey("users.User",
                            related_name="vacations",
                            on_delete=models.CASCADE)
    date = models.CharField(max_length=10, default="0000-00-00")
    VACATION = "1"
    TRAINING = "2"
    OUTING = "3"
    DISPATCH = "4"
    c_type = ((VACATION, "1"), (TRAINING, "2"), (OUTING, "3"), (DISPATCH, 4))
    calendar_type = models.CharField(choices=c_type, max_length=3, default=VACATION)
    def __str__(self):
        return f"{self.user} at {self.date}"

    def serializeCustom(self):
        data = {
            "user": self.user.username,
            "date": self.date,
            "type": self.calendar_type
        }
        return data