classroom = Classroom.find(140767)
to_school_year = SchoolYear.find(7069)
to_school = School.find(24547)

def transfer_classroom(classroom:, to_school_year:, to_school:)

  from_district = classroom.district
  from_school_year = to_school_year.nil? ? nil : from_district.school_years.in_progress.first
  from_school = classroom.school
  to_district = to_school.district

  classroom.update_attributes(
    school: to_school,
    school_year: to_school_year
  )

  Assignment.where(
    user: classroom.caregivers,
    role: Role.caregiver,
    assignable: from_district
  ).each do |assignment|
    assignment.update_attributes(assignable: to_district)
  end

  teachers = classroom.teachers.include?(classroom.owner) ?
      classroom.teachers :
      (classroom.teachers + [classroom.owner])

  Assignment.where(
    user: teachers.pluck(:id),
    role: Role.teacher,
    assignable: from_school
  ).each do |assignment|
    assignment.update_attributes(assignable: to_school)
  end

  classroom.students.each do |student|
    student.update_attributes(district: to_district)
  end

  classroom
    .classroom_metrics
    .where(school_year_id: from_school_year.id)
    .update_all(school_year_id: to_school_year.id)

end

transfer_classroom(classroom: classroom, to_school_year: to_school_year, to_school: to_school)