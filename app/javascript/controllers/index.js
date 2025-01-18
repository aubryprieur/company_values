import { application } from "./application"
import SurveyController from "./survey_controller"
application.register("survey", SurveyController)
import RadarChartController from "./radar_chart_controller"
application.register("radar-chart", RadarChartController)
import QuestionFormController from "./question_form_controller"
application.register("question-form", QuestionFormController)
import SurveyFormController from "./survey_form_controller"
application.register("survey-form", SurveyFormController)
import SortableController from "./sortable_controller"
application.register("sortable", SortableController)
import QvtFormController from "./qvt_form_controller"
application.register("qvt-form", QvtFormController)
import QvtChartController from "./qvt_chart_controller"
application.register("qvt-chart", QvtChartController)
