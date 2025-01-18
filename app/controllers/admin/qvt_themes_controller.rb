class Admin::QvtThemesController < Admin::BaseController
  before_action :set_theme, only: [:show, :edit, :update, :destroy, :preview]

  def index
    authorize QvtTheme
    @themes = QvtTheme.all.order(:name)
  end

  def show
    authorize @theme
  end

  def new
    authorize QvtTheme
    @theme = QvtTheme.new
  end

  def create
    authorize QvtTheme
    @theme = QvtTheme.new(theme_params)
    if @theme.save
      redirect_to admin_qvt_themes_path, notice: 'Thème créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @theme
  end

  def update
    authorize @theme
    if @theme.update(theme_params)
      redirect_to admin_qvt_themes_path, notice: 'Thème mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @theme
    @theme.destroy
    redirect_to admin_qvt_themes_path, notice: 'Thème supprimé avec succès.'
  end

  def preview
    authorize @theme
    @questions = @theme.qvt_questions.order(:position)
  end

  private

  def set_theme
    @theme = QvtTheme.find(params[:id])
  end

  def theme_params
    params.require(:qvt_theme).permit(:name, :description)
  end
end
