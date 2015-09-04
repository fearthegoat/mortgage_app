class MortgagesController < ApplicationController

  def index
  end

  def create
    mortgages = []
    params[:mortgage][:rate].each_with_index do |rate, index|
      mortgage_new = []
      mortgage_new << params[:mortgage][:loan].to_d
      mortgage_new << rate.to_d
      mortgage_new << params[:mortgage][:term][index].to_i
      mortgages << mortgage_new
    end
    m = []
    mortgages.each do |loan, rate, term|
      mortgage_new = Mortgage.new(rate, loan, term)
      m << mortgage_new.payment
    end
    raise :oops
    # render 'create.js'
  end

end
