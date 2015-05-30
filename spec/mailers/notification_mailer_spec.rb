require "spec_helper"

describe NotificationMailer do

  let(:member_1) { create(:member, email: "slim@mail.com", name: "Slim James") }

  describe ".default_params" do
    it "sets from to 'Sensori Collective <info@sensoricollective.com>'" do
      expect(NotificationMailer.default_params[:from]).to eq "Sensori Collective <info@sensoricollective.com>"
    end
  end

  describe "#discussion_notification(params = {})" do
    let(:member_2) { create(:member, email: "phil@mail.com", name: "Five05") }
    let(:member_3) { create(:member, email: "will@mail.com", name: "William") }
    let(:discussion) { create(:discussion, :subject => "check out my neat beat", :member => member_1) }
    let(:response) { create(:response, :member => member_2, :discussion => discussion, :body => "that beat is dope") }

    let!(:email) { NotificationMailer.discussion_notification(:member => member_1, :response => response).deliver }

    it "sends an email to the member passed with the correct subject" do
      expect(ActionMailer::Base.deliveries).not_to be_empty
      expect(email.to).to eq ["slim@mail.com"]
      expect(email.subject).to eq "Five05 posted in a discussion on Sensori"
    end

    context 'when the member receiving the notification also created the discussion' do
      it "formats the text correctly" do
        expect(email.to).to eq ["slim@mail.com"]
        expect(email.subject).to eq "Five05 posted in a discussion on Sensori"
        expect(email.encoded).to include("Hey Slim James, Five05 just commented on your post titled \"check out my neat beat\" in Discussions:")
        expect(email.encoded).to include("that beat is dope")
      end    
    end

    context 'when the member who created the response also created the discussion' do
      let(:response) { build(:response, :member => member_1, :discussion => discussion, :body => "that beat is dope") }
      let!(:email) { NotificationMailer.discussion_notification(:member => member_2, :response => response).deliver }

      it "formats the text correctly" do
        expect(email.to).to eq ["phil@mail.com"]
        expect(email.subject).to eq "Slim James posted in a discussion on Sensori"
        expect(email.encoded).to include("Hey Five05, Slim James just commented on their post titled \"check out my neat beat\" in Discussions:")
        expect(email.encoded).to include("that beat is dope")
      end
    end

    context 'when the member receiving the notification did not create the discussion' do
      let(:discussion) { build(:discussion, :subject => "check out my neat beat", :member => member_3) }
      let!(:email) { NotificationMailer.discussion_notification(:member => member_1, :response => response).deliver }

      it "formats the text correctly" do
        expect(email.to).to eq ["slim@mail.com"]
        expect(email.subject).to eq "Five05 posted in a discussion on Sensori"
        expect(email.encoded).to include("Hey Slim James, Five05 just commented on William&#x27;s post titled \"check out my neat beat\" in Discussions:")
        expect(email.encoded).to include("that beat is dope")
      end
    end
  end

  describe "#tutorial_notification(params = {})" do
    let(:tutorial) { create(:tutorial, title: "Creating a Sampled Bass", description: "How 2 make 1", member: create(:member, name: "Buddy Boy")) }
    
    let!(:email) { NotificationMailer.tutorial_notification(:member => member_1, :tutorial => tutorial).deliver }

    it "sends an email to params[:member]" do
      expect(ActionMailer::Base.deliveries).not_to be_empty

      expect(email.to).to eq ["slim@mail.com"]
      expect(email.subject).to eq "Buddy Boy published a tutorial on Sensori"
      expect(email.encoded).to include("Hey Slim James, Buddy Boy just published a tutorial:")
      expect(email.encoded).to include("Creating a Sampled Bass")
      expect(email.encoded).to include("How 2 make 1")
    end
  end

  describe "#session_notification(params = {})" do
    let(:session) { create(:session, title: "Bobby Bland", description: "Make a beat please!!!", :member => create(:member, name: "Buddy Boy"), end_date: Time.parse('2014-05-05')) }
    let!(:email) { NotificationMailer.session_notification(:member => member_1, :session => session).deliver }

    it "sends an email to params[:member]" do
      expect(ActionMailer::Base.deliveries).not_to be_empty

      expect(email.to).to eq ["slim@mail.com"]
      expect(email.subject).to eq "New Session posted on Sensori!"
      expect(email.encoded).to include("Hey Slim James,")
      expect(email.encoded).to include("NEW SESSION POSTED")
      expect(email.encoded).to include("Bobby Bland")
      expect(email.encoded).to include("Submission Deadline: May 5, 23:59 PST")
    end
  end

end

