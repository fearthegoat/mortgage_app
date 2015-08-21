class Mortgage
  def initialize
  end

  def interest_payment(principle)
    principle * monthly_interest
  end

  def monthly_interest
    @interest / 12
  end
end
