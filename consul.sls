install consul binary:
  file.managed:
    - name: /usr/local/bin/consul
    - source: salt://consul/consul
    - user: root
    - group: root
    - mode: 755

add consul user:
  user.present:
    - name: consul
    - shell: /bin/false
    - home: /etc/consul.d
    - system: True

/opt/consul:
  file.directory:
    - user: consul
    - group: consul

add consul service:
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: salt://consul/consul.service
    - user: consul
    - group: consul

/etc/consul.d:
  file.directory:
    - user: consul
    - group: consul


{% if grains['host'] == 'deb9-01' %}
server consul config:
  file.managed:
    - name: /etc/consul.d/server.json
    - source: salt://consul/server.json
    - user: consul
    - group: consul
    - mode: 640
{% endif %}

{% if grains['host'] != 'deb9-01' %}
client consul config:
  file.managed:
    - name: /etc/consul.d/client.json
    - source: salt://consul/client.json
    - user: consul
    - group: consul
    - mode: 640
{% endif %}

run consul service:
  service.running:
    - name: consul
    - enable: True
    - no_block: True
    - watch:
      {% if grains['host'] == 'deb9-01' %}
      - file: server consul config
      {% elif grains['host'] != 'deb9-01' %}
      - file: client consul config
      {% endif %}
