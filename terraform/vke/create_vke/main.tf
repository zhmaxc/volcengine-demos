# Provider 配置
terraform {
  required_version = ">= 0.13"
  required_providers {
    volcengine = {
      source = "volcengine/volcengine"
      version = "0.0.47"
    }
  }
}
provider "volcengine" {
  access_key = "AKLTNGZlY2YxNjczZWQ1NDI4MmIxODZiY2U1ZmRhMWE5ZWY"
  secret_key = "WkRsaU16RTFZV0ptT1RVME5EVTJPVGc1TXpoaFpqRmxaR015WkdJMVl6UQ=="
  # session_token = "sts token"
  region = "cn-beijing"
}

# 创建 VPC
resource "volcengine_vpc" "bio-vpc" {
  vpc_name = "bio-vpc"
  cidr_block = "192.168.0.0/16"
}
# 创建虚拟交换机&子网
resource "volcengine_subnet" "bio-subneta" {
  subnet_name = "bio-subneta"
  cidr_block  = "192.168.0.0/20"
  zone_id     = "cn-beijing-a"
  vpc_id      = volcengine_vpc.bio-vpc.id
}
# 创建VKE集群
resource "volcengine_vke_cluster" "bio-vke" {
  name                = "bio-vke"
  description         = "bio-vke created by terraform"
  delete_protection_enabled = false
  cluster_config {
    subnet_ids = [volcengine_subnet.bio-subneta.id]
    api_server_public_access_enabled = false
    resource_public_access_default_enabled = true
  }
  pods_config {
    #配置容器网络模型
    pod_network_mode = "Flannel"
    flannel_config {
      pod_cidrs = ["172.16.0.0/16"]
      max_pods_per_node = 64
    }
  }
  #配置集群service CIDR
  services_config {
    service_cidrsv4 = ["172.20.0.0/20"]
  }
}
#创建节点池
resource "volcengine_vke_node_pool" "bio-pool" {
  cluster_id = "${volcengine_vke_cluster.bio-vke.id}"
  name = "bio-pool"
  node_config {
    instance_type_ids = ["ecs.c1ie.large"]
    subnet_ids = [volcengine_subnet.bio-subneta.id]
    security {
      login {
        password = "UHdkMTIzNDU2"
      }
    }
    system_volume {
      type = "ESSD_PL0"
      size = 40
    }
    data_volumes  {
      type = "ESSD_PL0"
      size = 50
    }
    data_volumes  {
      type = "ESSD_PL0"
      size = 50
    }
  }
  auto_scaling {
    enabled = true
    max_replicas = 10
    min_replicas = 0
    desired_replicas = 2
    priority = 15
  }
  kubernetes_config {
    cordon = false
  }
}
#vke组件csi-ebs
resource "volcengine_vke_addon" "csi-ebs" {
  cluster_id = "${volcengine_vke_cluster.bio-vke.id}"
  name = "csi-ebs"
}
resource "volcengine_vke_addon" "nvidia-device-plugin" {
  cluster_id = "${volcengine_vke_cluster.bio-vke.id}"
  name = "nvidia-device-plugin"
  config = "{\"EnableExporter\":true}"
}
resource "volcengine_vke_addon" "ingress-nginx" {
  cluster_id = "${volcengine_vke_cluster.bio-vke.id}"
  name = "ingress-nginx"
  config = "{\"Replica\":1,\"Resource\":{\"Request\":{\"Cpu\":\"0.1\",\"Memory\":\"250Mi\"},\"Limit\":{\"Cpu\":\"0.5\",\"Memory\":\"1024Mi\"}},\"PublicNetwork\":{\"LanType\":\"BGP\",\"BandWidthLimit\":10,\"IpVersion\":\"IPV4\",\"BillingType\":3,\"SubnetId\":\"volcengine_subnet.bio-subneta.id\"}}"
}

