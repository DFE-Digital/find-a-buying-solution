require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#safe_url" do
    before do
      allow(helper.request).to receive(:host).and_return("example.com")
    end

    it "returns '#' for nil" do
      expect(helper.safe_url(nil)).to eq("#")
    end

    it "returns '#' for non-string input" do
      expect(helper.safe_url(123)).to eq("#")
    end

    it "returns '#' for invalid URLs" do
      expect(helper.safe_url("not a url")).to eq("#")
    end

    context "with internal URLs" do
      it "returns the URL unchanged if on same host" do
        expect(helper.safe_url("https://example.com/path")).to eq("https://example.com/path")
      end

      it "handles paths without host" do
        expect(helper.safe_url("/some/path")).to eq("/some/path")
      end
    end

    context "with external URLs" do
      it "returns redirect URL token for different host" do
        expect(helper.safe_url("https://external.com/path"))
          .to eq("/external-redirect?token=BAhJIh5odHRwczovL2V4dGVybmFsLmNvbS9wYXRoBjoGRVQ%3D--0ccbfe4b58df97e2ec4821d6a7eb302998ac4231ee0283bceb95d50db9087303")
      end
    end
  end

  describe "#external_link_attributes" do
    before do
      allow(helper.request).to receive(:host).and_return("example.com")
    end

    it "returns empty hash for nil" do
      expect(helper.external_link_attributes(nil)).to eq({})
    end

    it "returns empty hash for non-string input" do
      expect(helper.external_link_attributes(123)).to eq({})
    end

    it "returns empty hash for invalid URLs" do
      expect(helper.external_link_attributes("not a url")).to eq({})
    end

    context "with internal URLs" do
      it "returns empty hash if on same host" do
        expect(helper.external_link_attributes("https://example.com/path")).to eq({})
      end

      it "returns empty hash for paths without host" do
        expect(helper.external_link_attributes("/some/path")).to eq({})
      end
    end

    context "with external URLs" do
      it "returns target/rel hash for different host" do
        expect(helper.external_link_attributes("https://external.com/path"))
          .to eq({ target: "_blank", rel: "noopener noreferrer" })
      end
    end
  end
end
