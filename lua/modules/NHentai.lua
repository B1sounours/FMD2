----------------------------------------------------------------------------------------------------
-- Local Constants
----------------------------------------------------------------------------------------------------

DirectoryPagination = '/?page='

----------------------------------------------------------------------------------------------------
-- Event Functions
----------------------------------------------------------------------------------------------------

-- Get info and chapter list for current manga.
function GetInfo()
	local x = nil
	local u = MaybeFillHost(MODULE.RootURL, URL)

	if not HTTP.GET(u) then return net_problem end

	x = CreateTXQuery(HTTP.Document)
	MANGAINFO.Title     = x.XPathString('//h1')
	if MODULE.Name == 'NHentai' then
		MANGAINFO.CoverLink = x.XPathString('//div[@id="cover"]//img/@data-src')
		MANGAINFO.Artists   = x.XPathStringAll('//*[@class="tags"]/a[contains(@href, "artist")]/*[@class="name"]')
		MANGAINFO.Genres    = x.XPathStringAll('//*[@class="tags"]/a[contains(@href, "tag")]/*[@class="name"]')
	else
		MANGAINFO.CoverLink = x.XPathString('//div[@id="cover"]//img/@src')
		MANGAINFO.Artists   = x.XPathStringAll('//section[@id="tags"]//a[contains(@href, "artists")]/text()')
		MANGAINFO.Genres    = x.XPathStringAll('//section[@id="tags"]//a[contains(@href, "tags")]/text()')
		MANGAINFO.Summary   = x.XPathString('//div[contains(@class, "drop-discription")]/p/text()')
	end
	MANGAINFO.ChapterLinks.Add(URL)
	MANGAINFO.ChapterNames.Add(MANGAINFO.Title)

	return no_error
end

-- Get the page count of the manga list of the current website.
function GetDirectoryPageNumber()
	local u = MODULE.RootURL .. DirectoryPagination .. 1

	if not HTTP.GET(u) then return net_problem end

	if MODULE.Name == 'NHentai' then
		PAGENUMBER = tonumber(CreateTXQuery(HTTP.Document).XPathString('//a[@class="last"]/@href/substring-after(.,"=")'))
	else
		PAGENUMBER = tonumber(CreateTXQuery(HTTP.Document).XPathString('//section[@class="pagination"]/li[last()]/a/@href'):match('?page=(%d+)&order='))
	end

	return no_error
end

-- Get LINKS and NAMES from the manga list of the current website.
function GetNameAndLink()
	local x = nil
	local u = MODULE.RootURL .. DirectoryPagination .. (URL + 1)

	if not HTTP.GET(u) then return net_problem end

	x = CreateTXQuery(HTTP.Document)
	x.XPathHREFAll('//div[@id="content"]/div[not(contains(@class, "popular"))]/div[@class="gallery"]/a', LINKS, NAMES)

	return no_error
end

-- Get the page count for the current chapter.
function GetPageNumber()
	local x = nil
	local u = MaybeFillHost(MODULE.RootURL, URL)

	if not HTTP.GET(u) then return net_problem end

	x = CreateTXQuery(HTTP.Document)
	x.XPathStringAll('//a[@class="gallerythumb"]/@href', TASK.PageContainerLinks)
	TASK.PageNumber = TASK.PageContainerLinks.Count

	return no_error
end

-- Extract/Build/Repair image urls before downloading them.
function GetImageURL()
	local u = MaybeFillHost(MODULE.RootURL, TASK.PageContainerLinks[WORKID])

	if HTTP.GET(u) then
		TASK.PageLinks[WORKID] = CreateTXQuery(HTTP.Document).XPathString('//section[@id="image-container"]//img/@src')
		return true
	end

	return false
end

----------------------------------------------------------------------------------------------------
-- Module Initialization
----------------------------------------------------------------------------------------------------

function Init()
	function AddWebsiteModule(id, name, url)
		local m = NewWebsiteModule()
		m.ID                       = id
		m.Name                     = name
		m.RootURL                  = url
		m.Category                 = 'H-Sites'
		m.OnGetInfo                = 'GetInfo'
		m.OnGetDirectoryPageNumber = 'GetDirectoryPageNumber'
		m.OnGetNameAndLink         = 'GetNameAndLink'
		m.OnGetPageNumber          = 'GetPageNumber'
		m.OnGetImageURL            = 'GetImageURL'
		m.SortedList               = true
	end
	AddWebsiteModule('f8d26ca921af4876b7ba84bd7e06fe82', 'NHentai', 'https://nhentai.net')
	AddWebsiteModule('0052cb4aabe0443ca0c97e1eb217728a', 'HentaiHand', 'https://hentaihand.com')
end