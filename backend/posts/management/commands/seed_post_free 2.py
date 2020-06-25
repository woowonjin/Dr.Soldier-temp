import random
from django.core.management.base import BaseCommand
from django_seed import Seed
from posts.models import Post
from users.models import User
from boards.models import Board


class Command(BaseCommand):
    help = "This command creates many postages"

    def add_arguments(self, parser):
        parser.add_argument(
            "--number", default=1, type=int, help="How many postages do you want to create"
        )

    def handle(self, *args, **options):
        number = options.get("number")
        seeder = Seed.seeder()
        all_users = User.objects.all()
        ano_number = random.randint(1, 2)
        seeder.add_entity(
            Post, number,
            {"host": lambda x: random.choice(all_users),
                "board": Board.objects.get(title="All"),
                "is_deleted": False,
             })
        seeder.execute()
        self.stdout.write(self.style.SUCCESS("Postages Created!!"))
