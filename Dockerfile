FROM ruby:3.4.5

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y nodejs default-mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Expose port
EXPOSE 3000

# Default command (will be overridden by docker-compose)
CMD ["rails", "server", "-b", "0.0.0.0"]
