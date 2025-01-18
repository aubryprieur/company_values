class Admin::QvtQuestionsController < Admin::BaseController
  before_action :set_theme
  before_action :set_question, only: [:edit, :update, :destroy]

  def new
    @question = @theme.qvt_questions.build
  end

  def create
    @question = @theme.qvt_questions.build(question_params)
    if @question.save
      redirect_to admin_qvt_theme_path(@theme), notice: 'Question ajoutée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to admin_qvt_theme_path(@theme), notice: 'Question mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    redirect_to admin_qvt_theme_path(@theme), notice: 'Question supprimée avec succès.'
  end

  private

  def set_theme
    @theme = QvtTheme.find(params[:qvt_theme_id])
  end

  def set_question
    @question = @theme.qvt_questions.find(params[:id])
  end

  def question_params
    params.require(:qvt_question).permit(
      :content,
      :question_type,
      :required,
      :position,
      qvt_choices_attributes: [:id, :content, :position, :_destroy]
    )
  end
end
