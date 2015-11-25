#!/usr/bin/env ruby

require 'ostruct'
require 'pathname'
require 'tempfile'

Txtproc = Pathname.new("#{Dir.pwd}/../cli/bin/txtproc").cleanpath.to_s
TestFile = 'test_input.tmp'

CommentChar   = '#'
SeparatorChar = '%'

Dir.glob("#{Dir.pwd}/*.txt") do |test_file|

  reference_texts = {}
  tests = []
  state = :read_param_or_ref_text
  section = params = input = output = ref_text_no = ''
  line_no = current_test_line_no = 0

  File.open(test_file).each_line do |line_|
    line_no += 1

    line = line_.chomp

    next if line.start_with? CommentChar

    if line.start_with? "#{SeparatorChar}#{SeparatorChar}"
      state = :section_done
      output = section.chomp;
      section = ''
    elsif line.start_with? SeparatorChar
      if line.length > 1
        if state == :read_input
          section = reference_texts[line[1..-1]]
        else
          state = :read_param_or_ref_text
          ref_text_no = line[1..-1]
        end
      else
        if state == :read_param_or_ref_text
          state = :read_input
          params = section.chomp
        elsif state == :read_input
          state = :read_output
          input = section.chomp
        end
        section = ''
      end
    else
      section << line_
    end

    if state == :section_done
      if !ref_text_no.empty?
        reference_texts[ref_text_no] = output;
        ref_text_no = ''
      else
        test = OpenStruct.new
        test.params  = params.split(/\r?\n/).join(' ').chomp
        test.input   = input
        test.output  = output
        test.line_no = current_test_line_no
        tests << test
      end

      current_test_line_no = line_no + 1
      state = :read_param_or_ref_text
      section = ''
      ref_text = ''
    end
  end

  # puts "======"
  # puts reference_texts
  # puts "======"
  # puts tests
  # puts "======"

  tests.each do |test|
    File.open TestFile, 'w' do |test_file|
      test_file.write test.input
    end

    `#{Txtproc} #{test.params} -i"#{TestFile}" -m`
    processed_result = File.open(TestFile).read
    puts "#{test_file}(#{test.line_no}) : #{test.params}\n#{processed_result}\n(!=)\n#{test.output}" if processed_result != test.output

    # if processed_result != test.output
    #   File.open('error_in.tmp', 'w').write test.input
    #   File.open('error_out.tmp', 'w').write test.output
    # end
  end
end
