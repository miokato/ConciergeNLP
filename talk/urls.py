from django.urls import path
from .views import TalkView


urlpatterns = (
    path('', TalkView.as_view()),
)


