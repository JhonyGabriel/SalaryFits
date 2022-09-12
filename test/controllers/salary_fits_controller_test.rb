require "test_helper"

class SalaryFitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @salary_fit = salary_fits(:one)
  end

  test "should get index" do
    get salary_fits_url
    assert_response :success
  end

  test "should get new" do
    get new_salary_fit_url
    assert_response :success
  end

  test "should create salary_fit" do
    assert_difference("SalaryFit.count") do
      post salary_fits_url, params: { salary_fit: { descricao: @salary_fit.descricao, idade: @salary_fit.idade, name: @salary_fit.name } }
    end

    assert_redirected_to salary_fit_url(SalaryFit.last)
  end

  test "should show salary_fit" do
    get salary_fit_url(@salary_fit)
    assert_response :success
  end

  test "should get edit" do
    get edit_salary_fit_url(@salary_fit)
    assert_response :success
  end

  test "should update salary_fit" do
    patch salary_fit_url(@salary_fit), params: { salary_fit: { descricao: @salary_fit.descricao, idade: @salary_fit.idade, name: @salary_fit.name } }
    assert_redirected_to salary_fit_url(@salary_fit)
  end

  test "should destroy salary_fit" do
    assert_difference("SalaryFit.count", -1) do
      delete salary_fit_url(@salary_fit)
    end

    assert_redirected_to salary_fits_url
  end
end
