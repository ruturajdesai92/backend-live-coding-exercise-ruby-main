require_relative '../survey'

RSpec.describe Survey do
  let(:survey) { Survey.new }

  before do
    # Set PStore value to an empty array before each test
    survey.instance_variable_get(:@store).transaction { survey.instance_variable_get(:@store)[:runs] = [] }
  end

  describe "#initialize" do
    it "initializes a PStore object" do
      expect(survey.instance_variable_get(:@store)).to be_a(PStore)
    end
  end

  describe "#do_prompt" do
    it "saves survey answers" do
      allow(survey).to receive(:gets).and_return("n")

      expect { survey.send(:do_prompt) }.to change { survey.send(:get_saved_runs).size }.by(1)
    end
  end

  describe "#do_report" do
    it "outputs survey ratings" do
      answers = { "q1" => true, "q2" => false, "q3" => true, "q4" => false, "q5" => true }
      survey.send(:save_run, answers)

      expect { survey.send(:do_report) }.to output(/Your rating for this run:/).to_stdout
      expect { survey.send(:do_report) }.to output(/Your overall rating:/).to_stdout
    end
  end

  describe "#save_run" do
    it "saves survey runs" do
      answers = { "q1" => true, "q2" => false, "q3" => true, "q4" => false, "q5" => true }

      expect { survey.send(:save_run, answers) }.to change { survey.send(:get_saved_runs).size }.by(1)
    end
  end

  describe "#calculate_current_rating" do
    it "calculates current survey rating" do
      answers = { "q1" => true, "q2" => false, "q3" => true, "q4" => false, "q5" => true }
      survey.send(:save_run, answers)

      expect(survey.send(:calculate_current_rating)).to eq(60.0)
    end
  end

  describe "#calculate_overall_rating" do
    it "calculates overall survey rating" do
      answers1 = { "q1" => true, "q2" => false, "q3" => true, "q4" => false, "q5" => true }
      answers2 = { "q1" => true, "q2" => true, "q3" => true, "q4" => false, "q5" => true }
      survey.send(:save_run, answers1)
      survey.send(:save_run, answers2)

      expect(survey.send(:calculate_overall_rating)).to eq(70.0)
    end
  end

  describe "#percentage_true_answers_for_key" do
    it "calculates percentage of true answers for a specific question" do
      answers1 = { "q1" => true, "q2" => false, "q3" => true, "q4" => false, "q5" => true }
      answers2 = { "q1" => true, "q2" => true, "q3" => true, "q4" => false, "q5" => true }
      survey.send(:save_run, answers1)
      survey.send(:save_run, answers2)

      expect(survey.percentage_true_answers_for_key("q1")).to eq(100.0)
      expect(survey.percentage_true_answers_for_key("q2")).to eq(50.0)
    end
  end
end
