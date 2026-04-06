# MK-568 Transfer a Classroom From One District to Another
# https://teachingstrategies.atlassian.net/browse/MK-568

# Please transfer Class ID 250451 

# from District ID 2448 & School ID 18846 

# to District ID 2447 & School ID 18832

# transfer classroom with the students and assigned teachers over to the other district.

classroom = Classroom.find(250451)
district = District.find(2447)
school = School.find(18832)
owner = classroom.owner
students = classroom.students
caregivers = classroom.caregivers

ActiveRecord::Base.transaction do
  if classroom.update(school: school, district: district, school_year_id: 10358)
    puts "Classroom updated successfully."

    owner.update!(district: district)
    
    teachers = classroom.teachers
    teachers << classroom.owner

    teachers.uniq.each do |teacher|
      district_assignment = teacher.assignments.where(assignable: old_district, role: Role.teacher).first
      school_assignment = teacher.assignments.where(assignable: old_school, role: Role.teacher).first

      if district_assignment.nil?
        Assignment.create(user: teacher, assignable: new_district, role: Role.teacher)
      else
        district_assignment.update(assignable: new_district)
      end

      if school_assignment.nil?
        Assignment.create(user: teacher, assignable: new_school, role: Role.teacher)
      else
        school_assignment.update(assignable: new_school)
      end

    end

    
    students.update_all(district: district)
    caregivers.update_all(district: district)

  else
    puts "Failed to update classroom: #{classroom.errors.full_messages.join(', ')}"
    raise ActiveRecord::Rollback
  end
end




#<Classroom:0x00007f801fdde8b0
 # id: nil,
 # name: nil,
 # description: nil,
 # owner_id: nil,
 # school_id: nil,
 # created_at: nil,
 # updated_at: nil,
 # label: nil,
 # classroom_code: nil,
 # grade_level_id: nil,
 # school_year_id: nil>

 #<School:0x00007f7fef22f698 
 # id: nil, 
 # name: nil, 
 # district_id: nil, 
 # school_group_id: nil, 
 # created_at: nil, 
 # updated_at: nil>

 #<SchoolYear:0x00007f8f8655d490 
 # id: nil, 
 # start_date: nil, 
 # end_date: nil, 
 # district_id: nil, 
 # created_at: nil, 
 # updated_at: nil, 
 # name: nil>

 #<Assignment:0x00007f90ae727b08
 # id: nil,
 # user_id: nil,
 # role_id: nil,
 # created_at: nil,
 # updated_at: nil,
 # assignable_id: nil,
 # assignable_type: nil,
 # active: true,
 # active_changed_at: nil>
