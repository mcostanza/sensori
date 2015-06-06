require 'spec_helper'

describe Tutorial do
  let(:tutorial) { build(:tutorial) }
  
  describe "validations" do
    it "is valid given valid attributes" do
      expect(tutorial).to be_valid
    end
    it "is invalid without a title" do
      tutorial.title = nil
      expect(tutorial).not_to be_valid
    end
    it "is invalid without a description" do
      tutorial.description = nil
      expect(tutorial).not_to be_valid
    end
    it "is invalid without a member" do
      tutorial.member = nil
      expect(tutorial).not_to be_valid
    end
    it "is invalid without body_html" do
      tutorial.body_html = nil
      expect(tutorial).not_to be_valid
    end
  end

  describe "callbacks" do
    describe "before_save" do
      before do
        allow(tutorial).to receive(:format_table_of_contents)
      end

      it "formats the table of contents" do
        expect(tutorial).to receive(:format_table_of_contents)
        tutorial.save
      end
    end

    it "sets slug from the title" do
      tutorial.save
      expect(tutorial.slug).to eq tutorial.title.parameterize
    end

    describe "after_update" do
      let(:tutorial) { create(:tutorial, published: false) }

      before do
        allow(TutorialNotificationWorker).to receive(:perform_async)
      end

      context 'when published changed to true' do
        it "creates a worker to send tutorial notifications if published changed false => true" do
          tutorial.update_attributes(published: true)
          expect(TutorialNotificationWorker).to have_received(:perform_async).with(tutorial.id)
        end
      end

      context 'when published did not change to true' do
        it "does not create a worker to send tutorial notifications" do
          tutorial.update_attributes(title: "new title")
          tutorial.deliver_tutorial_notifications_if_published
          expect(TutorialNotificationWorker).not_to have_received(:perform_async)
        end
      end
    end
  end

  describe "#editable?(member)" do
    let(:admin) { build(:member, :admin) }
    let(:creator) { tutorial.member }
    let(:other_member) { build(:member) }

    context 'when member is an admin' do
      it "returns true" do
        expect(tutorial.editable?(admin)).to be true
      end
    end

    context 'when member is the creator of the tutorial' do
      it "returns true" do
        expect(tutorial.editable?(creator)).to be true
      end
    end

    context 'when member is not the creator and not an admin' do
      it "returns false" do
        expect(tutorial.editable?(other_member)).to be false
      end
    end

    context 'when member is nil' do
      it "returns false" do
        expect(tutorial.editable?(nil)).to be false
      end
    end
  end

  describe "#youtube_image_url" do
    it "returns an image url based on self.youtube_id" do
      expect(tutorial.youtube_image_url).to eq "http://img.youtube.com/vi/#{tutorial.youtube_id}/0.jpg"
    end

    context 'when youtube_id is not set' do
      before do
        tutorial.youtube_id = nil
      end

      it "returns a placeholder image" do
        expect(tutorial.youtube_image_url).to eq "https://s3.amazonaws.com/sensori/video-placeholder.jpg" 
      end
    end
  end

  describe "#image_url(size)" do
    it "returns the youtube_image_url regardless of the size passed" do
      expect(tutorial.image_url(:thumb)).to eq tutorial.youtube_image_url
      expect(tutorial.image_url(:random)).to eq tutorial.youtube_image_url
      expect(tutorial.image_url(:random)).to eq tutorial.youtube_image_url
    end
    
    it "does not require a size be passed" do
      expect(tutorial.image_url).to eq tutorial.youtube_image_url
    end
  end

  describe "#youtube_embed_url" do
    it "returns an embed url based on self.youtube_id" do
      expect(tutorial.youtube_embed_url).to eq "http://www.youtube.com/embed/#{tutorial.youtube_id}"
    end
  end

  describe "#youtube_video_url" do
    it "returns a video url based on self.youtube_id" do
      expect(tutorial.youtube_video_url).to eq "http://www.youtube.com/watch?v=#{tutorial.youtube_id}"
    end
  end

  describe "#format_table_of_contents" do
    let(:tutorial) { build(:tutorial) }
    let(:formatter) { double(TutorialTableOfContentsService) }
    let(:formatted_content) { 'formatted content' }

    before do
      allow(TutorialTableOfContentsService).to receive(:new).and_return(formatter)
      allow(formatter).to receive(:format).and_return(formatted_content)
    end

    it "processes the tutorial with a table of contents formatter and set the body_html from the result" do
      expect(TutorialTableOfContentsService).to receive(:new).with(tutorial).and_return(formatter)
      expect(formatter).to receive(:format).and_return(formatted_content)
      tutorial.format_table_of_contents
      expect(tutorial.body_html).to eq formatted_content
    end

    context 'when include_table_of_contents is false' do
      let(:tutorial) { build(:tutorial, include_table_of_contents: false) }

      it "does nothing" do
        expect(TutorialTableOfContentsService).not_to receive(:new)
        expect {
          tutorial.format_table_of_contents
        }.not_to change { tutorial.body_html }
      end
    end
  end

  describe "#body_components" do
    context 'when the attribute is nil' do
      before do
        tutorial.body_components = nil
      end

      it "returns an array of default components" do
        expect(tutorial.body_components).to eq [{ "type" => "text", "content" => "" }, { "type" => "gallery", "content" => [] }]
      end  
    end
  end

  describe "#prepare_preview(params)" do
    let(:params) do
      {
        :title => "new title",
        :description => "this is it",
        :body_html => "new body html",
        :youtube_id => "123123",
        :attachment_url => "http://s3.amazon.com/samples.zip",
        :include_table_of_contents => "true"
      }
    end

    before do
      allow(tutorial).to receive(:format_table_of_contents)
    end

    it "sets title, description, body_html, youtube_id, and attachment_url" do
      tutorial.prepare_preview(params)
      expect(tutorial.title).to eq params[:title]
      expect(tutorial.description).to eq params[:description]
      expect(tutorial.youtube_id).to eq params[:youtube_id]
      expect(tutorial.body_html).to eq params[:body_html]
      expect(tutorial.attachment_url).to eq params[:attachment_url]
    end

    context 'when additional attributes are passed' do
      before do
        params[:id] = 123
        params[:body_components] = 'oops'
      end

      it "does not set other attributes" do
        tutorial.prepare_preview(params)
        expect(tutorial.id).not_to eq 123
        expect(tutorial.body_components).not_to eq "oops"
      end  
    end
    
    context 'when params[:include_table_of_contents] is true' do
      it "formats the table of contents if params[:include_table_of_contents].to_s is 'true'" do
        expect(tutorial).to receive(:format_table_of_contents)
        tutorial.prepare_preview(params)
      end  
    end
    
    context 'when params[:include_table_of_contents] is not true' do
      before do
        params[:include_table_of_contents] = "false"
      end
      
      it "does not format the table of contents if params[:include_table_of_contents] is not true" do
        expect(tutorial).not_to receive(:format_table_of_contents)
        tutorial.prepare_preview(params)
      end      
    end

    it "does not save the tutorial" do
      expect {
        tutorial.prepare_preview(params)
      }.not_to change {
        tutorial.updated_at
      }
    end
  end
end
