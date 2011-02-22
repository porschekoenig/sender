local smtp = require"socket.smtp"
require"yaci"

local NOSUBJECT = '<no subject>'
local EMPTYMSG = ''

SimpleSender = newclass("SimpleSender")

function SimpleSender:init(from)
	 self.from =  from
end

function SimpleSender:formatAddress(ad)
	 assert(type(ad) == 'string)

	 local mail = ad:gmatch("<[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?>")

	 if not mail then
	    return nil, "malformed email-address"
	 end

	 return mail	   
end

function SimpleSender:getRecps(rcps, ...)
	 assert(type(rcps) == 'table')

	 for i = 2, #arg do
	     local r = arg[i]
	     
	     if type(r) == 'boolean' then
	     		r = r
	     elseif type(r) == 'string' then
	             table.insert(rcps, self.formatAddress(r))
	     elseif type(r) ~= 'table' then 
	     	    return nil, "wrong parameter, expected string or table, got " .. type(r) 
	     else

		for _, i in ipairs(r) do
	     	    table.insert(rcps, self.formatAddress(i))
		end
	     end
	 end	

	 return rcps
end

function SimpleSender:send(data)
	 assert(type(data) == 'table'

	 self.from = data.from or self.from
 	 
	 assert(self.from)
	 assert(type(data.to) == 'table' or type(data.to) == 'table')

	 local cc = data.cc or false
	 local bcc = data.bcc or false
	 
	 local subject = data.subject or NOSUBJECT
	 local body = data.body or EMPTYMSG

	 local recps = {}
	 
	 self.getRcps(rcps, to, cc, bcc)

	 local headers = {rcps}	 
	 	 
end

from = "<onkeljojo@onkel.jojo>"

rcpt = {
  "<jost.degenhardt@googlemail.com>",
  "<porschekoenig@googlemail.com>",
  "<jhdfkhskfhshfkhfkhfhhshkfkd@googlemail.com>"
}

mesgt = {
  headers = {
    to = "Jost Degenhardt <jost.degenhardt@googlemail.com",
    cc = '<jhdfkhskfhshfkhfkhfhhshkfkd@googlemail.com>',
    subject = "Lua test"
  },
  body = "Hallohallo!"
}

r, e = smtp.send{
  from = from,
  rcpt = rcpt, 
  source = smtp.message(mesgt)
}
