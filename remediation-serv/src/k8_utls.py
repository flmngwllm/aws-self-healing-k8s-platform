from kubernetes import client, config

def get_apps_api():
    config.load_incluster_config()
    return client.AppsV1Api()


def list_deployments():
    config.load_incluster_config()
    apps_v1 = client.AppsV1Api()


    deployments = apps_v1.list_namespaced_deployment(namespace="default")

    for deployment in deployments.items:
        print(f"Deployment Name: {deployment.metadata.name}")