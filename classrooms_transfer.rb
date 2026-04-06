classroom_ids = [
  84488, 85167, 144933
]

classrooms = Classroom.where(id: classroom_ids)
to_school_year = SchoolYear.find(7069)
to_school = School.find(24546)

def transfer_classrooms(classrooms:, to_school_year:, to_school:)

  classrooms.each do | classroom |

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
end

transfer_classrooms(classrooms: classrooms, to_school_year: to_school_year, to_school: to_school)