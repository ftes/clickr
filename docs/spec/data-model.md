# Data Model

All tables use UUID primary keys. All resources are owned by a user (teacher) via `user_id` foreign key, either directly or through a parent chain.

## Entity Relationship Diagram

```mermaid
%% title: Clickr Data Model
erDiagram
    User ||--o{ Class : owns
    User ||--o{ Subject : owns
    User ||--o{ Room : owns
    User ||--o{ Gateway : owns
    User ||--o{ Lesson : owns
    User ||--o{ Student : owns
    User ||--o{ SeatingPlan : owns

    Class ||--o{ Student : contains
    Class ||--o{ SeatingPlan : "has plans for"

    Gateway ||--o{ Device : "connects to"
    Device ||--o{ Button : has

    Room ||--o{ RoomSeat : has
    RoomSeat }o--|| Button : "assigned to"

    SeatingPlan ||--o{ SeatingPlanSeat : has
    SeatingPlanSeat }o--|| Student : "assigned to"

    Lesson }o--|| Subject : "teaches"
    Lesson }o--|| Room : "held in"
    Lesson }o--|| SeatingPlan : "uses"
    Lesson ||--o{ LessonStudent : "attendance"
    Lesson ||--o{ Question : "asks"
    Lesson ||--o{ LessonGrade : "produces"

    LessonStudent }o--|| Student : "references"
    Question ||--o{ QuestionAnswer : "receives"
    QuestionAnswer }o--|| Student : "from"

    Grade }o--|| Student : "for"
    Grade }o--|| Subject : "in"
    Grade ||--o{ LessonGrade : "composed of"
    Grade ||--o{ BonusGrade : "composed of"

    LessonGrade }o--|| Lesson : "from"
    LessonGrade }o--|| Student : "for"
    BonusGrade }o--|| Student : "for"
    BonusGrade }o--|| Subject : "in"
```

## Entities

### User
- `email`: string (unique)
- `hashed_password`: string (bcrypt)
- `admin`: boolean (default false)
- `confirmed_at`: datetime (nullable)

### Class
- `name`: string (required)
- `user_id`: FK -> User

### Student
- `name`: string (required)
- `user_id`: FK -> User
- `class_id`: FK -> Class

### Subject
- `name`: string (required)
- `user_id`: FK -> User

### Room
- `name`: string (required)
- `width`: integer (> 0) - grid columns
- `height`: integer (> 0) - grid rows
- `user_id`: FK -> User

### RoomSeat
- `x`: integer (> 0) - column position in room grid
- `y`: integer (> 0) - row position in room grid
- `room_id`: FK -> Room
- `button_id`: FK -> Button
- Unique: (room_id, x, y) and (room_id, button_id)

### Gateway
- `name`: string (required)
- `url`: string (optional, for zigbee2mqtt web UI link)
- `type`: enum [:zigbee2mqtt, :keyboard]
- `online`: boolean (default false, managed by gateway GenServer)
- `user_id`: FK -> User

### Device
- `name`: string (required)
- `deleted`: boolean (default false, soft-delete for offline devices)
- `gateway_id`: FK -> Gateway

### Button
- `name`: string (required, e.g., "toggle" or keyboard key like "a")
- `device_id`: FK -> Device
- No timestamps

### SeatingPlan
- `name`: string (required)
- `width`: integer (> 0)
- `height`: integer (> 0)
- `user_id`: FK -> User
- `class_id`: FK -> Class

### SeatingPlanSeat
- `x`: integer (> 0)
- `y`: integer (> 0)
- `seating_plan_id`: FK -> SeatingPlan
- `student_id`: FK -> Student
- Unique: (seating_plan_id, x, y) and (seating_plan_id, student_id)

### Lesson
- `name`: string (required)
- `state`: enum [:started, :roll_call, :active, :question, :ended, :graded]
- `grade`: embedded {min: float, max: float} - grading curve parameters
- `user_id`: FK -> User
- `subject_id`: FK -> Subject
- `room_id`: FK -> Room
- `seating_plan_id`: FK -> SeatingPlan

### LessonStudent
- `extra_points`: integer (default 0) - manually awarded bonus points
- `lesson_id`: FK -> Lesson
- `student_id`: FK -> Student
- Unique: (lesson_id, student_id)

### Question
- `name`: string (default "Question")
- `points`: integer (default 1) - points awarded per answer
- `state`: enum [:started, :ended]
- `lesson_id`: FK -> Lesson
- Unique: only one :started question per lesson

### QuestionAnswer
- `question_id`: FK -> Question
- `student_id`: FK -> Student
- Unique: (question_id, student_id) - each student can answer once per question

### Grade
- `percent`: float (0.0 - 1.0) - overall grade for student+subject
- `student_id`: FK -> Student
- `subject_id`: FK -> Subject
- Unique: (student_id, subject_id) - upserted on conflict

### LessonGrade
- `percent`: float (0.0 - 1.0)
- `lesson_id`: FK -> Lesson
- `student_id`: FK -> Student
- `grade_id`: FK -> Grade (nullable, linked after overall grade calculation)
- Unique: (lesson_id, student_id)

### BonusGrade
- `name`: string (default "Bonus Grade")
- `percent`: float (0.0 - 1.0)
- `student_id`: FK -> Student
- `subject_id`: FK -> Subject
- `grade_id`: FK -> Grade (nullable)
