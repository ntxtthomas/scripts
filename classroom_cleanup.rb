# I ran ran the transfer classrooms script but the initial pass didn't get all the assignments
# and didn't get the archived classrooms with a different school year. This is the clean up effort.

# using a clone; 
# do NOT delete the school until Hilary says everything is ok;

# 1. find on clone

Classroom.find(192517)
student_ids = [1594299, 1938267, 1938268, 1938269, 1594549, 1938270, 1938271, 1938272]


# 2. on production

Classroom.create(
  name: "4-G-Galvanizers EHS",
  owner_id: 1028091,
  school_id: 21440,
  classroom_code: "ipa9jkHB",
  school_year_id: 6406
 )


# 3. on production

classroom = Classroom.find(197190)
student_ids = [1594299, 1938267, 1938268, 1938269, 1594549, 1938270, 1938271, 1938272]
students = Student.where(id: student_ids)
students.each{|student| student.classrooms << classroom }


#4. Classroom Metrics

run `QueueClassroomMetricsBySchoolYearBackfillJob.peform_later(SchoolYear.find(6406))` on production console.
# don't worry about backfilling for the archived classrooms.. in fact, they really shouldn't have been brought over anyway, maybe.


# missing assigned teachers.. teacher owners will have to reassign
# all other metrics run overnight 