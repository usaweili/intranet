namespace :adding_technology_details_in_project do

  desc 'Adding Rails version in Project technology details'
  task :adding_rails_version => [:environment] do
    @projects = Project.where(:rails_version.ne => nil)
    @projects.each do|project|
      p project.id
      project = project.technology_details.new(name: "Rails", version: project.rails_version)
      project.save!
    end
  end

  desc 'Adding Ruby version in Project technology details'
  task :adding_ruby_version => [:environment] do
    @project = Project.where(:ruby_version.ne => nil)
    @project.each do|project|
      p project.id
      project = project.technology_details.new(name: "Ruby", version: project.ruby_version)
      project.save!
    end
  end
end
