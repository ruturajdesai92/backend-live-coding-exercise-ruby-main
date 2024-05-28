require "pstore"

class Survey
  STORE_NAME = "tendable.pstore"
  QUESTIONS = {
    "q1" => "Can you code in Ruby?",
    "q2" => "Can you code in JavaScript?",
    "q3" => "Can you code in Swift?",
    "q4" => "Can you code in Java?",
    "q5" => "Can you code in C#"
  }.freeze

  def initialize
    @store = PStore.new(STORE_NAME)
  end

  # Run the survey
  def run_survey
    do_prompt
    do_report
  end

  # Calculate percentage of true answers for a specific question key
  def percentage_true_answers_for_key(key)
    total_runs = get_saved_runs.size
    return 0 if total_runs.zero?

    true_answers_count = get_saved_runs.count { |run| run[key] == true }

    (100.0 * true_answers_count / total_runs).round(2)
  end

  private

  # Prompt survey questions to user to capture answers
  def do_prompt
    answers = {}
    QUESTIONS.each do |key, question|
      answer = nil
      loop do
        print "#{question} (yes/y/no/n): "
        answer = gets.chomp.downcase
        break if %w[yes no y n].include?(answer)
        puts "Invalid input. Please enter 'yes/y' or 'no/n'."
      end
      answers[key] = answer.start_with?('y')
    end
    save_run(answers)
  end

  # Report survey rating to the user
  def do_report
    rating = calculate_current_rating
    overall_rating = calculate_overall_rating

    puts "Your rating for this run: #{rating}%"
    puts "Your overall rating: #{overall_rating}%"
  end

  # Save current survey answers for future calculations
  def save_run(answers)
    @store.transaction do
      @store[:runs] ||= []
      @store[:runs] << answers
    end
  end

  # Get all saved run answers
  def get_saved_runs
    @store.transaction(true) do
      @store[:runs] || []
    end
  end

  # Calculate current survey rating
  def calculate_current_rating
    yes_answers = get_saved_runs.last.values.count(true)
    (100.0 * yes_answers / QUESTIONS.size).round(2)
  end

  # Calculate overall rating for all saved surveys
  def calculate_overall_rating
    all_runs = get_saved_runs
    total_questions = get_saved_runs.size * QUESTIONS.size
    return 0 if total_questions.zero?

    total_yes = all_runs.sum { |run| run.values.count(true) }
    (100.0 * total_yes / total_questions).round(2)
  end
end

# survey = Survey.new
# survey.run_survey

# # Get the percentage of true answers for questions
# key_to_count = "q1" # Change this key to get other questions
# puts "Number of 'true' answers for '#{Survey::QUESTIONS[key_to_count]}': #{survey.percentage_true_answers_for_key(key_to_count)}"
