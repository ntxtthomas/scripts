# script does not bring over district admins. Use this;

Assignment.find(2901280).update(assignable_id: 1448)
Assignment.find(2901324).update(assignable_id: 1448)



school = School.find(13382)
new_district = District.find(1448)


def move_school_to_new_district(school:, new_district:)
  old_district = school.district

  new_school_year = new_district.school_years.in_progress.first
  old_school_year = school.school_years.in_progress.first

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

  school
    .classrooms
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  ## Metrics

  # School Metrics
  # update school year
  school
    .school_metrics
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  # Teacher Metrics
  school
    .teacher_metrics
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  # school
  #   .teacher_metrics
  #   .update_all(school_year_id: new_school_year.id)

  # Classroom Metrics
  ClassroomMetric
    .where(classroom_id: school.classroom_ids, school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  TeacherMetric
    .where(teacher_id: school.teachers.pluck(:id))
    .where(school_year_id: old_school_year.id)
    .update_all(school_year_id: new_school_year.id)

  school.update_attributes(district_id: new_district.id)
end

move_school_to_new_district(school: school, new_district: new_district)

