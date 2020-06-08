local alphalist = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ'

function GetNameAndLink()
	local s, i, j, x, v
	if MODULE.CurrentDirectoryIndex == 0 then
		s = '0-9'
	else
		i = MODULE.CurrentDirectoryIndex + 1
		s = alphalist:sub(i, i)
	end
	if HTTP.GET(MODULE.RootURL .. '/category/' .. s .. '_views_' .. (URL + 1) .. '.html') then
		i = 1
		x = CreateTXQuery(HTTP.Document)
		for v in x.XPath('//*[@class="clistChr"]//span[@class="pagetor"]//text()').Get() do
			j = tonumber(v.ToString()) or 1
			if j > i then i = j end
		end
		UPDATELIST.CurrentDirectoryPageNumber = i
		x.XPathHREFTitleAll('//*[@class="clistChr"]/ul/li/div/h2/a', LINKS, NAMES)
	else
		return net_problem
	end
end

function GetInfo()
	MANGAINFO.URL = MaybeFillHost(MODULE.RootURL, URL)
	local s = MANGAINFO.URL
	if not(s:find('waring=1')) then s = s .. '?waring=1' end
	if HTTP.GET(s) then
		local x = CreateTXQuery(HTTP.Document)

		MANGAINFO.CoverLink = MaybeFillHost(MODULE.RootURL, x.XPathString('//table//td/a/img/@src'))
		MANGAINFO.Title     = x.XPathString('//title/substring-before(.," - Read ")')
		MANGAINFO.Authors   = x.XPathString('//table//table//td[starts-with(.,"Author:")]/string-join(./a,", ")')
		MANGAINFO.Genres    = x.XPathString('//table//table//td[starts-with(.,"Categories:")]/string-join(./a,", ")')
		MANGAINFO.Summary   = x.XPathString('//table//table//td[contains(.," Manga Summary ")]/substring-after(.,"Manga Summary ")')
		MANGAINFO.Status    = MangaInfoStatusIfPos(x.XPathString('//table//table//td[starts-with(.,"Status:")]/a'), 'Updated', 'Completed')

		x.XPathHREFAll('//*[@class="chapter_list"]/table//tr/td[1]/a', MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
		InvertStrings(MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
		return no_error
	else
		return net_problem
	end
end

function GetPageNumber()
	if HTTP.GET(MaybeFillHost(MODULE.RootURL, URL)) then
		TASK.PageNumber = tonumber(CreateTXQuery(HTTP.Document).XPathString('//select[@id="page"]/count(./option)')) or 0
		return true
	else
		return false
	end
end

function GetImageURL()
	if HTTP.GET(MaybeFillHost(MODULE.RootURL, URL):gsub('/+$', '') .. '/page-' .. (WORKID + 1)) then
		TASK.PageLinks[WORKID] = CreateTXQuery(HTTP.Document).XPathString('//img[@id="comicpic"]/@src')
		return true
	else
		return false
	end
end

function Init()
	local m = NewWebsiteModule()
	m.ID                         = '05ebc869b7e0466690041551612fee1c'
	m.Name                       = 'Taadd'
	m.RootURL                    = 'http://www.taadd.com'
	m.Category                   = 'English'
	m.OnGetNameAndLink           = 'GetNameAndLink'
	m.OnGetInfo                  = 'GetInfo'
	m.OnGetPageNumber            = 'GetPageNumber'
	m.OnGetImageURL              = 'GetImageURL'
	m.TotalDirectory             = alphalist:len()
end
