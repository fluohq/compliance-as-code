from django.contrib import admin
from django.urls import path, include
from users.views import health

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health', health, name='health'),
    path('', include('users.urls')),
]
