defmodule Clickr.Repo.Migrations.IndexNamesAndOthers do
  use Ecto.Migration

  def change do
    # execute "CREATE EXTENSION pg_trgm"

    # execute "CREATE INDEX bonus_grades_name_index ON bonus_grades USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX buttons_name_index ON buttons USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX classes_name_index ON classes USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX devices_name_index ON devices USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX gateways_name_index ON gateways USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX lessons_name_index ON lessons USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX questions_name_index ON questions USING GIST (name GIST_TRGM_OPS)"

    # execute "CREATE INDEX seating_plans_name_index ON bonus_grades USING GIST (name GIST_TRGM_OPS)"

    # execute "CREATE INDEX rooms_name_index ON rooms USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX students_name_index ON students USING GIST (name GIST_TRGM_OPS)"
    # execute "CREATE INDEX subjects_name_index ON subjects USING GIST (name GIST_TRGM_OPS)"

    create index(:lessons, :state)
  end
end
