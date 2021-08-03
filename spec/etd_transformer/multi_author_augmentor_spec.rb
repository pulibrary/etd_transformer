# frozen_string_literal: true

RSpec.describe EtdTransformer::MultiAuthorAugmentor do
  context 'multi author metadata' do
    let(:spreadsheet) { "#{$fixture_path}/multiauthor/ExcelExport.xlsx" }
    let(:directory) { "#{$fixture_path}/multiauthor/" }
    let(:metadata_file) { "#{$fixture_path}/multiauthor/submission_10394/dublin_core.xml" }
    let(:backup_file) { "#{$fixture_path}/multiauthor/submission_10394/dublin_core.xml_backup" }
    let(:options) do
      {
        spreadsheet: spreadsheet,
        directory: directory
      }
    end

    after do
      FileUtils.mv(backup_file, metadata_file) if File.exist? backup_file
    end

    it "finds the DataSpace objects described by the spreadsheet" do
      maa = described_class.new(options)
      expect(maa.theses_requiring_augmentation.keys.count).to eq 2
    end

    it "adds multiple authors to a thesis" do
      dublin_core = File.open(metadata_file) { |f| Nokogiri::XML(f) }
      authors = dublin_core.xpath("/dublin_core/dcvalue[@element='contributor'][@qualifier='author']").map { |a| a.text.strip }
      expect(authors).to contain_exactly("Sadalgekar, Gargi")

      described_class.add_metadata(options)

      dublin_core = File.open(metadata_file) { |f| Nokogiri::XML(f) }
      authors = dublin_core.xpath("/dublin_core/dcvalue[@element='contributor'][@qualifier='author']").map { |a| a.text.strip }
      expect(authors).to contain_exactly("Sadalgekar, Gargi", "Walrath, Jacob", "Wilson, Samarie")
    end
  end
end
