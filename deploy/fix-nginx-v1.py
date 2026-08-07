#!/usr/bin/env python3
# Corrige o rewrite /v1 -> /api/v1 no site qolari-api.
# O rewrite com "last" nao funciona porque o Laravel/Symfony le o caminho de
# REQUEST_URI (que nao muda com rewrite). Solucao: location dedicada que faz o
# rewrite com "break" e entrega direto ao PHP-FPM com REQUEST_URI reescrito.
p = '/etc/nginx/sites-enabled/qolari-api'
s = open(p).read()

old = '    location ^~ /v1/ { rewrite ^ /api$request_uri last; }\n'
new = (
    '    # Compat OpenAI / extensao: clientes apontam para /v1/* -> /api/v1/*\n'
    '    location ^~ /v1/ {\n'
    '        rewrite ^/v1/(.*)$ /api/v1/$1 break;\n'
    '        include fastcgi_params;\n'
    '        fastcgi_pass unix:/run/php/php8.3-fpm-qolari.sock;\n'
    '        fastcgi_param SCRIPT_FILENAME /var/www/qolari/api/public/index.php;\n'
    '        fastcgi_param SCRIPT_NAME /index.php;\n'
    '        fastcgi_param REQUEST_URI $uri$is_args$args;\n'
    '        fastcgi_read_timeout 300;\n'
    '        fastcgi_buffering off;\n'
    '    }\n'
)

if old in s:
    s = s.replace(old, new)
    open(p, 'w').write(s)
    print('SUBSTITUIDO')
elif 'rewrite ^/v1/' in s:
    print('JA_CORRIGIDO')
else:
    print('LINHA_NAO_ENCONTRADA')
