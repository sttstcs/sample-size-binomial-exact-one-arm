FROM r-base

# 必要なシステムパッケージ
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# plumber をインストール
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org')"

# 作業ディレクトリ
WORKDIR /app

# API スクリプトをコピー
COPY plumber.R /app/plumber.R
COPY api.R /app/api.R

# コンテナ起動時に plumber API を実行
CMD ["R", "-e", "pr <- plumber::pr('plumber.R'); pr$run(host='0.0.0.0', port=as.integer(Sys.getenv('PORT')))"]
