FROM rocker/r-ver:4.3.2

# 必要なシステムライブラリ
RUN apt-get update && apt-get install -y \
    libsodium-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libicu-dev \
    pkg-config \
    build-essential

# R パッケージのインストール（依存関係込みで成功する組み合わせ）
RUN R -e "install.packages(c('plumber', 'jsonlite'), repos='https://cloud.r-project.org')"

WORKDIR /app

COPY plumber.R /app/plumber.R
COPY api.R /app/api.R

CMD ["R", "-e", "pr <- plumber::pr('plumber.R'); pr$run(host='0.0.0.0', port=as.integer(Sys.getenv('PORT')))"]
