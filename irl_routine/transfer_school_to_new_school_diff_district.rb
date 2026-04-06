# https://teachingstrategies.atlassian.net/browse/MK-696
# Transfer School from one district to another
# Problem: It times out in production app

# from Snippets; 

def transfer_school(school:, new_school:)
  new_district = new_school.district
  old_district = school.district

  new_school_year = new_school.school_years.current.first
  old_school_year = school.school_years.current.first

  # Update all school assignments
  school
    .assignments
    .update_all(assignable_id: new_school.id)

  # Update Admin assignments
  school.school_admins.each do |school_admin|
    school_admin
      .district_assignments
      .where(role: Role.school_admin, assignable_id: old_district.id)
      .update_all(assignable_id: new_district.id)
  end

  # Update Teaher assignments
  school.teachers.each do |teacher|
    teacher
      .district_teacher_assignments
      .where(assignable_id: old_district.id)
      .update_all(assignable_id: new_district.id)
  end

  # Update Caregiver assignments
  school.caregivers.each do |caregiver|
    caregiver
      .district_assignments
      .where(role: Role.caregiver, assignable_id: old_district.id)
      .update_all(assignable_id: new_district.id)
  end

  # Update Students
  school
    .students
    .update_all(district_id: new_district.id)

  # Update Classrooms
  school
    .classrooms
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  school
    .classrooms
    .update_all(school_id: new_school.id)

  ## Metrics

  # School Metrics
  # update school year
  school
    .school_metrics
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  # update school_id
  school
    .school_metrics
    .update_all(school_id: new_school.id)

  # Teacher Metrics
  school
    .teacher_metrics
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  school
    .teacher_metrics
    .update_all(school_year_id: new_school_year.id)

  # Classroom Metris
  ClassroomMetric
    .where(classroom_id: school.classroom_ids, school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  TeacherMetric
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  TeacherMetric
    .where(school_id: school.id)
    .update_all(school_id: new_school.id)
end

school = School.find(16030)
new_school = School.find(30041)
transfer_school(school: school, new_school:)
