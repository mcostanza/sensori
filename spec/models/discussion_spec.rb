require 'spec_helper'

describe Discussion do
  
  let(:discussion) { build(:discussion) }
  
  describe "CATEGORIES" do
    it "returns an array of valid categories" do
      expect(Discussion::CATEGORIES).to eq ['general', 'production', 'music-recs', 'collabs', 'events']
    end
  end

  describe "validations" do
    it "is valid given valid attributes" do
      expect(discussion).to be_valid
    end
    it "is invalid without a member" do
      discussion.member = nil
      expect(discussion).not_to be_valid
    end
    it "is invalid without a subject" do
      discussion.subject = ' '
      expect(discussion).not_to be_valid
    end
    it "is invalid without a body" do
      discussion.body = ' '
      expect(discussion).not_to be_valid
    end
    it "is invalid without a category" do
      discussion.category = ' '
      expect(discussion).not_to be_valid
    end
    it "is invalid with a bogus category" do
      discussion.category = 'bogus'
      expect(discussion).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a member" do
      expect(Discussion.reflect_on_association(:member).macro).to eq :belongs_to
    end
    it "has many responses" do
      expect(Discussion.reflect_on_association(:responses).macro).to eq :has_many
    end
    it "has many notifications" do
      expect(Discussion.reflect_on_association(:notifications).macro).to eq :has_many
    end
  end

  describe "callbacks" do
    let!(:now) { Time.now }

    before do
      allow(Time).to receive(:now).and_return(now)
    end

    it "creates a discussion notification for the member creating the discussion" do
      expect {
        discussion.save
      }.to change {
        discussion.notifications.where(member_id: discussion.member.id).count
      }.by(1)
    end

    it "sets last_post_at to now on create" do
      expect {
        discussion.save
      }.to change {
        discussion.last_post_at
      }.to(now)
    end

    it "sets slug from the subject when saving" do
      expect { 
        discussion.save
      }.to change { 
        discussion.slug 
      }.from(nil).to(discussion.subject.parameterize)
    end
  end
  
  it "sets an html version of the body text when body is set" do
    discussion.body = 'test'
    expect(discussion.body_html).not_to be_blank
  end

  describe "#editable?(member)" do
    let(:owner) { build(:member) }
    let(:non_owner) { build(:member) }
    let(:admin) { build(:member, :admin) }

    let(:discussion) { build(:discussion, member: owner) }

    context 'when the passed member is the owner' do
      it "returns true" do
        expect(discussion.editable?(owner)).to be_true
      end
    end

    context 'when the passed member is not the owner' do
      context 'when the passed member is an admin' do
        it "returns true" do
          expect(discussion.editable?(admin)).to be_true
        end
      end

      context 'when the passed member is not an admin' do
        it "returns false" do
          expect(discussion.editable?(non_owner)).to be_false
        end
      end
    end

    context 'when no member is passed' do
      it "returns nil" do
        expect(discussion.editable?(nil)).to be_false
      end
    end

    context 'when the discussion has responses' do
      before do
        create(:response, discussion: discussion)
      end

      context 'when the passed member is the owner' do
        it "returns false" do
          expect(discussion.editable?(owner)).to be_false
        end
      end

      context 'when the passed member is an admin' do
        it "returns true" do
          expect(discussion.editable?(admin)).to be_true
        end
      end
    end
  end

  describe "#attachment_name" do
    context 'when there is an attachment_url' do
      before do
        discussion.attachment_url = "http://s3.amazon.com/sensori/uploads/audio.wav"
      end

      it "returns the filename of the attachment_url" do
        expect(discussion.attachment_name).to eq "audio.wav"
      end  
    end
    
    context 'when there is no attachment_url' do
      before do
        discussion.attachment_url = nil
      end

      it "returns nil" do
        expect(discussion.attachment_name).to be_nil    
      end
    end
  end

  describe "#to_json(options = {})" do
    let(:extended_attributes) do
      discussion.attributes.merge({
        "attachment_name" => discussion.attachment_url,
        "member" => {
          'name' => discussion.member.name,
          'slug' => discussion.member.slug,
          'image_url' => discussion.member.image_url
        }
      })
    end

    it "returns a JSON object with attributes, attachment_name and the member association included" do
      expect(JSON.parse(discussion.to_json)).to eq extended_attributes
    end
  end
end
