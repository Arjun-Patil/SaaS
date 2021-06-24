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
  dnsRecords.reject { |i| i.start_with?("#") }.map { |line| line.strip.split(", ") }.
    each_with_object({}) do |rec, recs|
    rec.each_with_object({}) do |a, nestRec|
      nestRec[:type] = rec[0]
      nestRec[:target] = rec[2]
      recs[rec[1]] = nestRec
    end
  end
end

def resolve(dns_records, lookup_chain, domain)
  record = dns_records[domain]
  if (!record)
    puts "Error: Record not found for " + domain
    exit
  elsif record[:type] == "CNAME"
    lookup_chain << record[:target]
    resolve(dns_records, lookup_chain, record[:target])
  elsif record[:type] == "A"
    lookup_chain << record[:target]
  else
    lookup_chain << "Invalid record type for " + domain
    return
  end
end

# # # To complete the assignment, implement `parse_dns` and `resolve`.
# # # Remember to implement them above this line since in Ruby
# # # you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
