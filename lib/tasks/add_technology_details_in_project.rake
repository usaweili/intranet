desc 'Adding Technology Details in Project'
task :adding_rails_version_in_project_technology_details => [:environment] do
  @projects = Project.where(:rails_version.ne=>nil)
  @projects.each do|project|
    project = project.technology_details.new(name:"Rails",version:project.rails_version)
    project.save!
  end
task :adding_ruby_version_in_project_technology_details => [:environment] do
  @project = Project.where(:ruby_version.ne=>nil)
  @projects.each do|project|
    project = project.technology_details.new(name:"Ruby",version:project.ruby_version)
    project.save!
  end
end