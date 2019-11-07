require 'csv'
desc 'Add parent designation to the designations from csv'
namespace :add_parent_designation do

  task :add_parent_designations_to_designations =>
    [:environment, :add_new_designations] do
    file = "#{Rails.root}/tmp/desig_self_association.csv"
    CSV.open(file, 'r', headers: true).each do |reader|
      desig = Designation.find_by(name: reader['Designation'])
      parent_desig = Designation.find_by(name: reader['Parent Designation'])
      if desig && parent_desig
        desig.parent_designation = parent_desig
        desig.save!
      end
    end
    CSV.open(file, 'r', headers: true).each do |reader|
      desig = Designation.find_by(name: reader['Designation'])
      if desig.parent_designation.name != reader['Parent Designation']
        puts "Invalid  parent assigned to designation #{desig.id.to_s}"
      end
    end
  end

  task :add_new_designations => :environment do
    DESIGNATIONS = [
      "HR Manager", "Senior HR Executive", "Senior Admin Operations",
      "Admin Operations", "Principle Engineer", "Manager", "QA Manager",
      "QA", "Accountant"
    ]
    DESIGNATIONS.each do |designation|
      Designation.create(name: designation)
    end
  end
end
