defmodule Clickr do
  use Boundary,
    deps: [],
    exports: [
      Accounts,
      Accounts.{User},
      Classes,
      Classes.{Class, SeatingPlan, SeatingPlanSeat},
      Devices,
      Devices.{Button, Device, Gateway},
      Grades,
      Grades.{BonusGrade, Grade, LessonGrade},
      Lessons,
      Lessons.{Lesson, LessonStudent, Question, QuestionAnswer},
      PubSub,
      Rooms,
      Rooms.{Room, RoomSeat},
      Schema,
      Students,
      Students.{Student},
      Subjects,
      Subjects.{Subject}
    ]

  @moduledoc """
  Clickr keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
end
