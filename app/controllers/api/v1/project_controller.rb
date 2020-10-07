class Api::V1::ProjectController < ApplicationController
  
  def index
    render json: { projects: Project.get_all_sorted_by_name.as_json(project_info_fields) }
  end

  private

  def project_info_fields
    {
      only: [:_id, :name, :is_active, :created_at, :updated_at, :manager_ids],
      include: {
        repositories: {
          only: [:url, :host]
        }
      },
      methods: [:active_users]
    }
  end
end