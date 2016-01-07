require 'spec_helper'

describe String do
  context 'removing control characters' do
    Given(:string) do
      <<-EOS
Joe \u0003\u0093Pro\u0094 on-the-go!
New Line!"
EOS
    end

    Given(:expected_result) do
      <<-EOS
Joe Pro on-the-go!
New Line!"
EOS
    end

    Then { string.remove_control_characters == expected_result }
  end
end
