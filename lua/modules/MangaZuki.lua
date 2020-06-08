local dirurl = '/manga-list'

function GetDirectoryPageNumber()
	if HTTP.GET(MODULE.RootURL..dirurl) then
		local s = CreateTXQuery(HTTP.Document).XPathString('(//ul[@class="pagination"]//a)[last()-1]/@href')
		PAGENUMBER = tonumber(s:match('=(%d+)$') or 1)
		return no_error
	else
		return net_problem
	end
end

function GetNameAndLink()
	if HTTP.GET(MODULE.RootURL..dirurl..'?page='..(URL + 1)) then
			CreateTXQuery(HTTP.Document).XPathHREFAll('//*[@class="row"]//a[@class="chart-title"]', LINKS, NAMES)
		return no_error
	else
		return net_problem
	end
end

function GetInfo()
	MANGAINFO.URL = MaybeFillHost(MODULE.RootURL, URL)
	if HTTP.GET(MANGAINFO.URL) then
		local x = CreateTXQuery(HTTP.Document)

		MANGAINFO.CoverLink = x.XPathString('//meta[@itemprop="photo"]/@content')
		MANGAINFO.Title     = x.XPathString('//div[@class="container"]/div[@class="row"]/div/h2')
		MANGAINFO.Summary   = x.XPathString('//h5[text()="Summary"]/following-sibling::*')

		x.XPathHREFAll('//ul[@class="chapters"]/li/h3/a', MANGAINFO.ChapterLinks, MANGAINFO.ChapterNames)
		MANGAINFO.ChapterLinks.Reverse(); MANGAINFO.ChapterNames.Reverse()
		return no_error
	else
		return net_problem
	end
end

function GetPageNumber()
	if HTTP.GET(MaybeFillHost(MODULE.RootURL, URL):gsub('/+$', '')) then
		CreateTXQuery(HTTP.Document).XPathStringAll('//div[@id="all"]/img/@data-src', TASK.PageLinks)
		return true
	else
		return false
	end
end

function Init()
	function AddWebsiteModule(id, website, rooturl, category)
		local m = NewWebsiteModule()
		m.ID                       = id
		m.Name                     = website
		m.RootURL                  = rooturl
		m.Category                 = category
		m.OnGetDirectoryPageNumber = 'GetDirectoryPageNumber'
		m.OnGetNameAndLink         = 'GetNameAndLink'
		m.OnGetInfo                = 'GetInfo'
		m.OnGetPageNumber          = 'GetPageNumber'
	end
	AddWebsiteModule('6c116508a52448eeae4d09ff909c9d22', 'MangaZuki', 'https://mangazuki.co', 'English-Scanlation')
	AddWebsiteModule('5d1a3c9e886f4e0b83894c8894914c24', 'MangaZukiRaws', 'https://raws.mangazuki.co', 'Raw')
end
