## Terraform 
### vke
1. 创建 vpc，subnet
2. 创建vke，node-pool，node
3. 创建组件ebs-csi, ingress-controller，nvdia-device-plugin
4. vke集群关联Bio-OS，关联workspace（1.4.0发版后对接 terraform,暂时没有）

## Python
### Bio-OS
1. 获取共享集群 ID
2. 创建 workspace
3. 获取 Workspace ID (通过名字)
4. Worksapce 关联 workflow 计算集群 bind_cluster_to_workspace workflow
5. Worksapce 关联 notebook 计算集群 bind_cluster_to_workspace notebook 
6. Worksapce 解除关联 workflow 计算集群 unbind_cluster_to_workspace workflow
7. Worksapce 解除关联 notebook 计算集群，unbind_cluster_to_workspace notebook 
8. 删除 Workspace，Delete workspace 


