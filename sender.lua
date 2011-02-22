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

function tableToString(t, delim)
	 if type(t) == 'string' then return t end
x
	 assert(type(t) == 'table')
	 local delim = delim or ','
	 local s = ""

	 for i = 1,#t-1  do
	     s = s .. t[i] .. delim
	 end 

	 s = s .. t[#t]

	 return s
end

function SimpleSender:send(data)
	 assert(type(data) == 'table'

	 self.from = data.from or self.from
 	 
	 assert(self.from)
	 assert(type(data.to) == 'table' or type(data.to) == 'string')

	 local cc = data.cc or false
	 local bcc = data.bcc or false
	 
	 local subject = data.subject or NOSUBJECT
	 local body = data.body or EMPTYMSG

	 local recps = {}
	 
	 self.getRcps(rcps, to, cc, bcc)

	 local headers = {}
	 	 
	 headers.to = tableToString(data.to)
	 headers.cc = tableToString(cc)

	 headers.subject = subject

	 msg = {headers, body = body}

	 r, e = smtp.send{
	    from = from,
	    rcpts = rcpts,
	    source = smpt.message(msg)
	 }

	 return r, e
end
