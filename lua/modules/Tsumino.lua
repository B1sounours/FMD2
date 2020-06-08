function Init()
	local m = NewWebsiteModule()
	m.ID                         = '2f5e1b629ce148988e56fca46798afd1'
	m.Name                       = 'Tsumino'
	m.RootURL                    = 'http://www.tsumino.com'
	m.Category                   = 'H-Sites'
	m.OnGetDirectoryPageNumber   = 'GetDirectoryPageNumber'
	m.OnGetNameAndLink           = 'GetNameAndLink'
	m.OnGetInfo                  = 'GetInfo'
	m.OnGetPageNumber            = 'GetPageNumber'
end

local dirurl = '/Books/Operate'
local dirurldata = 'PageNumber='
local dirurldataend = '&Text=&Sort=Newest&List=0&Length=0&MinimumRating=0&ExcludeList=0&CompletelyExcludeHated=false'

function GetDirectoryPageNumber()
	if HTTP.POST(MODULE.RootURL .. dirurl, dirurldata .. '1' .. dirurldataend) then
		PAGENUMBER = tonumber(CreateTXQuery(HTTP.Document).x.XPathString('json(*)("PageCount")')) or 1
		return no_error
	else
		return net_problem
	end
end

function GetNameAndLink()
	if HTTP.POST(MODULE.RootURL .. dirurl, dirurldata .. (URL + 1) .. dirurldataend) then
		local v for v in CreateTXQuery(HTTP.Document).XPath('json(*)("Data")().Entry').Get() do
			NAMES.Add(v.GetProperty('Title').ToString())
			LINKS.Add(MODULE.RootURL .. '/Book/Info/' .. v.GetProperty('Id').ToString())
		end
		return no_error
	else
		return net_problem
	end
end

function GetInfo()
	MANGAINFO.URL = MaybeFillHost(MODULE.RootURL, URL)
	if HTTP.GET(MANGAINFO.URL) then
		local x = CreateTXQuery(HTTP.Document)

		MANGAINFO.CoverLink = MaybeFillHost(MODULE.RootURL, x.XPathString('//img[@class="book-page-image img-responsive"]/@src'))
		MANGAINFO.Title     = x.XPathString('//div[@class="book-line"][starts-with(.,"Title")]/div[@class="book-data"]')
		MANGAINFO.Artists   = x.XPathString('//div[@class="book-line"][starts-with(.,"Artist")]/div[@class="book-data"]')
		MANGAINFO.Genres    = x.XPathStringAll('//div[@class="book-line"][starts-with(.,"Parody") or starts-with(.,"Characters") or starts-with(.,"Tags")]/div[@class="book-data"]/*')

		if MANGAINFO.Title ~= '' then
			MANGAINFO.ChapterLinks.Add(MANGAINFO.URL)
			MANGAINFO.ChapterNames.Add(MANGAINFO.Title)
		end
		return no_error
	else
		return net_problem
	end
end

function GetPageNumber()
	local bookid = URL:match('/info/(%d+)')
	if bookid == nil then return false end
	HTTP.Headers.Values['Referer'] = ' ' .. MODULE.RootURL .. 'Read/View' .. bookid
	if HTTP.POST(MODULE.RootURL .. '/Read/Load', 'q=' .. bookid) then
		local crypto = require 'fmd.crypto'
		local v for v in CreateTXQuery(HTTP.Document).XPath('json(*).reader_page_urls()').Get() do
			TASK.PageLinks.Add(MODULE.RootURL .. '/Image/Object?name=' .. crypto.EncodeURLElement(v.ToString()))
		end
		return true
	else
		return false
	end
end
