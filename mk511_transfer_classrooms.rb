# https://teachingstrategies.atlassian.net/browse/MK-511

# transfer all 2023-2024 School Year classrooms (with the class owners and assigned teachers) 
# from the School IDs listed on the left to the School IDs listed on the right:

# LESSONS I LEARNED FROM THIS;
# 1. There was already a snippet close enough to borrow from_school, and I didn't think to look
# 2. Using ChatGPT to improve code attempts is very helpful
# 3. ActiveRecord::Base.transaction is an interesting method that will rollback entire transaction within a block if it didn't work.

# Do one school at a time


# From Schools;
# 
# 
# 


# To Schools;
# 
# 
# 

from_school = School.find(13012)
from_school_sy = from_school.school_years.find_by(name: "2023-2024").id
to_school = School.find(28734)
to_school_sy = to_school.school_years.find_by(name: "2023-2024").id

begin
  ActiveRecord::Base.transaction do
    from_classrooms = from_school.classrooms.where(school_year_id: from_school_sy)
    
    from_classrooms.each do | from_classroom |
      
      from_classroom.update(school: to_school, school_year_id: to_school_sy)
      
      owner = from_classroom.owner_id
      Assignment.create(user_id: owner, role_id: 2, assignable_id: to_school.id, assignable_type: "School")
      Assignment.find_or_create_by(user_id: owner, role_id: 2, assignable_id: to_school.district.id, assignable_type: "District")

      assigned_teachers = from_classroom.assigned_teachers
      assigned_teachers.each do | assigned_teacher |
        Assignment.create(user_id: assigned_teacher.id, role_id: 2, assignable_id: to_school.id, assignable_type: "School")
        Assignment.find_or_create_by(user_id: assigned_teacher, role_id: 2, assignable_id: to_school.district.id, assignable_type: "District")
      end
    end
  end
rescue => e
  p "Error occured: #{e.message}"
  ActiveRecord::Base.rollback_transaction
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
