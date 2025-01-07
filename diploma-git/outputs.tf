output "internal_ip_address_wm1" {
    value = yandex_compute_instance.wm1.network_interface.0.ip_address  
}

output "internal_ip_address_wm2" {
    value = yandex_compute_instance.wm2.network_interface.0.ip_address 
}

output "internal_ip_address_elasticsearch" {
    value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address 
}

output "internal_ip_address_kibana" {
    value = yandex_compute_instance.kibana.network_interface.0.ip_address 
}

output "external_ip_address_kibana" {
    value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "internal_ip_address_zabbix" {
    value = yandex_compute_instance.zabbix.network_interface.0.ip_address 
}

output "external_ip_address_zabbix" {
    value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "internal_ip_address_bastion" {
    value = yandex_compute_instance.bastion.network_interface.0.ip_address 
}

output "external_ip_address_bastion" {
    value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "external_ip_address_Application_load_balancer" {
    value = yandex_alb_load_balancer.applb.listener.0.endpoint.0.address.0.external_ipv4_address
}