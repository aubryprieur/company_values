class Admin::ValueCategoriesController < Admin::BaseController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = ValueCategory.all
  end

  def new
    @category = ValueCategory.new
  end

  def create
    @category = ValueCategory.new(category_params)
    if @category.save
      redirect_to admin_value_categories_path, notice: 'Catégorie créée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_value_categories_path, notice: 'Catégorie mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.company_values.any?
      redirect_to admin_value_categories_path, alert: 'Cette catégorie contient des valeurs et ne peut pas être supprimée.'
    else
      @category.destroy
      redirect_to admin_value_categories_path, notice: 'Catégorie supprimée avec succès.'
    end
  end

  private

  def set_category
    @category = ValueCategory.find(params[:id])
  end

  def category_params
    params.require(:value_category).permit(:name, :description)
  end
end
