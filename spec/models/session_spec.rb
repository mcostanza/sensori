require 'spec_helper'

describe Session do
  let(:session_model) { build(:session) }

  describe "validations" do
    it "is valid given valid attributes" do
      expect(session_model).to be_valid
    end
    it "is invalid without a member" do
      session_model.member = nil
      expect(session_model).not_to be_valid
    end
    it "is invalid without a title" do
      session_model.title = nil
      expect(session_model).not_to be_valid
    end
    it "is invalid without a description" do
      session_model.description = nil
      expect(session_model).not_to be_valid
    end
    it "is invalid without a image" do
      session_model.remove_image!
      expect(session_model).not_to be_valid
    end
    it "is invalid without an end_date" do
      session_model.end_date = nil
      expect(session_model).not_to be_valid 
    end
  end

  describe "associations" do
    it "belongs to a member" do
      expect(Session.reflect_on_association(:member).macro).to eq :belongs_to
    end
    it "has many submissions" do
      expect(Session.reflect_on_association(:submissions).macro).to eq :has_many
    end
    it "has many sample_packs" do
      expect(Session.reflect_on_association(:sample_packs).macro).to eq :has_many
    end
  end
  
  describe "callbacks" do
    before do
      allow(SessionNotificationWorker).to receive(:perform_async)
    end

    it "sets a slug from the title when saving" do
      expect {
        session_model.save
      }.to change {
        session_model.slug
      }.from(nil).to(session_model.title.parameterize)
    end

    it "creates a worker to deliver session notifications" do
      session_model.save
      expect(SessionNotificationWorker).to have_received(:perform_async).with(session_model.id)
    end
  end

  describe "#active?" do
    let!(:session_model) { create(:session) }
    let!(:now) { Time.now }
    let!(:now_pst) { now.in_time_zone("Pacific Time (US & Canada)") }

    before do
      allow(Time).to receive(:now).and_return(now)
    end

    it "compares against the current time in PST" do
      expect(now).to receive(:in_time_zone).with("Pacific Time (US & Canada)").and_return(now_pst)
      session_model.active?
    end

    context 'when end_date is in the past' do
      before do
        session_model.end_date = 2.days.ago
      end

      it "returns false" do
        expect(session_model.active?).to be false
      end
    end

    context 'when end_date is in the future' do
      before do
        session_model.end_date = 1.day.from_now
      end

      it "returns true" do
        expect(session_model.active?).to be true
      end
    end

    context 'when end_date is today' do
      before do
        session_model.end_date = now
      end

      it "returns true" do
        expect(session_model.active?).to be true
      end
    end

    context 'when end_date is not set' do
      before do
        session_model.end_date = nil
      end

      it "returns false" do
        expect(session_model.active?).to be false
      end
    end
  end
end
