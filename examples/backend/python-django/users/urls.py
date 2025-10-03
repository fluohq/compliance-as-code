from django.urls import path
from . import views

urlpatterns = [
    path('user/<str:user_id>', views.get_user, name='get_user'),
    path('user', views.create_user, name='create_user'),
    path('users', views.list_users, name='list_users'),
    path('user/<str:user_id>/delete', views.delete_user, name='delete_user'),
]
