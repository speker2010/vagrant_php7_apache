# vagrant_php7 nginx apache mysql
* mysql
* user root
* pass 
* db name test
* default domain test.loc

## Генерация ssl сертификата
Частично взято отсюда:
https://habr.com/ru/post/192446/

*Многие инструкции по созданию сертификатов не работают, потому что с определенного момента
Chrome стал требовать указания subjectAltName для сертификата домена.
В инструкциях об этом обычно не написано*

Последовательность следующая. 
1. Создаем корневой сертификат.
1. С помощью корневого сертификата создаем сертификат для домена.
1. Добавляем корневой сертификат в список доверенных сертификатов в ос
1. Теперь все сертификаты созданные с помощью этого корневого сертификата будут считаться валидными

### Создаем корневой сертификат
файл ```root.crt.sh```
*openssl можно использовать в vagrant ssh*

Можно выпустить один раз и пропускать этот шаг для новых доменов

*Лучше сгенерированные в этом разделе файлы скопировать куда-то,
 чтобы потом использовать для выпуска новых сертификатов*
 
Генерируем приватный ключ для корневого сертификата
```
openssl genrsa -out myRootCA.key 4096
```

Генерируем корневой сертификат с приватным ключом
В файле root.cfg конфиг для ```openssl req```
```
openssl req -x509 -new -key myRootCA.key -days 10000 -config root.cfg -out myRootCA.crt
  # Country Name (2 символьный код) [AU]:RU
  # State or Province Name (область или штат) [Some-State]:Moskow
  # Locality Name (Город) []:Moskow
  # Organization Name (название организации) [Internet Widgits Pty Ltd]: MY-DEV-CA
  # Organizational Unit Name (название подразделения) []: my-dev-ca
  # Common Name (общее имя) []: my-dev-ca
  # Email Address []: my@email.com
```

### Создание сертификата для домена
Файл ```domain.crt.sh``` использовать ```./domain.crt.sh site.com```
**Здесь и далее site.com нужно заменить на домен для которого делаем сертификат**

Создаем приватный ключ
```
openssl genrsa -out site.com.key 2048
```

Создаем файл конфига из дефолтного.
В файле domain.cfg.default находится шаблон конфига.
Команда ниже заменит все вхождения site.com на ownsite.com(ownsite.com нужно заменить 
на домен для которого сертификат) в файле domain.cfg.default
и сохранит в файл domain.cfg
```
cat domain.cfg.default | sed 's/site.com/ownsite.com/g' > domain.cfg
```

Создание запроса на генерацию
```
openssl req -new -key site.com.key -config domain.cfg -out site.com.csr
	
	# Country Name (2-х буквенный код страны) [AU]:AU
	# State or Province Name (область штат) [Some-State]:Moscow
	# Locality Name (Город) []:Moscov
	# Organization Name (название организации) [Internet Widgits Pty Ltd]:dev
	# Organizational Unit Name (название подразделения) []:dev
	# Common Name (домен для которого выпускается сертификат или ip) []:site.com
	# Email Address [email администратора]:me@email.com
	# A challenge password []:23zy!
	# An optional company name []:Kloud

```

Подписываем запрос корневым сертификатом
```
openssl x509 -req -in site.com.csr -CA myRootCA.crt -CAkey myRootCA.key -CAcreateserial -out site.com.crt -days 5000 -extensions v3_req -extfile domain.cfg
```

rootCA.crt — можно давать друзьям, устанавливать, копировать не сервера, выкладывать в публичный доступ
rootCA.key — следует держать в тайне

Теперь нужно сертификат ```myRootCA.crt``` добавить в "доверенные центры сертификации" в вашем браузере и ОС.
Теперь любой сертификат домена подписанный этим сертификатом будет отображаться как доверенный.
Все должно заработать после того как настроим nginx на отдачу сертификата.

## Добавляем в конфиг nginx

```
server {
        listen 80;
        listen       443 ssl;
        server_name  cvclinic.ru;
        access_log  /var/log/nginx/host.access.log;
        error_log /var/log/nginx/host.error.log debug;
        index index.php;

        ssl on;
        ssl_certificate      /vagrant/site.com.crt;
        ssl_certificate_key  /vagrant/device.key;

        location ~* ^.+\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|js)$ {
            root /var/www/;
            index  index.php;
        }

        location / {
            proxy_pass   http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location ~ /\.ht {
        deny  all;
        }
}
```
