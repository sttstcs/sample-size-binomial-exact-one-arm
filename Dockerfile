# R ベースイメージ
FROM rocker/r-base:4.4.0

# plumber など必要なパッケージに必要なシステム依存関係
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev

# R パッケージのインストール
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org')"

# 作業ディレクトリ
WORKDIR /app

# API ファイルをコピー
COPY plumber.R /app/plumber.R
COPY api.R /app/api.R

# plumber API を起動
CMD ["R", "-e", "pr <- plumber::pr('plumber.R'); pr$run(host='0.0.0.0', port=as.integer(Sys.getenv('PORT')))"]
