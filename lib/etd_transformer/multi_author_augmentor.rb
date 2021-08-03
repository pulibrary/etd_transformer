# frozen_string_literal: true

module EtdTransformer
  ##
  # Add multi-author metadata to DataSpace ETDs
  class MultiAuthorAugmentor
    attr_reader :spreadsheet, :directory

    ##
    # Convenience method for kicking off addition of multi-author metadata.
    # @param [Hash] options
    # @return [EtdTransformer::MultiAuthorAugmentor]
    # @example
    #  EtdTransformer::MultiAuthorAugmentor.add_metadata(spreadsheet: '/path/to/foo.xlsx', directory: '/path/to/bar')
    def self.add_metadata(options)
      maa = EtdTransformer::MultiAuthorAugmentor.new(options)
      maa.add_metadata
      maa
    end

    def initialize(options)
      @spreadsheet = options[:spreadsheet]
      @directory = options[:directory]
    end

    ##
    # Augment author data as recorded in dublin_core.xml for each thesis.
    def add_metadata
      theses_requiring_augmentation.each do |thesis_group|
        data = thesis_group[1]
        thesis_id = data.select { |a| data[a][:status] == "Approved" }.keys.first
        authors = data.values.map { |a| a[:student_name] }

        dublin_core_file_path = File.join(@directory, "submission_#{thesis_id}", "dublin_core.xml")
        dublin_core = File.open(dublin_core_file_path) { |f| Nokogiri::XML(f) }
        author_node = dublin_core.xpath("/dublin_core/dcvalue[@element='contributor'][@qualifier='author']")
        authors_in_file = author_node.map { |a| a.text.strip }

        authors.each do |author|
          next if authors_in_file.include?(author)

          new_author_node = Nokogiri::XML::Node.new('dcvalue', dublin_core)
          new_author_node['element'] = "contributor"
          new_author_node['qualifier'] = 'author'
          new_author_node.content = author
          author_node.first.add_next_sibling(new_author_node)
        end
        FileUtils.cp(dublin_core_file_path, "#{dublin_core_file_path}_backup")
        File.write(dublin_core_file_path, dublin_core.to_xml)
      end
    end

    ##
    # Get a list of the theses that need extra author metadata. This is all of the theses
    # in @spreadsheet that are multi-author and also Approved
    # @return [Array]
    def theses_requiring_augmentation
      theses = {}
      creek = Creek::Book.new @spreadsheet, with_headers: true
      m = creek.sheets[0]
      m.simple_rows.each_with_index do |row, index|
        next if index.zero? # skip the header row
        next unless row["Multi Author Group"]

        groupid = row["Multi Author Group"]
        rowid = row["ID"]
        theses[groupid] = {} if theses[groupid].nil?
        theses[groupid][rowid] = {}
        theses[groupid][rowid][:student_name] = row["Student name"]
        theses[groupid][rowid][:status] = row["Status"]
      end
      theses
    end
  end
end
