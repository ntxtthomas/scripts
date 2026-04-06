bulk_import_id = 19561

def undo_caregiver_bulk_import(bulk_import_id)
  bulk_import = BulkImport.find bulk_import_id

  bulk_import.bulk_import_rows.completed.each do |row|
    data = JSON.parse row.data
    teacher = User.find_by email: data['teacher_email']
    school = School.find data['school_id']
    school_year = bulk_import.school_year
    district = bulk_import.district
    caregiver = User.find_by(email: data['caregiver_email']) || User.find_by(phone_number: data['caregiver_cell'])

# destroy classrooms
    teacher.owned_classrooms
           .where('created_at > ?', bulk_import.created_at)
           .where(name: data['class_name'],
                  school: school,
                  school_year: school_year)
           .destroy_all

    student = Student.find_by student_id: data['student_id'],
                              first_name: data['student_first_name'],
                              last_name: data['student_last_name'],
                              district: district

# destroy caregiver invitations <-- seems like this is an invitation, not assignment
    student.invitations
           .where('created_at > ?', bulk_import.created_at)
           .where.not(accepted_at: nil)
           .each { |invitation|
              Assignment.where(role: invitation.role,
                               assignable: invitation.assignable,
                               user: caregiver)
                        .destroy_all

              Assignment.where(role: invitation.role,
                               assignable: invitation.assignable.school,
                               user: caregiver)
                        .destroy_all if invitation.assignable.respond_to? :school

              Assignment.where(role: invitation.role,
                               assignable: invitation.assignable.district,
                               user: caregiver)
                        .destroy_all if invitation.assignable.respond_to? :district
           } if student.present?

# destroy caregiver invitations <-- seems like this is an assignment
    student.invitations
           .where('created_at > ?', bulk_import.created_at)
           .where(inviter: teacher,
                  role: Role.caregiver,
                  email: data['caregiver_email'],
                  phone_number: PhoneNumberNormalizer.normalize(data['caregiver_cell']))
           .destroy_all if student.present?

# destroy teacher assignments
    Assignment.where(role: Role.teacher,
                     user: teacher,
                     assignable: student)
              .where('created_at > ?', bulk_import.created_at)
              .destroy_all

# destroy caregiver
    caregiver.destroy if caregiver.present? && caregiver.created_at > bulk_import.created_at

# destroy student
    student.destroy if student.present? && student.created_at > bulk_import.created_at
  end
end

undo_caregiver_bulk_import(bulk_import_id)
