import random
from django.core.management.base import BaseCommand
from django_seed import Seed
from posts.models import Post
from users.models import User
from likes.models import Like


class Command(BaseCommand):
    help = "This command creates many likes"

    def add_arguments(self, parser):
        parser.add_argument(
            "--number", default=1, type=int, help="How many likes do you want to create"
        )

    def handle(self, *args, **options):
        number = options.get("number")
        seeder = Seed.seeder()
        all_users = User.objects.all()
        all_posts = Post.objects.all()
        seeder.add_entity(
            Like, number,
            {"user": lambda x: random.choice(all_users),
                "post": lambda x: random.choice(all_posts),
             })
        seeder.execute()
        self.stdout.write(self.style.SUCCESS("Likes Created!!"))
