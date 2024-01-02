# PKI
Финальная работа по курсу Skillbox "Старт в DevOps системное администрирова­ние для начинающих"

### Над чем предстояло работать
Задача максимально приближена к реальной: вам предстоит разработать инфраструктуру для централизованного управления учетными записями.

### Что нужно было cделать:
- развернуть удостоверяющий центр для выдачи сертификатов (Public Key Infrastructure);
- создать и настроить VPN-сервер;
- настроить мониторинг;
- сделать резервное копирование;
- подготовить документацию;
- запланировать развитие инфраструктуры.

---------------------------------------------------------------------

### Документация к реализации проекта

#### Документации для администратора
- [Общая схема инфрструктуры и обмен данными между ее компонентами](https://github.com/Cleverscript/pki/blob/main/architecture_diagram.jpg)
- [Описание ифраструктуры](https://github.com/Cleverscript/pki/blob/main/infrastructure_doc.pdf)
- [Инструкция для администратора](https://github.com/Cleverscript/pki/blob/main/admin_doc.pdf)
- [Документация по установке Prometheus и Alertmanager](https://github.com/Cleverscript/pki/blob/main/prometeus.pdf)
- [Документация по установке Grafana](https://github.com/Cleverscript/pki/blob/main/grafana.pdf)


#### Документация для клиетов OpenVPN
- [Документация для клиетов OpenVPN](https://github.com/Cleverscript/pki/blob/main/client_doc.pdf)


#### Пакеты
- [Пакет для PKI](https://github.com/Cleverscript/pki/blob/main/pki_0.1-1_all.deb)
- [Пакет для OpenVPN](https://github.com/Cleverscript/pki/blob/main/ovpn_0.1-1_all.deb)
- [Пакет для резервного копирования](https://github.com/Cleverscript/pki/blob/main/bac_0.1-1_all.deb)
- [Пакет для клиентов OpenVPN](https://github.com/Cleverscript/pki/blob/main/client_0.1-1_all.deb)
