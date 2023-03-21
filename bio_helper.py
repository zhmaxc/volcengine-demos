from __future__ import print_function
from volcengine.bioos.BioOsService import BioOsService

# 1. 获取共享集群 ID
def get_cluster_id(bioos_service,type):
    params_list_cluster = {
        'Filter': {
            'Type': type
        },
    }
    cluster_id = bioos_service.list_clusters(params_list_cluster)["Items"][0]["ID"]

    return cluster_id

# 2. 创建 Workspace
# def create_workspace(bioos_service,workspace_name,worksapce_Description,S3Bucket):
def create_workspace(bioos_service,workspace_name,worksapce_Description):
    params_create_workspace = {
        'Name': workspace_name,
        'Description': worksapce_Description,
        #'S3Bucket':  S3Bucket
    }
    workspace_id = bioos_service.create_workspaces(params_create_workspace)["ID"]
    return workspace_id

# 3. 获取 Workspace ID (by name)
def get_workspce_id(bioos_service,workspace_name):

    params_list_workspace = {
        'Filter': {
            'Keyword': workspace_name,
        },
    }
    workspace_id = bioos_service.list_workspaces(params_list_workspace)["Items"][0]["ID"]
    return workspace_id

# 4. Worksapce 关联 cluster
def bind(bioos_service,workspace_id,cluster_id,type):
    params_bind_cluster = {
        'ID': workspace_id ,
        'ClusterID': cluster_id, 
        'Type': type,
    }
    bioos_service.bind_cluster_to_workspace(params_bind_cluster)

# 5. Worksapce 解除关联 workflow 计算集群 unbind_cluster_to_workspace workflow
def unbind(bioos_service,workspace_id,cluster_id,type):
    params_unbind= {
        'ID': workspace_id ,
        'ClusterID': cluster_id, 
        'Type': type,
    }
    bioos_service.unbind_cluster_and_workspace(params_unbind)
# 6. 删除 Workspace，Delete workspace
def delete_workspace(bioos_service,workspace_id):
    params_del_workspace = {
        'ID': workspace_id,
    }
    bioos_service.delete_workspace(params_del_workspace)