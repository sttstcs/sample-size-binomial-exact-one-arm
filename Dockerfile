FROM rocker/r-ver:4.3.2

# 必要な Linux ライブラリ（plumber + httpuv + stringi + rlang 依存すべて）
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libsodium-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libicu-dev \
    pkg-config \
    build-essential

# R パッケージのインストール
RUN R -e "install.packages(c('plumber'), repos='https://cloud.r-project.org')"

# plumber が確実に入ったかチェック
RUN R -e "library(plumber); sessionInfo()"

WORKDIR /app

COPY plumber.R /app/plumber.R
COPY api.R /app/api.R

EXPOSE 8000

CMD ["R", "-e", "pr <- plumber::pr('plumber.R'); pr$run(host='0.0.0.0', port=as.integer(Sys.getenv('PORT')))"]
