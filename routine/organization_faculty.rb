# all teachers and admins for each district under each of the Org IDs 
# for AL DECE orgs within RR. Each report should contain the district name, 
# each teacher and admin’s First Name, Last Name, Email Address, and 
# Role (Teacher, School Admin, District Admin). If they’re a Teacher or 
# School Admin please include the site name for that role.

require 'csv'

org_ids = [88, 89]

def faculity_export(organization)
  headers = %w(First\ Name Last\ Name Email Role Site)
  csv_file = CSV.open("/Users/terrythomas/Downloads/faculty/Org#{organization.id}/faculty_export_#{organization.name.parameterize.underscore}_#{DateTime.current.to_i}.csv", "w") do |csv|
    csv << headers
  
    organization_admins = organization.organization_admins
    organization_admins.each do |admin|
      csv << [admin.first_name, admin.last_name, admin.email, 'Organization Admin', organization.respond_to?(:name) ? organization.name : '']
    end 
    
    organization.districts.each do | district |
      district_admins = district.district_admins
      school_admins = district.schools.map(&:school_admins).flatten
      teachers = district.teachers.distinct

      district_admins.each do |admin|
        csv << [admin.first_name, admin.last_name, admin.email, 'District Admin', district.respond_to?(:name) ? district.name : '']
      end

      school_admins.each do |admin|
        admin.schools_as_admin.each do |school|
          csv << [admin.first_name, admin.last_name, admin.email, 'School Admin', school.respond_to?(:name) ? school.name : '']
        end
      end

      teachers.each do |teacher|
        csv << [teacher.first_name, teacher.last_name, teacher.email, 'Teacher', teacher.schools.first.respond_to?(:name) ? teacher.schools.first.name : '']
      end
    end
  end
end

org_ids.each do | org |
  organization = Organization.find(org)
  faculity_export(organization)
end


