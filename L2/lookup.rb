def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dnsRecords)
  hash = Hash.new { }
  removeSpacesAndComments = dnsRecords.filter { |a| a != "\n" and !a.start_with? "#" }
  splitRecord = removeSpacesAndComments.map { |b| b.split(",").map { |h| h.strip } }
  splitRecord.map { |value| hash[value[1]] = value[2] }
  return hash
end

def resolve(records, lookup_chain, domain)
  if !(records.has_key? domain) and !(records.has_value? domain)
    puts "Error: record not found for #{domain}"
    exit!
  elsif (domain.match /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
    return lookup_chain
  end
  lookup_chain.push(records[domain])
  resolve(records, lookup_chain, lookup_chain.last)
end

# # # To complete the assignment, implement `parse_dns` and `resolve`.
# # # Remember to implement them above this line since in Ruby
# # # you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
