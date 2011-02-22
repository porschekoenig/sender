local smtp = require"socket.smtp"
require"yaci"

local NOSUBJECT = '<no subject>'
local EMPTYMSG = ''

SimpleSender = newclass("SimpleSender")

function SimpleSender:init(from)
	 self.from =  from
end

function SimpleSender:formatAddress(ad)
	 assert(type(ad) == 'string')

	 local mail = ad:gmatch("<[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?>")

	 if not mail then
	    return nil, "malformed email-address: " .. ad
	 end
	 
	 return ad	   
end

function SimpleSender:getRcps(rcps, ...)
	 assert(type(rcps) == 'table', "table expected, got " .. type(rcps))

	 for i = 1, #arg do
	     local r = arg[i]
	     
	     if type(r) == 'string' and #r > 0 then
	             table.insert(rcps, assert(self:formatAddress(r)))
	     elseif type(r) ~= 'table' then 
	     	    return nil, "wrong parameter, expected string or table, got " .. type(r) 
	     else
		for _, i in ipairs(r) do
	     	    table.insert(rcps, assert(self:formatAddress(i)))
		end
	     end
	 end	

	 return rcps
end

function tableToString(t, delim)
	 if type(t) == 'string' then return t end

	 assert(type(t) == 'table', "table expected, got " .. type(t))

	 local delim = delim or ','
	 local s = ""

	 for i = 1,#t-1  do
	     s = s .. t[i] .. delim
	 end 

	 s = s .. t[#t]

	 return s
end

function SimpleSender:sendit(from, to)
	 return self:send({from=from, to=to})
end

function SimpleSender:send(data)
	 assert(type(data) == 'table', 'table expected, got ' .. type(data))

	 self.from = data.from or self.from
 	 
	 assert(self.from)
	 assert(type(data.to) == 'table' or type(data.to) == 'string', 'table or string expected, got ' .. type(data.to))

	 local cc = data.cc or ''
	 local bcc = data.bcc or ''
	 
	 local subject = data.subject or NOSUBJECT
	 local body = data.body or EMPTYMSG

	 local rcpt = {}
	 self:getRcps(rcpt, data.to, cc, bcc)

	 local headers = {}
	 	 
	 headers.to = tableToString(data.to)
	 headers.cc = tableToString(cc)
	
	 headers.subject = subject

	 msg = {headers = headers, body = body}

	 local mt = {from = self.from, rcpt = rcpt, source = smtp.message(msg)}

	print('from: ' .. mt.from)
	print('to: ' .. msg.headers.to)
	print('cc: ' .. msg.headers.cc)
	print('subject: ' .. msg.headers.subject)
	print('body: ' .. msg.body)

	for k,v in pairs(mt.rcpt) do
		print("rcpt: ", k, v)
	end

	 local r, e = smtp.send(mt)

	 return r, e
end


se = SimpleSender:new()

r, e = se:sendit(arg[1], arg[2])

print(r,e)
