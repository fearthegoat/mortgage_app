class Mortgage

  attr_reader :beginning_principle
  attr_accessor :payments_made
  attr_accessor :interest
  attr_accessor :payment
  attr_accessor :remaining_principle

  def initialize(interest_rate, principle, term_in_years)
    @interest = interest_rate/100
    @beginning_principle = principle
    @remaining_principle = principle
    @payment = ((@interest/12)*(@beginning_principle) / (1 - (1 + (@interest/12))**(-term_in_years*12))).round(2) # annuity equation
    @interest_paid = 0.0
    @payments_made = 0
  end

  def interest_payment
    (@remaining_principle * monthly_interest).round(2)
  end

  def principle_payment
    (@payment - interest_payment).round(2)
  end

  def monthly_interest
    @interest / 12
  end

  def make_payment
    @interest_paid += interest_payment
    @remaining_principle -= principle_payment
    @payments_made += 1
  end
end

