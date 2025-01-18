# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_13_105744) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "company"
    t.string "organization_type"
    t.index ["email"], name: "index_companies_on_email", unique: true
    t.index ["reset_password_token"], name: "index_companies_on_reset_password_token", unique: true
    t.index ["role"], name: "index_companies_on_role"
  end

  create_table "company_values", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "value_category_id"
    t.index ["value_category_id"], name: "index_company_values_on_value_category_id"
  end

  create_table "company_values_surveys", id: false, force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.bigint "company_value_id", null: false
    t.index ["company_value_id", "survey_id"], name: "index_company_values_surveys_on_company_value_id_and_survey_id"
    t.index ["survey_id", "company_value_id"], name: "index_company_values_surveys_on_survey_id_and_company_value_id"
  end

  create_table "custom_values", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.bigint "employee_id"
    t.bigint "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_custom_values_on_employee_id"
    t.index ["survey_id"], name: "index_custom_values_on_survey_id"
  end

  create_table "employees", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "company_id", null: false
    t.boolean "invitation_accepted", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "department"
    t.string "invitation_token"
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_sent_at"
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["reset_password_token"], name: "index_employees_on_reset_password_token", unique: true
  end

  create_table "qvt_choices", force: :cascade do |t|
    t.bigint "qvt_question_id", null: false
    t.string "content", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qvt_question_id"], name: "index_qvt_choices_on_qvt_question_id"
  end

  create_table "qvt_questions", force: :cascade do |t|
    t.bigint "qvt_theme_id", null: false
    t.text "content", null: false
    t.integer "question_type", default: 0, null: false
    t.boolean "required", default: true
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qvt_theme_id"], name: "index_qvt_questions_on_qvt_theme_id"
  end

  create_table "qvt_response_choices", force: :cascade do |t|
    t.bigint "qvt_response_id", null: false
    t.bigint "qvt_choice_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qvt_choice_id"], name: "index_qvt_response_choices_on_qvt_choice_id"
    t.index ["qvt_response_id", "qvt_choice_id"], name: "index_qvt_response_choices_on_response_and_choice", unique: true
    t.index ["qvt_response_id"], name: "index_qvt_response_choices_on_qvt_response_id"
  end

  create_table "qvt_responses", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "qvt_question_id", null: false
    t.bigint "survey_id", null: false
    t.text "text_answer"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "qvt_question_id", "survey_id"], name: "index_qvt_responses_on_employee_question_survey", unique: true
    t.index ["employee_id"], name: "index_qvt_responses_on_employee_id"
    t.index ["qvt_question_id"], name: "index_qvt_responses_on_qvt_question_id"
    t.index ["survey_id"], name: "index_qvt_responses_on_survey_id"
  end

  create_table "qvt_themes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "responses", force: :cascade do |t|
    t.integer "rating"
    t.text "comment"
    t.bigint "employee_id", null: false
    t.bigint "company_value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at"
    t.index ["company_value_id"], name: "index_responses_on_company_value_id"
    t.index ["employee_id", "company_value_id", "completed_at"], name: "index_responses_on_employee_value_and_completion"
    t.index ["employee_id"], name: "index_responses_on_employee_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
    t.datetime "end_date"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "survey_type", default: 0
    t.index ["company_id", "survey_type"], name: "index_surveys_on_company_id_and_survey_type", unique: true
    t.index ["company_id"], name: "index_surveys_on_company_id"
  end

  create_table "value_categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "company_values", "value_categories"
  add_foreign_key "custom_values", "employees"
  add_foreign_key "custom_values", "surveys"
  add_foreign_key "employees", "companies"
  add_foreign_key "qvt_choices", "qvt_questions"
  add_foreign_key "qvt_questions", "qvt_themes"
  add_foreign_key "qvt_response_choices", "qvt_choices"
  add_foreign_key "qvt_response_choices", "qvt_responses"
  add_foreign_key "qvt_responses", "employees"
  add_foreign_key "qvt_responses", "qvt_questions"
  add_foreign_key "qvt_responses", "surveys"
  add_foreign_key "responses", "company_values"
  add_foreign_key "responses", "employees"
  add_foreign_key "surveys", "companies"
end
