# Use an official Ruby 2.7.3 image as a parent image
FROM ruby:2.7.3

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

RUN bundle install

# Run a ruby command when the container launches
CMD ["ruby", "run_survey.rb"]
