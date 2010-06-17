#!/usr/bin/ruby

ENV['RAILS_ENV'] ||= 'production'
require File.expand_path('../../lib/glyphtree-client', __FILE__)
include GlyphTreeClient

OPTS = {:debug => true}

def my_glyphs
	glyphs = GlyphTreeClient::Config['secret_keys'].keys
end

def print_commands
	puts %Q{
 GlyphTree Console alpha

 Commands:
    help                              Show this message
    query @sandbox/*                  List the subaccounts under @sandbox
    query @sandbox/joe                Show the balance on Joe's account in 'sandbox'
    query @sandbox/joe %dollars %yen  Show the balance on Joe's account only for %dollars and %yen
    list                              List glyphs for which we know the private key
    send ...                          Execute a transaction. See 'help send' for more info
    quit|exit                         Exit

}
end

def print_help_send
	puts %Q{
 Help: send

  The general syntax is 'send <account> key:value key:value ...' with no space between keys and values.

  send @sandbox/joe %dollars:100
  -> Inject the @sandbox/joe with 100 new %dollars. You need the key for 'dollars' to inject currency this way

  send @sandbox/joe from:@sandbox/bob %dollars:100 %yen:200
  -> Give @sandbox/bob 100 %dollars and 200 %yen from @sandbox/joe. The @sandbox/joe account must have at least 100 %dollars and 200 %yen

}
end

def query_subaccounts(account)
	# assert that account is valid
	Glyph.parse_account_name(account)

	query = ListAccountQuery.new(:account => account)
	results = query.execute
	results.each do |subaccount|
		puts " - #{account}/#{subaccount}"
	end
end

def query_balance(account, currencies=nil)
	# assert that account / currencies are valid
	Glyph.parse_account_name(account)
	(currencies || []).each {|c| Glyph.parse_currency_name(c)}

	query = BalanceQuery.new(:account => account, :currencies => currencies)
	results = query.execute
	if results.empty?
		puts "  #{account} is empty."
	else
		results.each do |currency, value|
			puts " - #{currency}:\t#{value}"
		end
	end
end

def do_transact(to_account, from_account, diff)
	# assert that account / currencies are valid
	Glyph.parse_account_name(to_account)
	Glyph.parse_account_name(from_account) if from_account
	diff.each {|c,v| Glyph.parse_currency_name(c)}

	diffs = {to_account => diff}
	if from_account
		opp_diff = diff.inject({}){|h, (c,v)| h[c] = v*-1.0; h}
		diffs[from_account] = opp_diff
	end

	transaction = SwapTransaction.new(:diff=>diffs)
	results = transaction.execute
	puts results
end

print_commands

while true
	print "> "
	begin # trap ^C, ^D
		command = STDIN.readline.strip
	rescue Interrupt, EOFError => e
		puts "\nbye"
		break
	end

	catch (:break_case) do
		begin
			case command.downcase
				when 'help', 'query' then
					print_commands
				when 'list' then
					my_glyphs.each do |glyph|
						puts " - #{glyph}"
					end
				when /query\s+([^\s]+)\/\*/ then
					account = $1
					query_subaccounts(account)
				when /query\s+([^\s]+)\s*([^\s]+)?/ then
					account, currencies = $1, $2.nil? ? nil : $2.split
					query_balance(account, currencies)
				when /send\s+([^\s]+)\s(.+)/ then
					to_account, options_s = $1, $2
					from_account = nil
					assets = {}
					# TODO clean up
					options_s.split.each do |kv|
						kvsplit = kv.split(":")
						puts "  Error! Unexpected '#{kv}', expected <key>:<value>. See 'help send'" or throw(:break_case) if not kvsplit.length == 2
						if kvsplit[0] == 'from'
							puts "  Error! Too many from:<account> options" or throw(:break_case) if not from_account.nil?
							from_account = kvsplit[1]
						elsif kvsplit[0].start_with? '%'
							puts "  Error! Too many values for #{kvsplit[0]}" or throw(:break_case) if not assets[kvsplit[0]].nil?
							assets[kvsplit[0]] = kvsplit[1].to_f
						else
							puts "  Error! Unexpected key #{kvsplit[0]}" or throw(:break_case)
						end
					end
					do_transact(to_account, from_account, assets)
				when /help\s+send/, /send.*/ then
					print_help_send
				when 'quit', 'exit' then
					exit
				when /\s*/ then
					break
				else
					puts "  Unrecognized command!: #{command}"
			end
		rescue SystemExit => e
			puts "bye"
			exit
		rescue Exception => e
			puts "  Error! #{e.message}\nBacktrace:\n#{e.backtrace.map{|l| "  #{l}"}.join("\n")}"
		end
	end
end
