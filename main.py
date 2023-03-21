from __future__ import print_function
from volcengine.bioos.BioOsService import BioOsService
from bio_helper import get_cluster_id,create_workspace,get_workspce_id,bind,unbind,delete_workspace

if __name__ == '__main__':
    # set endpoint/region here if the default value is unsatisfied
    bioos_service = BioOsService(endpoint='https://open.volcengineapi.com', region='cn-beijing')

    # call below method if you don't set ak and sk in $HOME/.volc/config
    bioos_service.set_ak('AK')
    bioos_service.set_sk('SK')
    # ------------------------------------------------------------------------------------------------------------
    # 01 参数配置区域（必须）

    # S3Bucket = 'bio' 
    workspace_name = "chenggang_python_sdk"
    workspace_Description = 'Created By python SDK, zhuchenggang@bytedance.com'
    count = 0
    try:
        cluster_id = get_cluster_id(bioos_service,['shared'])
        count += 1
        print(str(count)+".获取共享集群ID:"+str(cluster_id))
    except Exception as e:
        print("获取共享集群信息失败:",e)

    # ------------------------------------------------------------------------------------------------------------
    # 02 创建 workspace， 并关联workflow，notebook算力 （按需）

    try:
        # workspace_id = create_workspace(bioos_service,workspace_name,worksapce_Description,S3Bucket)
        workspace_id = create_workspace(bioos_service,workspace_name,workspace_Description)
        count += 1
        print(str(count)+".创建 workspace：" + workspace_name + "成功，ID:"+workspace_id)
    except Exception as e:
        count += 1
        print(str(count)+".创建集群失败:",e)      
    try:
        bind(bioos_service, workspace_id,cluster_id,'workflow')
        count += 1
        print(str(count)+".绑定集群:"+str(cluster_id)+" 和workspace:"+ workspace_name +"的"+"workflow 成功")
    except Exception as e:  
        count += 1
        print(str(count)+".绑定 workflow 失败:",e) 
    try:
        count += 1
        bind(bioos_service, workspace_id,cluster_id,'notebook')
        print(str(count)+".绑定集群:"+str(cluster_id)+" 和workspace:"+ workspace_name +"的"+"notebook 成功")
    except Exception as e:  
        count += 1
        print(str(count)+".绑定 notebook 失败:",e)   
    # ------------------------------------------------------------------------------------------------------------
    ## 03 解除关联workflow，notebook，删除 workspace （按需）
    # try:
    #     workspace_id = get_workspce_id(bioos_service, workspace_name)
    #     count += 1
    #     print(str(count)+".获取集群ID成功:",cluster_id)
    # except Exception as e:
    #     count += 1
    #     print(str(count)+".获取集群ID失败"+"\n",e)

    # try:
    #     count += 1   
    #     unbind(bioos_service, workspace_id,cluster_id,'workflow')
    #     print(str(count)+".解绑集群"+cluster_id+" 和workspace:"+ workspace_name +"的"+"workflow 成功") 
    # except Exception as e:  
    #     count += 1
    #     print(str(count)+".解绑workflow 失败"+"\n",e)
 
    # try:
    #     count += 1
    #     unbind(bioos_service, workspace_id,cluster_id,'notebook')
    #     print(str(count)+".解绑集群"+cluster_id+" 和workspace:"+ workspace_name +"的"+"notebook 成功") 
    # except Exception as e:  
    #     count += 1
    #     print(str(count)+".解绑集群"+cluster_id+" 和workspace:"+ workspace_name +"的"+"notebook失败",e)
    # try:
    #     count += 1
    #     delete_workspace(bioos_service, workspace_id)
    #     print(str(count)+".删除workspace:"+ workspace_name +"成功")
    # except Exception as e:  
    #     count += 1
    #     print(str(count)+".删除 workspace:"+workspace_name+ "失败"+"\n",e)

