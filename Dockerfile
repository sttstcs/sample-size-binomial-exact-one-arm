FROM rocker/r-base:4.4.0

# plumber の依存ライブラリ（← ここが重要）
RUN apt-get update && apt-get install -y \
    libsodium-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    pkg-config \
    build-essential

# R パッケージ plumber をインストール
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org')"

# 作業ディレクトリ
WORKDIR /app

# API スクリプトをコピー
COPY plumber.R /app/plumber.R
COPY api.R /app/api.R

# plumber 起動
CMD ["R", "-e", "pr <- plumber::pr('plumber.R'); pr$run(host='0.0.0.0', port=as.integer(Sys.getenv('PORT')))"]
