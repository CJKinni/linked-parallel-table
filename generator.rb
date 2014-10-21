#!/bin/ruby

def read_file(file_name)
  file = File.open(file_name, "r")
  data = file.read
  file.close
  return data
end

def edit_file(ptoa)
  final_ptoa = "<p style='font-family:\"Andale Mono\", \"Monotype.com\", monospace;'>"
  usc_sec = 0
  cfr_title = 0
  appendix = false
  ussal = false
  ptoa.each_line do |line|

  	if line[/^  --/] == nil # To deal with line 5
  		line = line.gsub(/--/, ' &mdash; ')
  	end

  	if line.include? "Parts"
  		line.sub(/(\d+) Parts (\d+)/) do |full_match|
  			cfr_title = $1
  		end
  		line = line.gsub(/(\d+) Parts (\d+-?\d?\d?\d?[a-zA-Z]?)/, '<a href="http://www.law.cornell.edu/cfr/text/\1/part-\2">\1 Parts \2</a>')
  		line = line.gsub(/, (\d+-?\d?\d?\d?[a-zA-Z]?)/, ', <a href="http://www.law.cornell.edu/cfr/text/' + cfr_title + '/part-\1">\1</a>')
  	end


  	if line.include? "U.S.C. Appendix"
  		appendix = true
  	elsif line.include? "United States Statutes at Large"
  		ussal = true
  	elsif line.include? "U.S.C."
  		line.sub(/^(\d+) U.S.C./) do |full_match|
            usc_sec = $1
  			line = "<a href='http://www.law.cornell.edu/uscode/text/" + $1 + "'>" + line.chomp + "</a>"
  		end
  		appendix = false
  	elsif line[/^  (\d+[a-zA-Z]?)/] != nil
  		if ((appendix == false) && (ussal == false)) # Don't show USC if in Appendix or in another section.
	  		line.sub(/^  (\d+[a-zA-Z]?[a-zA-Z]?-?\d?[a-zA-Z]?)/) do |full_match|
  				line = "&nbsp;&nbsp;  <a href='http://www.law.cornell.edu/uscode/text/" + usc_sec.to_s + "/" + $1 + "'>" + $1 + "</a>" + line[full_match.length,1000]
  			line.gsub(/--(\d+[a-zA-Z]?)/, '--<a href="http://www.law.cornell.edu/uscode/text/"' + usc_sec.to_s + '/' + $1 + '">' + $1 + '"</a>')
  			end
  		end
  	elsif line[/^\s+(\d+-?\d?\d?\d?[a-zA-Z]?)(,|$)/] != nil
  		line = line.gsub(/(\d+-?\d?\d?\d?[a-zA-Z]?)((,|$))/, '<a href="http://www.law.cornell.edu/cfr/text/' + cfr_title + '/part-\1">\1</a>\2')
  	end
  	line = line.gsub(/(\d+) Part (\d+-?\d?\d?\d?[a-zA-Z]?)/, '<a href="http://www.law.cornell.edu/cfr/text/\1/part-\2">\1 Part \2</a>')


  	line = line + "<br>"
  	final_ptoa = final_ptoa + line
  end

  return final_ptoa + "</p>"
end

def add_nbsp(file)
	final_file = ""
	file.each_line do |line| # We're breaking this up for future optimization?
		line = line.gsub(/  /, '&nbsp&nbsp') 
		final_file = final_file + line
	end

	return final_file
end


puts "Start"
final = add_nbsp(edit_file(read_file("./ptoa_2014.txt")))
puts "End"

File.open('ptoa.html', 'w') { |file| file.write(final) }
