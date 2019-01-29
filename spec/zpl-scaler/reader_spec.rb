RSpec.describe ZplScaler::ZplReader do
  def self.it_parses_cmd(zpl_code, cmd_name, cmd_params)
    it "parses cmd #{zpl_code.inspect}" do
      reader = ZplScaler::ZplReader.new(zpl_code)
      cmd = reader.next_command
      expect(cmd.name).to eq cmd_name
      expect(cmd.params).to eq cmd_params
    end
  end

  it_parses_cmd "^AB\n ", "AB", []
  it_parses_cmd "^AB,", "AB", ["", ""]
  it_parses_cmd "^ABC", "AB", ["C"]
  it_parses_cmd "^ABC,   \n", "AB", ["C", ""]
  it_parses_cmd "^AB1,   ,,4", "AB", ["1", "", "", "4"]
  it_parses_cmd "^AB42,-21,z", "AB", ["42", "-21", "z"]
  it_parses_cmd "^AB^CD", "AB", []
  it_parses_cmd "^AB\n\n^CD", "AB", []
  it_parses_cmd "^A@R,10,10,R:font.ttf", "A@", ["R", "10", "10", "R:font.ttf"]
  it_parses_cmd "^AB1,\n****foobar\n^AB2", "AB", ["1", ""]

  it "parses a single zpl cmd to ruby and back" do
    code = "^XY1,2,3"

    reader = ZplScaler::ZplReader.new(code)
    cmd = reader.next_command
    expect(cmd.name).to eq "XY"
    expect(cmd.params).to eq ["1", "2", "3"]
    expect(cmd.to_zpl_string).to eq code
  end

  it "parses multiple zpl cmds to ruby and back"do
    code = "^AB001,48,2\n^CD\n^Y3azerty,"
    reader = ZplScaler::ZplReader.new(code)

    cmd = reader.next_command
    expect(cmd.name).to eq "AB"
    expect(cmd.params).to eq ["001", "48", "2"]
    expect(cmd.to_zpl_string).to eq "^AB001,48,2"

    cmd = reader.next_command
    expect(cmd.name).to eq "CD"
    expect(cmd.params).to eq []
    expect(cmd.to_zpl_string).to eq "^CD"

    cmd = reader.next_command
    expect(cmd.name).to eq "Y3"
    expect(cmd.params).to eq ["azerty", ""]
    expect(cmd.to_zpl_string).to eq "^Y3azerty,"

    expect(reader.next_command).to be_nil
  end
end
