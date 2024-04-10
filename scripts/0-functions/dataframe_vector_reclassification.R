# FUNCTION 1
ptile_cut_breaks = function(vect.in, weight.in, n.quant) {
  # vect.in = risk_stack$luchange
  # weight.in = risk_stack$area
  # n.quant = 5
  
  # start of function
  n.probs = seq(0, 1, length.out = n.quant + 1)
  
  # rcl.mtx = data.frame(
  #   # ptile = n.probs,
  #   low = wtd.quantile(vect.in, n.probs, weight = weight.in)[1:n.quant],
  #   high = c(wtd.quantile(vect.in, n.probs, weight = weight.in)[2:n.quant], Inf),
  #   id = seq(1, n.quant)
  # )
  
  cut_breaks = wtd.quantile(vect.in, n.probs, weight = weight.in)
  return(cut_breaks)
}

# FUNCTION 2
ptile_classify = function(vect.in, weight.in, n.quant){
  # vect.in = risk_stack$luchange
  # weight.in = risk_stack$area
  # n.quant = 5
  
  cut_breaks = ptile_cut_breaks(vect.in = vect.in, weight.in = weight.in, n.quant = n.quant)
  
  classed_vector = base::cut(x = vect.in, breaks = cut_breaks, include.lowest = TRUE, labels = F)  
  return(classed_vector)
}
