class String
  def remove_control_characters
    gsub(/[^ [^[:cntrl:]] | [\s] ]/, '')
  end
end
