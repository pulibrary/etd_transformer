# frozen_string_literal: true

RSpec.describe EtdTransformer::EmbargoDataPoint do
  let(:restriction_status) { "Walk-In Only" }
  let(:spreadsheet_row) do
    {
      "Name" => "This is a fake creative writing thesis - Janice Cheon.xml",
      "Submitted By" => "i:0ǵ.t|adfs 3.0|jcheon",
      "Created" => "2020-05-08 17:16:37 -0400", "Class Year" => "2020",
      "Department" => "Creative Writing",
      "Adviser" => "Devin A. Fore", "Embargo Years" => "5",
      "Walk In Access" => "Yes", "Initial Review" => "Reviewed",
      "Adviser Comments Status" => "N/A", "Adviser Comments" => nil,
      "ODOCReview" => "Approved",
      "Confirmation Sent" => "Yes", "Approval Notification Sent" => "Yes",
      "Mudd Status" => "Pending", "Request Type" => restriction_status,
      "Notify Faculty Adviser" => nil, "Thesis Uploaded" => "No",
      "Check Thesis Uploaded" => "1", "SetFormLink" => nil,
      "Item Type" => "Item", "Path" => "our/strar/Requests"
    }
  end
  let(:embargo_data_point) { described_class.new(spreadsheet_row) }

  context "Request Type: Walk-In Only" do
    it 'has the netid' do
      expect(embargo_data_point.netid).to eq 'jcheon'
    end
    it 'has the title' do
      expect(embargo_data_point.title).to eq spreadsheet_row["Name"]
    end
    it 'has the walk in access' do
      expect(embargo_data_point.walk_in_access).to eq 'Yes'
    end
    it 'has the embargo years' do
      expect(embargo_data_point.years).to eq '5'
    end
  end

  context "Request Type: Embargo + Walk-In" do
    let(:restriction_status) { "Embargo + Walk-In" }
    it 'has the walk in access' do
      expect(embargo_data_point.walk_in_access).to eq 'Yes'
    end
  end
end
