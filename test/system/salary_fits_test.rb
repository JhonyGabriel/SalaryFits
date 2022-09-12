require "application_system_test_case"

class SalaryFitsTest < ApplicationSystemTestCase
  setup do
    @salary_fit = salary_fits(:one)
  end

  test "visiting the index" do
    visit salary_fits_url
    assert_selector "h1", text: "Salary fits"
  end

  test "should create salary fit" do
    visit salary_fits_url
    click_on "New salary fit"

    fill_in "Descricao", with: @salary_fit.descricao
    fill_in "Idade", with: @salary_fit.idade
    fill_in "Name", with: @salary_fit.name
    click_on "Create Salary fit"

    assert_text "Salary fit was successfully created"
    click_on "Back"
  end

  test "should update Salary fit" do
    visit salary_fit_url(@salary_fit)
    click_on "Edit this salary fit", match: :first

    fill_in "Descricao", with: @salary_fit.descricao
    fill_in "Idade", with: @salary_fit.idade
    fill_in "Name", with: @salary_fit.name
    click_on "Update Salary fit"

    assert_text "Salary fit was successfully updated"
    click_on "Back"
  end

  test "should destroy Salary fit" do
    visit salary_fit_url(@salary_fit)
    click_on "Destroy this salary fit", match: :first

    assert_text "Salary fit was successfully destroyed"
  end
end
