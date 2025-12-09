#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  
  forward()
}
# plumber.R / api.R
#install.packages("plumber")
library(plumber)

###############################################
# 計算部分（あなたのコードをそのまま使用）
###############################################

design_one_n <- function(n, p0, p1, alpha) {
  c <- NA_integer_
  size <- NA_real_
  power <- NA_real_
  
  for (x in 0:n) {
    tail_p <- 1 - pbinom(x - 1, n, p0)
    if (tail_p <= alpha) {
      c <- x
      size <- tail_p
      power <- 1 - pbinom(c - 1, n, p1)
      break
    }
  }
  
  data.frame(
    n = n,
    c = c,
    size = size,
    power = power
  )
}

sample_size_exact_envelope <- function(p0, p1,
                                       alpha = 0.025,
                                       power.target = 0.80,
                                       n.min = 5,
                                       n.max = 300) {
  des.list <- lapply(n.min:n.max, design_one_n,
                     p0 = p0, p1 = p1, alpha = alpha)
  des <- do.call(rbind, des.list)
  
  running_min_power <- rep(NA_real_, nrow(des))
  current_min <- Inf
  
  for (i in seq(nrow(des), 1L, by = -1L)) {
    pw <- des$power[i]
    if (!is.na(pw)) {
      current_min <- min(current_min, pw)
    }
    running_min_power[i] <- current_min
  }
  
  des$running_min_power <- running_min_power
  
  idx <- which(!is.na(des$power) &
                 des$running_min_power >= power.target)
  
  if (length(idx) == 0L) {
    return(list(
      n_star = NA_integer_,
      message = "探索範囲内に条件を満たす n がありません"
    ))
  }
  
  n_star <- des$n[min(idx)]
  
  list(
    n_star = n_star
  )
}

###############################################
# ここから API 部分
###############################################

#* サンプルサイズ計算 API
#* @param p0 帰無仮説比率
#* @param p1 対立仮説比率
#* @param alpha 片側有意水準
#* @param power 検出力（目標）
#* @param nmin n の最小値
#* @param nmax n の最大値
#* @get /sample_size
function(p0, p1, alpha = 0.025, power = 0.80, nmin = 5, nmax = 300){
  
  p0 <- as.numeric(p0)
  p1 <- as.numeric(p1)
  alpha <- as.numeric(alpha)
  power <- as.numeric(power)
  nmin <- as.integer(nmin)
  nmax <- as.integer(nmax)
  
  res <- sample_size_exact_envelope(
    p0 = p0, p1 = p1,
    alpha = alpha,
    power.target = power,
    n.min = nmin,
    n.max = nmax
  )
  
  return(res)
}




#* @get /
#* @head /
function(){
  list(status = "ok", message = "API alive")
}

