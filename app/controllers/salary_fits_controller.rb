class SalaryFitsController < ApplicationController
  before_action :set_salary_fit, only: %i[ show edit update destroy ]

  # GET /salary_fits or /salary_fits.json
  def index
    @salary_fits = SalaryFit.all
  end

  # GET /salary_fits/1 or /salary_fits/1.json
  def show
  end

  # GET /salary_fits/new
  def new
    @salary_fit = SalaryFit.new
  end

  # GET /salary_fits/1/edit
  def edit
  end

  # POST /salary_fits or /salary_fits.json
  def create
    @salary_fit = SalaryFit.new(salary_fit_params)

    respond_to do |format|
      if @salary_fit.save
        format.html { redirect_to salary_fit_url(@salary_fit), notice: "Salary fit was successfully created." }
        format.json { render :show, status: :created, location: @salary_fit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @salary_fit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /salary_fits/1 or /salary_fits/1.json
  def update
    respond_to do |format|
      if @salary_fit.update(salary_fit_params)
        format.html { redirect_to salary_fit_url(@salary_fit), notice: "Salary fit was successfully updated." }
        format.json { render :show, status: :ok, location: @salary_fit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @salary_fit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /salary_fits/1 or /salary_fits/1.json
  def destroy
    @salary_fit.destroy

    respond_to do |format|
      format.html { redirect_to salary_fits_url, notice: "Salary fit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salary_fit
      @salary_fit = SalaryFit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def salary_fit_params
      params.require(:salary_fit).permit(:name, :idade, :descricao)
    end
end
