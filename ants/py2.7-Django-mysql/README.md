* do cmd by follows
```
docker-compose build
docker-compose run web django-admin.py startproject mysite ./mysite
chmod -R 777 mysite/
vim mysite/mysite/settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'mysitedb',
        'USER': 'root',
        'PASSWORD': '11111111',
        'HOST': 'db',
        'PORT': 3306,
    }
}
docker-compose up -d
```
* curl IP:80000
