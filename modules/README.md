# Настройка серверов для ceph с помощю Ansible

**Буду расписывать полную конфигурацию по задачам.**
**А точнее для `setting_up_servers.yaml`**
**Эти значение нужны для того что бы ускорить работу сервера, и работу дисков**
```ansible
- name: Обновление sysctl.conf с новыми настройками
  hosts: all
  become: yes
  tasks:
    - name: Добавление параметров в /etc/sysctl.conf
      lineinfile:
        path: /etc/sysctl.conf
        line: "{{ item }}"
        create: yes
      with_items:
        - vm.swappiness = 10
        - net.core.somaxconn = 16384
        - net.core.netdev_max_backlog = 2000
        - net.core.netdev_budget = 1000
        - net.core.default_qdisc = fq
        - net.ipv6.conf.all.disable_ipv6 = 1
        - net.ipv6.conf.default.disable_ipv6 = 1
        - net.ipv4.tcp_mtu_probing = 0
        - net.ipv4.tcp_window_scaling = 1
        - net.ipv4.tcp_congestion_control = bbr
        - net.ipv4.tcp_notsent_lowat = 16384
        - net.ipv4.tcp_timestamps = 1
        - net.ipv4.tcp_sack = 1
        - net.ipv4.tcp_tw_reuse = 1
        - net.ipv4.tcp_adv_win_scale = -2
        - net.ipv4.tcp_syncookies = 0
        - net.ipv4.tcp_max_syn_backlog = 4096
        - net.ipv4.tcp_synack_retries = 1
        - net.ipv4.tcp_max_orphans = 65536
        - net.ipv4.tcp_fin_timeout = 10
        - net.ipv4.tcp_keepalive_time = 60
        - net.ipv4.tcp_keepalive_intvl = 15
        - net.ipv4.tcp_keepalive_probes = 5
        - net.ipv4.tcp_slow_start_after_idle = 0
        - net.ipv4.conf.all.accept_source_route = 0
        - net.ipv4.conf.all.accept_redirects = 0
        - net.ipv4.conf.all.secure_redirects = 0
        - net.ipv4.conf.all.send_redirects = 0
        - net.ipv4.icmp_echo_ignore_broadcasts = 1
        - net.ipv4.icmp_ignore_bogus_error_responses = 1
        - net.core.rmem_max = 56623104
        - net.core.wmem_max = 56623104
        - net.core.rmem_default = 56623104
        - net.core.wmem_default = 56623104
        - net.core.optmem_max = 40960
        - net.ipv4.tcp_rmem = 4096 87380 56623104
        - net.ipv4.tcp_wmem = 4096 65536 56623104
        - net.ipv6.conf.lo.disable_ipv6 = 1

    - name: Применение настроек sysctl
      command: sysctl -p
```
**Создание udev правила для сетевых интерфесов**
```
    - name: Добавление параметров в /etc/udev/rules.d/59-net.ring.rules
      lineinfile:
        path: /etc/udev/rules.d/59-net.ring.rules
        line: "{{ item }}"
        create: yes
      with_items:
        - ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="en*", RUN+="/sbin/ethtool -G $name rx 4096 tx 4096"
        - ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="en*", RUN+="/sbin/ip link set $name txqueuelen 10000"
        - ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="bon*", RUN+="/sbin/ip link set $name txqueuelen 10000"

    - name: Перезапуск udevadm
      shell: udevadm control --reload-rules && udevadm trigger
```

**Выключение автоапдейтов**
<span style="color:red">Примечание: Предварительно надо очистить файл /etc/apt/apt.conf.d/20auto-upgrades</span>
<span style="color:red">Например вот так</span>

```
ansible all -m shell -a 'echo > /etc/apt/apt.conf.d/20auto-upgrades`

```


```
    - name: Выключение /etc/apt/apt.conf.d/20auto-upgrades
      copy:
        dest: /etc/apt/apt.conf.d/20auto-upgrades
        content: |
          APT::Periodic::Update-Package-Lists "0";
          APT::Periodic::Unattended-Upgrade "0";
        owner: root
        group: root
        mode: '0644'
```

**Очень удобно т.к не надо проходить по каждой ноде в ручную**
```
    - name: Установка новых имен хостов
      command: hostnamectl set-hostname {{ item.new_hostname }}
      when: inventory_hostname == item.inventory_hostname
      loop:
        - { inventory_hostname: 'mon01', new_hostname: 'mon1-ceph4-p1-01' }
        - { inventory_hostname: 'mon02', new_hostname: 'mon2-ceph4-p2-02' }
        - { inventory_hostname: 'mon03', new_hostname: 'mon3-ceph4-p1-03' }
        - { inventory_hostname: 'osd01', new_hostname: 'osd1-ceph4-p1-01' }
        - { inventory_hostname: 'osd02', new_hostname: 'osd2-ceph4-p1-01' }
        - { inventory_hostname: 'osd03', new_hostname: 'osd3-ceph4-p1-01' }
        - { inventory_hostname: 'osd04', new_hostname: 'osd4-ceph4-p2-02' }
        - { inventory_hostname: 'osd05', new_hostname: 'osd5-ceph4-p2-02' }
        - { inventory_hostname: 'osd06', new_hostname: 'osd6-ceph4-p2-02' }
        - { inventory_hostname: 'osd07', new_hostname: 'osd7-ceph4-p1-03' }
        - { inventory_hostname: 'osd08', new_hostname: 'osd8-ceph4-p1-03' }
        - { inventory_hostname: 'osd09', new_hostname: 'osd9-ceph4-p1-03' }

```


**Так же добовляем параметры в hosts**
**P.S. Это точно можно улучшить сделаю это позже**
```
    - name: Добавление параметров в /etc/hosts
      lineinfile:
        path: /etc/hosts
        line: "{{ item }}"
        create: yes
      with_items:
        -   mon1-ceph4-p1-01
        -   mon2-ceph4-p2-02
        -   mon3-ceph4-p1-03
        -   osd1-ceph4-p1-01
        -   osd2-ceph4-p1-01
        -   osd3-ceph4-p1-01
        -   osd4-ceph4-p2-02
        -   osd5-ceph4-p2-02
        -   osd6-ceph4-p2-02
        -   osd7-ceph4-p1-03
        -   osd8-ceph4-p1-03
        -   osd9-ceph4-p1-03

```

**Удаление и остановка сервисов которые не нужны на сервере**
```
    - name: Удаление cloud-init
      apt:
        name: cloud-init
        state: absent

    - name: Удаление lxd(Если ошибка, значит его уже нет)
      snap:
        name: lxd
        state: absent
      ignore_errors: yes

    - name: Удаление core20(Если ошибка, значит его уже нет)
      snap:
        name: core20
        state: absent
      ignore_errors: yes

    - name: Удаление snapd(Если ошибка, значит его уже нет)
      snap:
        name: snapd
        state: absent
      ignore_errors: yes

    - name: Удаление snapd через apt
      apt:
        name: snapd
        state: absent

    - name: Автоматическое удаление ненужных пакетов
      apt:
        autoremove: yes

    - name: Обновление списка пакетов
      apt:
        update_cache: yes

    - name: Установка cephadm(Если ошибка значит уже установлен)
      shell: apt install cephadm -y
      ignore_errors: yes

    - name: Добавление репозитория Quincy
      shell: cephadm add-repo --release Quincy

    - name: Установка ceph-common:17.2.7
      shell: cephadm install ceph-common












```
    - name: Генерация ssh-keygen
      shell: |
        bash ssh-key.sh
# Надо выбирать 'executable: /bin/bash' потому что sh так не умеет
      args:
        executable: /bin/bash
```
