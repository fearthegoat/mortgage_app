$(document).ready(function() {
  $(".button-collapse").sideNav();
  $('.modal-trigger').leanModal();
  var add_fixed_rate, add_adjustable_rate, max_fields, wrapper, x;
  max_fields = 6;
  wrapper = $('#form_start');
  add_fixed_rate = $('#add_fixed_rate');
  add_adjustable_rate = $('#add_adjustable_rate');
  x = 1;

  $(add_fixed_rate).click(function(e) {
    e.preventDefault();
    if (x < max_fields) {
      x++;
      $(wrapper).append('<div class="row"> \
        <div class="input-field col m12 l3"> \
        <input id="fixed_rate" class="validate" placeholder="i.e: 3.75" step=".125" min="1" max="15" type="number" name="mortgage[rate][]"> \
        <label for="fixed_rate" class="active">Interest Rate (APR)</label> \
        </div> \
        <div class="input-field col m12 l3 offset-l2"> \
        <input id="fixed_term" class="validate" placeholder="i.e.: 30" step="5" min="5" max="30" type="number" name="mortgage[term][]"> \
        <label for="fixed_term" class="active">Term (years)</label> \
        </div> \
        <a href="#" class="remove_field">Remove</a> \
        <input id="years_before_first_adjustment" type="hidden" value ="0" name="mortgage[years_before_first_adjustment][]"> \
        <input id="max_rate_adjustment_term" type="hidden" value ="0" name="mortgage[max_rate_adjustment_term][]"> \
        <input id="max_rate_adjustment_period" type="hidden" value ="0" name="mortgage[max_rate_adjustment_period][]"> \
        <input id="years_between_adjustments" type="hidden" value ="0" name="mortgage[years_between_adjustments][]"> \
        </div>');
    listen_to_form();
    }
    else {
      return alert("Only six patrons can be signed up on a single booking.  If your party is larger, either contact us or sign-up on separate bookings.  Thank you.")
    };
  });

  $(wrapper).on('click', '.remove_field', function(e) {
    e.preventDefault();
    $(this).parent('div').remove();
    x--;
  });

  $(add_adjustable_rate).click(function(e) {
    e.preventDefault();
    if (x < max_fields) {
      x++;
      $(wrapper).append('<div class="row"> \
        <div class="input-field col m12 l2"> \
        <input id="adjustable_rate" class="validate" placeholder="i.e: 3.75" step=".125" min="1" max="15" type="number" name="mortgage[rate][]"> \
        <label for="adjustable_rate" class="active">Interest Rate (APR)</label> \
        </div> \
        <div class="input-field col m12 l2"> \
        <input id="adjustable_term" class="validate" placeholder="i.e.: 30" step="5" min="5" max="30" type="number" name="mortgage[term][]"> \
        <label for="adjustable_term" class="active">Term (years)</label> \
        </div> \
        <div class="input-field col m12 l2"> \
        <input id="years_before_first_adjustment" class="validate" placeholder="i.e.: 5" step="1" min="1" max="30" type="number" name="mortgage[years_before_first_adjustment][]"> \
        <label for="years_before_adjustment" class="active">Years Before 1st Adjustment</label> \
        </div> \
        <div class="input-field col m12 l2"> \
        <input id="max_rate_adjustment" class="validate" placeholder="i.e.: 2" step=".125" min="1" max="10" type="number" name="mortgage[max_rate_adjustment_period][]"> \
        <label for="max_rate_adjustment" class="active">Max Rate Adjustment, Each Period</label> \
        </div> \
        <div class="input-field col m12 l2"> \
        <input id="max_rate_adjustment_term" class="validate" placeholder="i.e.: 3" step=".125" min="1" max="10" type="number" name="mortgage[max_rate_adjustment_term][]"> \
        <label for="max_rate_adjustment_term" class="active">Max Rate Adjustment for Term</label> \
        </div> \
        <div class="input-field col m12 l2"> \
        <input id="years_between_adjustments" class="validate" placeholder="i.e.: 1" step="1" min="1" max="15" type="number" name="mortgage[years_between_adjustments][]"> \
        <label for="years_between_adjustments" class="active">Years Between Rate Adjustments</label> \
        </div> \
        <a href="#" class="remove_field">Remove</a> \
        </div>');
    listen_to_form();
    }
    else {
      return alert("Only six patrons can be signed up on a single booking.  If your party is larger, either contact us or sign-up on separate bookings.  Thank you.")
    };
  });
});

$(function(){
  $("#nav a").click(function(e){
    e.preventDefault();
    $('html,body').scrollTo(this.hash,this.hash);
  });
});
