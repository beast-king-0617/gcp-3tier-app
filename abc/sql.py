import csv 
import json
from googleapiclient import discovery
import subprocess
from google.auth import default
from googleapiclient.errors import HttpError
credentials, project_id = default()

compute = discovery.build('compute', 'v1', credentials=credentials)
cloudresourcemanager = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
sql = discovery.build('sqladmin', 'v1', credentials=credentials)

org_id = '319490226055'

def list_projects_recursive(parent):
    projects = []
    try:
        projects_response = cloudresourcemanager.projects().list(parent=parent).execute()
        if 'projects' in projects_response:
            projects.extend([project['projectId'] for project in projects_response['projects']])
        else:
            print(f"No projects found under {parent}")
    except HttpError as e:
        print(f"Error listing projects under {parent}: {e}")
    try:
        folders_response = cloudresourcemanager.folders().list(parent=parent).execute()
        if 'folders' in folders_response:
            for folder in folders_response['folders']:
                projects.extend(list_projects_recursive(folder['name']))
        else:
            print(f"No folders found under {parent}")
    except HttpError as e:
        print(f"Error listing folders under {parent}: {e}")
    return projects

all_projects = list_projects_recursive(f'organizations/{org_id}')

paas_services = []

for project in all_projects:
    try:
        sql_response = sql.instances().list(project=project).execute()
        for instance in sql_response.get('items', []):
            db_version = instance.get('databaseVersion', 'N/A')
            tier = instance['settings'].get('tier', "N/A")
            labels = nstance['settings'].get('user_labels', {})
            labels_str = ','.join([f"{key}: {value}" for key,value in labels.items()]) if labels else 'N/A'

            paas_services.append({
                'Project_Id': project,
                'db_version': db_version,
                'Service_Name': instance['name']
            })
    except HttpError as e:
        print(f"Error getting Cloud SQL details {error}")

with open('paas_services.csv', 'w', newline='') as csvfile:
    fieldnames = ['Project_Id', 'db_version', 'Service_Name']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(paas_services)
print("PAAS services data written to paas_services.csv")