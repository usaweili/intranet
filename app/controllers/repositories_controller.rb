class RepositoriesController < ApplicationController
  before_action :authenticate_user!

  def overview_index
    url = "http://api.codeclimate.com/v1/orgs/#{ENV["CODE_CLIMATE_ORGANIZATION_KEY"]}/repos"
    headers = { "Accept" => "application/vnd.api+json",
                "Authorization" => "Token token=#{ENV["CODE_CLIMATE_TOKEN"]}" }
    begin
      response = HTTParty.get(url, headers: headers, timeout: 20)
    rescue Timeout::Error => e
      puts "Error: Request Timeout for #{repo.project.name}"
    end
    @response_body = JSON.parse(response.body)
  end

  def repository_issues
    @repo_name = params[:repo_name]
    @response_body = params[:repo_id] && params[:snap_id] ? get_issues : {}
  end

  def get_repo_issues
    offset = params["offset"].to_i || 0
    page = params["page"] || 1
    result = get_issues(page = page)
    respond_to do |format|
      format.json { render json: result["data"] || {} }
    end
  end

  private

  # Recursive get_issues to fetch the paginated data from CodeClimate, where page[size] limit is 100.
  def get_issues(page = 1)
    query_string = "page[size]=100&page[number]=#{page}"
    url = "https://api.codeclimate.com/v1/repos/#{params[:repo_id]}/snapshots/#{params[:snap_id]}/issues?#{query_string}"
    headers = { "Accept" => "application/vnd.api+json", "Authorization" => "Token token=#{ENV["CODE_CLIMATE_TOKEN"]}" }
    begin
      response = HTTParty.get(url, headers: headers, timeout: 20)
    rescue Timeout::Error => e
      puts "Error: Request Timeout for #{repo.project.name}"
    end
    response = JSON.parse(response.body)
    if response["meta"]["current_page"] <= response["meta"]["total_pages"]
      return response
    else
      return {}
    end
  end
end
